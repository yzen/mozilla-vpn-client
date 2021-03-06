/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.5
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Mozilla.VPN 1.0
import "../components"
import "../themes/themes.js" as Theme

VPNFlickable {
    id: vpnFlickable

    flickContentHeight: vpnPanel.height + alertWrapperBackground.height + footerContent.height + (Theme.windowMargin * 4)
    state: VPN.updateRecommended ? "recommended" : "required"
    states: [
        State {
            name: "recommended"

            PropertyChanges {
                target: vpnPanel
                //% "Update recommended"
                logoTitle: qsTrId("vpn.updates.updateRecomended")
                //% "Please update the app before you continue to use the VPN"
                logoSubtitle: qsTrId("vpn.updates.updateRecomended.description")
                logo: "../resources/updateRecommended.svg"
            }

            PropertyChanges {
                target: signOff
                visible: false
            }

            PropertyChanges {
                target: footerLink
                onClicked: {
                    // TODO Should we hide the alert after "Not now" is clicked ?
                    // Can it be accessed again?
                    alertBox.visible = true;
                    stackview.pop(StackView.Immediate);
                }
            }

        },
        State {
            name: "required"

            PropertyChanges {
                target: vpnPanel
                //% "Update required"
                logoTitle: qsTrId("vpn.updates.updateRequired")
                //% "We detected and fixed a serious bug. You must update your app."
                logoSubtitle: qsTrId("vpn.updates.updateRequire.reason")
                logo: "../resources/updateRequired.svg"
            }

            PropertyChanges {
                target: signOff
                visible: VPN.userAuthenticated
            }

            PropertyChanges {
                target: footerLink
                onClicked: {
                    // TODO - should anything happen here besides opening
                    // the user account website?
                    VPN.openLink(VPN.LinkAccount);
                }
            }

        }
    ]

    Item {
        id: spacer1

        height: Math.max(Theme.windowMargin * 2, ( window.height - flickContentHeight ) / 2)
        width: vpnFlickable.width
    }

    VPNPanel {
        id: vpnPanel

        property var childRectHeight: vpnPanel.childrenRect.height

        anchors.top: spacer1.bottom
        width: Math.min(vpnFlickable.width - Theme.windowMargin * 4, Theme.maxHorizontalContentWidth)
        logoSize: 80
    }

    Item {
        id: spacer2

        anchors.top: vpnPanel.bottom
        height: Math.max(Theme.windowMargin * 2, (window.height -flickContentHeight ) / 2)
        width: vpnFlickable.width
    }

    VPNDropShadow {
        anchors.fill: alertWrapperBackground
        source: alertWrapperBackground
    }

    Rectangle {
        id: alertWrapperBackground

        anchors.fill: alertWrapper
        color: Theme.white
        radius: 8
        anchors.topMargin: -Theme.windowMargin
        anchors.bottomMargin: -Theme.windowMargin
        anchors.leftMargin: -Theme.windowMargin
        anchors.rightMargin: -Theme.windowMargin
    }

    ColumnLayout {
        id: alertWrapper

        anchors.top: spacer2.bottom
        anchors.topMargin: Theme.windowMargin
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(vpnFlickable.width - (Theme.windowMargin * 4), Theme.maxHorizontalContentWidth)

        RowLayout {
            id: insecureConnectionAlert

            Layout.minimumHeight: 40
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 16

            Image {
                source: "../resources/connection-info-dark.svg"
                sourceSize.width: 20
                sourceSize.height: 20
                antialiasing: true
            }

            VPNTextBlock {
                id: alertUpdateRecommendedText

                font.family: Theme.fontInterFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.fontColorDark
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                //% "Your connection will not be secure while you update."
                text: qsTrId("vpn.updates.updateConnectionInsecureWarning")
            }

        }

    }

    ColumnLayout {
        id: footerContent

        anchors.top: alertWrapperBackground.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width, Theme.maxHorizontalContentWidth)
        spacing: Theme.windowMargin * 1.25

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.windowMargin / 2
            color: "transparent"
        }

        VPNButton {
            id: updateBtn

            text: qsTrId("vpn.updates.updateNow")
            radius: 4
            onClicked: VPN.openLink(VPN.LinkUpdate)
        }

        VPNLinkButton {
            id: footerLink

            //% "Not now"
            readonly property var textNotNow: qsTrId("vpn.updates.notNow")
            //% "Manage account"
            readonly property var textManageAccount: qsTrId("vpn.main.manageAccount")

            Layout.alignment: Qt.AlignHCenter
            labelText: (vpnFlickable.state === "recommended") ? textNotNow : textManageAccount
        }

        VPNSignOut {
            id: signOff

            anchors.bottom: undefined
            anchors.bottomMargin: undefined
            anchors.horizontalCenter: undefined
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                stackview.pop(StackView.Immediate);
                VPNController.logout();
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.windowMargin * 2
            color: "transparent"
        }

    }

}
