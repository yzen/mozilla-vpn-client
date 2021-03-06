/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.5
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Mozilla.VPN 1.0
import "../components"
import "../themes/themes.js" as Theme

Item {
    property alias isSettingsView: menu.isSettingsView

    VPNMenu {
        id: menu
        objectName: "getHelpBack"

        //% "Get Help"
        title: qsTrId("vpn.main.getHelp")
        isSettingsView: true
    }

    VPNList {
        height: parent.height - menu.height
        width: parent.width
        anchors.top: menu.bottom
        spacing: Theme.listSpacing
        anchors.topMargin: Theme.windowMargin
        listName: menu.title

        model: VPNHelpModel

        delegate: VPNExternalLinkListItem {
            title: name
            accessibleName: name
            onClicked: VPNHelpModel.open(id)
        }

        ScrollBar.vertical: ScrollBar {
            Accessible.ignored: true
        }

    }

}
