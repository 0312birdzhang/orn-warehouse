import QtQuick 2.0
import Sailfish.Silica 1.0
import "."

Column {
    signal busyStatusChanged

    property bool showPending: false
    property alias transactionCount: transactionModel.count

    width: parent.width
    spacing: 5

    visible: true //if any transactions available

    Connections {
        target: pkgManagerProxy
        onTransactionListChanged: {
            transactionModel.clear();
            transactionList.forEach(function(transaction) {
                if (transactionModel.count && !showPending)
                    return;
                transactionModel.append({
                    "name": transaction.name,
                    "action": transaction.role,
                    "application": transaction.data,
                    "progress": 0,
                });
                //make call to get application info
            });
        }
        onTransactionPackage: {
            for(var i = 0; i<transactionModel.count; i++) {
                var transaction = transactionModel.get(i);
                if (transaction.name === trname) {
                    transaction.action = pkgstatus;
                    transaction.application = pkgobject.name;
                    transactionModel.set(i, transaction);
                    return;
                }
            }
        }
        onTransactionFinished: {
            for(var i = 0; i<transactionModel.count; i++) {
                var transaction = transactionModel.get(i);
                if (transaction.name === trname) {
                    transactionModel.remove(i);
                    return;
                }
            }
        }
        onTransactionProgress: {
            for(var i = 0; i<transactionModel.count; i++) {
                var transaction = transactionModel.get(i);
                if (transaction.name === trname) {
                    transaction.progress = trprogress;
                    transaction.application = "%1 v%2".arg(pkgobject.name).arg(pkgobject.version);
                    transactionModel.set(i, transaction);
                    return;
                }
            }
        }
        onTransactionRepoDetail: {
            for(var i = 0; i<transactionModel.count; i++) {
                var transaction = transactionModel.get(i);
                if (transaction.name === trname) {
                    transaction.application = repoid;
                    /*transaction.progress = trprogress;
                    transaction.application = "%1 v%2".arg(pkgobject.name).arg(pkgobject.version);
                    transactionModel.set(i, transaction);*/
                    return;
                }
            }
        }
    }

    ListModel {
        id: transactionModel
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        color: myTheme.primaryColor
        font.pixelSize: myTheme.fontSizeMedium
        text: qsTr("Current operation")
        visible: transactionModel.count
    }

    Repeater {
        id: transactionViewer
        width: parent.width
        model: transactionModel
        delegate: transactionDelegate
    }

    function operationText(rawStatus) {
        return rawStatus;
    }

    Component {
        id: transactionDelegate

        Column {
            width: transactionViewer.width
            spacing: 5

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: myTheme.primaryColor
                font.pixelSize: myTheme.fontSizeSmall
                text: operationText(model.action)
                visible: text.length > 0
            }            

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: myTheme.primaryColor
                font.pixelSize: myTheme.fontSizeSmall
                text: model.application
                visible: text.length > 0
            }

            ProgressBar {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width/3*2
                minimumValue: 0
                maximumValue: 100
                value: model.progress
                indeterminate: model.progress === 0
            }
        }
    }
}
