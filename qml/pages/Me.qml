import QtQuick 1.1
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: appList

    signal update()

    property variant repositories: undefined

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: qsTr("Your profile")
    //headerIcon: "../icons/icon-header-checkinhistory.png"

    function load() {
        var page = appList;
        page.update.connect(function(){
            pkgManager.updateRepositoryList();
        })
        page.update();
    }
    function updateView() {
        update();
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
    }

    Connections {
        target: pkgManager
        onRepositoryListChanged: {
            repositories = repos;
        }
    }

    Flickable{
        id: flickableArea
        anchors.top: pagetop
        width: parent.width
        height: parent.height - y
        contentWidth: parent.width

        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        pressDelay: 100

        Column {
            id: reposColumn
            width: parent.width
            spacing: 10

            onHeightChanged: {
                flickableArea.contentHeight = height + y;
            }

            SectionHeader {
                text: qsTr("Current operations")
            }
            SectionHeader {
                text: qsTr("Some weird stuff")
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Enable test repos"
                onClicked: {
                    repositoryScript.sendMessage({"name":"basil","state":true});
                    repositoryScript.sendMessage({"name":"appsformeego","state":true});
                    repositoryScript.sendMessage({"name":"knobtviker","state":true});
                }
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Fetch repository info"
                enabled: !manageBox.opInProgress
                onClicked: {
                    pkgManager.fetchRepositoryInfo();
                }
            }
            AppManageBox {
                id: manageBox
            }

            SectionHeader {
                text: qsTr("Enabled repositories")
            }

            Repeater {
                width: parent.width
                model: repositories
                delegate: repositoryDelegate
            }
        }
    }

    Component {
        id: repositoryDelegate

        Item {
            width: reposColumn.width
            height: disableButton.height + 20
            Text {
                id: repoName
                anchors{
                    left: parent.left
                    right: disableButton.left
                    margins: mytheme.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                font.pixelSize: mytheme.fontSizeLarge
                maximumLineCount: 2
                color: mytheme.colors.textColorOptions
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                text: modelData.name
            }
            Button {
                id: disableButton
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }

                width: 150
                text: qsTr("Disable")
                onClicked: repositoryScript.sendMessage({"name":modelData.name,"state":false});
            }
        }
    }

    /*WorkerScript {
        id: repositoryScript
        source: "../js/repositoryscript.js"

        onMessage: {
            if (messageObject.state) {
                pkgManager.enableRepository(messageObject.name);
            } else {
                pkgManager.disableRepository(messageObject.name);
            }
        }
    }*/
}
