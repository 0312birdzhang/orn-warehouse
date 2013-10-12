import Qt 4.7
import com.nokia.meego 1.0
import "../components"

import "../js/api.js" as Api

PageWrapper {
    id: appDetails
    signal update()

    property variant application: {}

    width: parent.width
    height: parent.height
    color: mytheme.colors.backgroundMain

    headerText: qsTr("Application details")
    //headerIcon: "../icons/icon-header-checkinhistory.png"

    function load() {
        var page = appDetails;
        page.update.connect(function(){
            Api.apps.loadApplication(page, application.appid);
        })
        page.update();
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { }
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
            width: parent.width
            spacing: 10

            onHeightChanged: {
                flickableArea.contentHeight = height + y;
            }

            ApplicationBox {
                application: appDetails.application
                categorystyle: "full"
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Install")
                onClicked: {
                    show_error("You cannot install apps yet!");
                }
            }
            SectionHeader {
                text: qsTr("Description")
            }
            Text {
                anchors {
                    left: parent.left
                    leftMargin: 10
                    right: parent.right
                    rightMargin: 10
                }

                font.pixelSize: mytheme.font.sizeHelp
                horizontalAlignment: Text.AlignHCente
                wrapMode: Text.WordWrap

                text: application.body !== undefined ? application.body : ""
            }

            SectionHeader {
                text: qsTr("Comments & reviews")
            }
            NextBox {
                text: qsTr("Comments (%1)").arg(application.comments_count);
            }

            SectionHeader {
                text: qsTr("Screenshots")
                visible: application.screenshots!== undefined
            }
            ScreenshotBox {
                screenshots: application.screenshots
                visible: application.screenshots!== undefined
            }

            SectionHeader {
                text: qsTr("Publisher")
            }
            NextBox {
                text: qsTr("More apps by %1").arg(application.user.name);
            }

            SectionHeader {
                text: qsTr("Releated")
            }
            Text {
                text: "some related stuff by cat and tags"
                font.pixelSize: mytheme.font.sizeHelp
            }
        }
    }

    Component {
        id: catDelegate

        Item{

        }
    }
}
