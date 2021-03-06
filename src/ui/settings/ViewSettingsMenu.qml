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

    width: window.width
    flickContentHeight: settingsList.y + (settingsList.count * 56) + signOutLink.height + signOutLink.anchors.bottomMargin
    ListModel {
        id: settingsMenuListModel

        /* TODO - disable captive portal and its notifications
        ListElement {
            settingTitle: qsTrId("vpn.settings.notifications")
            imageLeftSource: "../resources/settings/notifications.svg"
            imageRightSource: "../resources/chevron.svg"
            pushView: "../settings/ViewNotifications.qml"
        }
        */

        ListElement {
            settingTitle: qsTrId("vpn.settings.networking")
            imageLeftSource: "../resources/settings/networkSettings.svg"
            imageRightSource: "../resources/chevron.svg"
            pushView: "../settings/ViewNetworkSettings.qml"
        }

        ListElement {
            settingTitle: qsTrId("vpn.settings.language")
            imageLeftSource: "../resources/settings/language.svg"
            imageRightSource: "../resources/chevron.svg"
            pushView: "../settings/ViewLanguage.qml"
        }

        ListElement {
            settingTitle: qsTrId("vpn.settings.aboutUs")
            imageLeftSource: "../resources/settings/aboutUs.svg"
            imageRightSource: "../resources/chevron.svg"
            pushAboutUs: true
        }

        ListElement {
            settingTitle: qsTrId("vpn.main.getHelp")
            imageLeftSource: "../resources/settings/getHelp.svg"
            imageRightSource: "../resources/chevron.svg"
            pushGetHelp: true
        }

        ListElement {
            //% "Give feedback"
            settingTitle: qsTrId("vpn.settings.giveFeedback")
            imageLeftSource: "../resources/settings/feedback.svg"
            imageRightSource: "../resources/externalLink.svg"
            openUrl: VPN.LinkFeedback
        }

    }

    VPNIconButton {
        id: iconButton

        onClicked: stackview.pop(StackView.Immediate)
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: Theme.windowMargin / 2
        anchors.leftMargin: Theme.windowMargin / 2
        accessibleName: qsTrId("vpn.main.back")

        Image {
            id: backImage

            source: "../resources/close-dark.svg"
            sourceSize.width: Theme.iconSize
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: iconButton
        }

    }



    VPNPanel {
        id: vpnPanel
        logoSize: 80
        logo:  VPNUser.avatar
        //% "VPN User"
        readonly property var textVpnUser: qsTrId("vpn.settings.user")
        logoTitle: VPNUser.displayName ? VPNUser.displayName : textVpnUser
        logoSubtitle: VPNUser.email
        y: (Math.max(window.height * .08, Theme.windowMargin * 2))
        maskImage: true
        imageIsVector: false
    }

    VPNButton {
        id: manageAccountButton

        text: qsTrId("vpn.main.manageAccount")
        anchors.top: vpnPanel.bottom
        anchors.topMargin: Theme.vSpacing
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: VPN.openLink(VPN.LinkAccount)
    }

    VPNCheckBoxRow {
        id: startAtBootCheckBox

        //% "Launch VPN app on Startup"
        labelText: qsTrId("vpn.settings.runOnBoot")
        subLabelText: ""
        isChecked: VPNSettings.startAtBoot
        isEnabled: true
        showDivider: true
        anchors.top: manageAccountButton.bottom
        anchors.topMargin: Theme.hSpacing * 1.5
        anchors.rightMargin: Theme.hSpacing
        width: vpnFlickable.width - Theme.hSpacing
        onClicked: VPNSettings.startAtBoot = !VPNSettings.startAtBoot

        visible: VPN.startOnBootSupported
    }

    Component {
        id: getHelpComponent

        VPNGetHelp {
            isSettingsView: true
        }

    }

    Component {
        id: aboutUsComponent

        VPNAboutUs {
            isSettingsView: true
        }
    }

    VPNList {
        id: settingsList

        height: parent.height - y
        width: parent.width
        y: Theme.vSpacing + (VPN.startOnBootSupported ? startAtBootCheckBox.y + startAtBootCheckBox.height : manageAccountButton.y + manageAccountButton.height)
        spacing: Theme.listSpacing
        //% "Settings"
        listName: qsTrId("vpn.main.settings")
        model: settingsMenuListModel

        delegate: VPNClickableRow {
            accessibleName: settingTitle
            onClicked: {
                if (pushAboutUs)
                    return settingsStackView.push(aboutUsComponent);

                if (pushGetHelp)
                    return settingsStackView.push(getHelpComponent);

                if (pushView)
                    return settingsStackView.push(pushView);

                return VPN.openLink(openUrl);
            }

            VPNSettingsItem {
                setting: settingTitle
                imageLeftSrc: imageLeftSource
                imageRightSrc: imageRightSource
            }

        }

    }

    VPNSignOut {
        id: signOutLink

        onClicked: VPNController.logout()
    }

}
