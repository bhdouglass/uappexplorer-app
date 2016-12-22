import QtQuick 2.4
//import QtPurchasing 1.0
import Ubuntu.Web 0.2
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import com.canonical.Oxide 1.0 as Oxide
import 'UCSComponents'

MainView {
    id: root
    objectName: 'mainView'

    applicationName: 'uappexplorer.bhdouglass'

    anchorToKeyboard: true
    automaticOrientation: true

    property string urlPattern: 'https?://uappexplorer.com/*,https://login.ubuntu.com/*'

    width: units.gu(50)
    height: units.gu(75)

    Page {
        id: page
        anchors {
            fill: parent
            bottom: parent.bottom
        }
        width: parent.width
        height: parent.height

        header: PageHeader {
            id: header
            visible: false
        }

        WebContext {
            id: webcontext
            userAgent: 'Mozilla/5.0 (Linux; Android 5.0; Nexus 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.102 Mobile Safari/537.36 Ubuntu Touch Webapp'
        }

        WebView {
            id: webview
            anchors {
                fill: parent
                bottom: parent.bottom
            }
            width: parent.width
            height: parent.height

            context: webcontext
            url: 'https://uappexplorer.com/'
            preferences.localStorageEnabled: true
            preferences.appCacheEnabled: true
            preferences.javascriptCanAccessClipboard: true

            function navigationRequestedDelegate(request) {
                var url = request.url.toString();
                var pattern = urlPattern.split(',');
                var isvalid = false;

                for (var i=0; i<pattern.length; i++) {
                    var tmpsearch = pattern[i].replace(/\*/g,'(.*)');
                    var search = tmpsearch.replace(/^https\?:\/\//g, '(http|https):\/\/');

                    if (url.match(search)) {
                       isvalid = true;
                       break;
                    }
                }

                if (isvalid == false) {
                    Qt.openUrlExternally(url);
                    request.action = Oxide.NavigationRequest.ActionReject;
                }
            }

            Component.onCompleted: {
                preferences.localStorageEnabled = true;
            }
        }

        ProgressBar {
            height: units.dp(3)
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }

            showProgressPercentage: false
            value: (webview.loadProgress / 100)
            visible: (webview.loading && !webview.lastLoadStopped)
        }

        RadialBottomEdge {
            id: nav
            visible: true

            actions: [
                RadialAction {
                    id: home
                    text: qsTr('Home')
                    iconName: 'home'
                    onTriggered: {
                        webview.url = 'https://uappexplorer.com/';
                    }
                },

                RadialAction {
                    id: forward
                    text: qsTr('Forward')
                    iconName: 'go-next'
                    onTriggered: {
                        webview.goForward();
                    }
                    enabled: webview.canGoForward
                },

                RadialAction {
                    id: reload
                    text: qsTr('Reload')
                    iconName: 'reload'
                    onTriggered: {
                        webview.reload();
                    }
                },

                RadialAction {
                    id: back
                    text: qsTr('Back')
                    iconName: 'go-previous'
                    enabled: webview.canGoBack
                    onTriggered: {
                        webview.goBack();
                    }
                }

                /*RadialAction {
                    id: donate
                    text: qsTr('Donate')
                    iconName: 'like'
                    onTriggered: {
                        PopupUtils.open(donationComponent)
                    }
                }*/
            ]
        }
    }

    /*Component {
        id: donationComponent

        Dialog {
            id: donationDialog
            state: 'DONATE'
            text: 'Help make uApp Explorer better with a $3/£3/€3 donation!'

            ActivityIndicator {
                id: loading
                running: true
            }

            Button {
                id: donateButton
                text: 'Donate'
                color: UbuntuColors.orange
                onClicked: {
                    donationDialog.state = 'LOADING';
                    donation3.purchase();
                }
            }

            Button {
                id: closeButton
                text: 'Close'
                onClicked: {
                    donationDialog.state = 'DONATE';
                    PopupUtils.close(donationDialog);
                }
            }

            states: [
                State {
                    name: 'DONATE'
                    PropertyChanges {target: donationDialog; title: 'Donate to uApp Explorer'}
                    PropertyChanges {target: donationDialog; text: 'Help make uApp Explorer better with a $3/£3/€3 donation!'}
                    PropertyChanges {target: loading; visible: false}
                    PropertyChanges {target: donateButton; visible: true}
                    PropertyChanges {target: closeButton; visible: true}
                },
                State {
                    name: 'LOADING'
                    PropertyChanges {target: donationDialog; title: ''}
                    PropertyChanges {target: donationDialog; text: 'Preparing the transaction'}
                    PropertyChanges {target: loading; visible: true}
                    PropertyChanges {target: donateButton; visible: false}
                    PropertyChanges {target: closeButton; visible: true}
                },
                State {
                    name: 'THANKS'
                    PropertyChanges {target: donationDialog; title: 'Thank you!'}
                    PropertyChanges {target: donationDialog; text: 'Thank you for your donation!'}
                    PropertyChanges {target: loading; visible: false}
                    PropertyChanges {target: donateButton; visible: false}
                    PropertyChanges {target: closeButton; visible: true}
                },
                State {
                    name: 'ERROR'
                    PropertyChanges {target: donationDialog; title: 'Error'}
                    PropertyChanges {target: donationDialog; text: 'There was an error processing your donation, please try again later.'}
                    PropertyChanges {target: loading; visible: false}
                    PropertyChanges {target: donateButton; visible: false}
                    PropertyChanges {target: closeButton; visible: true}
                }
            ]

            Connections {
                target: donation3
                onStatusChanged: {
                    if (donation3.status == 'success') {
                        donationDialog.state = 'THANKS';
                        donation3.status = 'pending';
                    }
                    else if (donation3.status == 'failed') {
                        donationDialog.state = 'ERROR';
                        donation3.status = 'pending';
                    }
                    else if (donation3.status == 'canceled') {
                        donationDialog.state = 'DONATE';
                        PopupUtils.close(donationDialog);
                        donation3.status = 'pending';
                    }
                }
            }
        }
    }

    Store {
        Product {
            id: donation3
            identifier: 'uappexplorer.donation3'
            type: Product.Consumable

            property string status: 'pending'

            onPurchaseSucceeded: {
                status = 'success';
                transaction.finalize();
            }

            onPurchaseFailed: {
                console.log('reason: ' + transaction.failureReason);
                console.log('error: ' + transaction.errorString);

                if (transaction && transaction.failureReason === Transaction.CanceledByUser) {
                    status = 'canceled'
                }
                else {
                    status = 'failed';
                }

                transaction.finalize();
            }
        }
    }*/

    Connections {
        target: Qt.inputMethod
        onVisibleChanged: (nav.visible = !nav.visible)
    }

    Connections {
        target: webview
        onFullscreenChanged: (nav.visible = !webview.fullscreen)
    }

    Connections {
        target: UriHandler
        onOpened: {
            webview.url = uris[0];
        }
    }
}
