/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.0
import QtQuick.Controls 2.5

import "../themes/themes.js" as Theme

// VPNRadioButtonLabel
Label {
    anchors.left: radioButton.right
    anchors.leftMargin: Theme.hSpacing - 2

    font.family: vpnFontInter.name
    font.pointSize: Theme.fontSize
    color: Theme.fontColorDark

    states: State {
        when: radioControl.checked
        PropertyChanges {
            target: radioButtonLabel
            color: Theme.buttonColor
        }
    }

    transitions: Transition {
        ColorAnimation {
            target: radioButtonLabel
            properties: "color"
            duration: 100
        }
    }
}
