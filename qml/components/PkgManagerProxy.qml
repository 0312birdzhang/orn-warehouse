import Qt 4.7
import "../js/threadworker.js" as WorkerJS

Item {
    id: proxy
    signal processedOperation(variant operation)

    property variant lastoperation: undefined
    property int actionNumber: 0
    property bool opInProgress: queuedActions !== 0 || localOperation
    property bool localOperation: false
    property int queuedActions: 0

    function execute(name, params, callback) {
        var actionitem = "action-"+(actionNumber++);
        var actionitemobj = WorkerJS.objs.save(actionitem);
        actionitemobj.callback = callback;
        var msg = {
            "name": name,
            "params": params,
            "item": actionitem,
        };
        queuedActions++;
        pkgManager.queueAction(msg);
    }

    function actionDone(msg) {
        var actionitemobj = WorkerJS.objs.get(msg.item);
        if (msg.error) {
            appWindow.stack.currentPage.show_error(msg.errorText);
        } else {
            if (actionitemobj.callback !== undefined) {
                try {
                    actionitemobj.callback(msg.result);
                } catch (e) {};
            }
        }
        queuedActions--;
        WorkerJS.objs.remove(msg.item);
    }

    function installSourcePolicy(callback) {
        proxy.execute("installSourcePolicy","",callback);
    }

    function fetchRepositoryInfo(name, callback) {
        if (name === undefined) {
            name = "";
        } else {
            name = "openrepos-"+name;
        }
        proxy.execute("fetchRepositoryInfo", name, callback);
    }

    function updateRepositoryList(callback) {
        proxy.execute("updateRepositoryList", "", callback);
    }

    function enableRepository(name, callback) {
        proxy.execute("enableRepository",name, callback);
    }
    function disableRepository(name, callback) {
        proxy.execute("disableRepository",name, callback);
    }

    function isRepositoryEnabled(repository, callback) {
        proxy.execute("isRepositoryEnabled", repository, callback);
    }

    function getPackageInfo(packagename, callback) {
        proxy.execute("getPackageInfo", packagename, callback);
    }

    function getInstalledPackages(owned, callback) {
        proxy.execute("getInstalledPackages", owned, callback);
    }

    function install(packagename, callback) {
        proxy.execute("install", packagename, callback);
    }
    function upgrade(packagename, callback) {
        proxy.execute("upgrade", packagename, callback);
    }

    function uninstall(packagename, callback) {
        proxy.execute("uninstall",packagename, callback);
    }

    //##### Callback-signal functions #####
    function processOperation(status, operation, name, version, progress) {
        lastoperation = {
            "status": status,
            "operation": operation,
            "name": name,
            "version": version,
            "progress": progress
        };
        if (status === "Completed") {
            localOperation = false;
        } else {
            localOperation = true;
        }
        //console.log("PROCESS OPERATION: " + JSON.stringify(lastoperation));
        pkgManagerProxy.processedOperation(lastoperation);
    }

    function operationProgress(operation, name, version, progress) {
        //console.log("OPERATION PROGRESS: %1 %2 %3 %4".arg(operation).arg(name).arg(version).arg(progress));
        processOperation("Progress", operation, name, version, progress);
    }
    function operationStarted(operation,name,version){
        //console.log("OPERATION STARTED: %1 %2 %3".arg(operation).arg(name).arg(version));
        processOperation("Started", operation, name, version, 0)
    }
    function operationCompleted(operation,name,version,message,error) {
        //console.log("OPERATION COMPLETED: %1 %2 %3 %4 %5".arg(operation).arg(name).arg(version).arg(message).arg(error));
        processOperation("Completed", operation, name, version, 0)
    }
    function downloadProgress(operation, name, version, curBytes, totalBytes){
        //console.log("DOWNLOAD PROGRESS: %1 %2 %3 %4 %5".arg(operation).arg(name).arg(version).arg(curBytes).arg(totalBytes));
        operationProgress("Download", name, version, curBytes/totalBytes*100);
    }
    function packageListUpdated(updates) {
        //console.log("PACKAGE LIST UPDATED: " + updates);
    }

    function reemitOperation(callback) {
        if (lastoperation !== undefined) {
            callback(lastoperation);
        }
    }

    Connections {
        target: pkgManager
        onActionDone: actionDone(msg);

        onOperationStarted: operationStarted(operation,name,version)
        onOperationProgress: operationProgress(operation, name, version, progress);
        onOperationCompleted: operationCompleted(operation, name, version, message, error);
        onDownloadProgress: downloadProgress(operation, name, version, curBytes, totalBytes);
        onPackageListUpdate: packageListUpdated(updates);
    }
}
