// OldNet "Turn off computer" screen: Windows XP's layout (three big actions in a
// titled box, Cancel at the bottom right) in the OldNet skin. Loaded by Plasma's
// logout greeter from the global theme; if this file fails, Plasma falls back to Breeze.
//
// Context properties from the greeter: maysd (can shut down), canLogout, spdMethods
// (SuspendState, HibernateState), sdtype. Actions are the root signals below.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import org.kde.kirigami as Kirigami

Item {
    id: root

    signal logoutRequested()
    signal haltRequested()
    signal suspendRequested(int spdMethod)
    signal rebootRequested()
    signal rebootRequested2(int opt)
    signal cancelRequested()
    signal lockScreenRequested()

    readonly property bool canSuspend: typeof spdMethods !== "undefined" && !!spdMethods.SuspendState
    readonly property bool canShutdown: typeof maysd === "undefined" || !!maysd
    readonly property bool canLogOut: typeof canLogout === "undefined" || !!canLogout

    // Icons ship per palette (a, b, light): pick light on a light colour scheme.
    readonly property string pal: Kirigami.ColorUtils.brightnessForColor(Kirigami.Theme.backgroundColor)
                                  === Kirigami.ColorUtils.Light ? "light" : "a"
    readonly property color accent: pal === "light" ? "#C8283D" : "#FF5468"
    readonly property color surface: pal === "light" ? "#FFFFFF" : "#121216"
    readonly property color band: pal === "light" ? "#F3EFE6" : "#0A0A0C"
    readonly property color edge: pal === "light" ? "#C9C2B4" : "#2A2A33"
    readonly property color textColor: pal === "light" ? "#141418" : "#ECE9E4"
    readonly property color dimText: pal === "light" ? "#6B665D" : "#9A98A3"
    readonly property string uiFont: "Chakra Petch"
    readonly property string monoFont: "IBM Plex Mono"

    // Only the title is ours; the action labels use KDE's own translations.
    readonly property bool pt: Qt.locale().name.indexOf("pt") === 0
    readonly property string title: pt ? "Desligar o computador" : "Turn off computer"
    function kde(text) { return i18nd("plasma_lookandfeel_org.kde.lookandfeel", text) }

    Keys.onEscapePressed: root.cancelRequested()

    // Dimmed screen behind the box; clicking it cancels, like Esc.
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.6
        MouseArea { anchors.fill: parent; onClicked: root.cancelRequested() }
    }

    Item {
        id: box
        readonly property real cut: 24
        width: 620
        height: 340
        anchors.centerIn: parent

        // Entry: a short fade, like the box powering on.
        opacity: 0
        Component.onCompleted: opacity = 1
        Behavior on opacity { NumberAnimation { duration: 160 } }

        Shape {
            anchors.fill: parent
            ShapePath {
                fillColor: root.surface; strokeColor: root.edge; strokeWidth: 2
                startX: 0; startY: 0
                PathLine { x: box.width - box.cut; y: 0 }
                PathLine { x: box.width; y: box.cut }
                PathLine { x: box.width; y: box.height }
                PathLine { x: box.cut; y: box.height }
                PathLine { x: 0; y: box.height - box.cut }
                PathLine { x: 0; y: 0 }
            }
            ShapePath {
                fillColor: "transparent"; strokeColor: root.accent; strokeWidth: 4
                startX: 0; startY: 0
                PathLine { x: box.width - box.cut; y: 0 }
                PathLine { x: box.width; y: box.cut }
            }
        }

        // Title band
        Rectangle {
            id: titleBand
            x: 2; y: 2; width: parent.width - box.cut - 2; height: 64
            color: root.band
            RowLayout {
                anchors { left: parent.left; leftMargin: 22; verticalCenter: parent.verticalCenter }
                spacing: 14
                Image {
                    source: "file:///usr/share/icons/hicolor/scalable/apps/oldnet.svg"
                    sourceSize: Qt.size(36, 36)
                    Layout.preferredWidth: 36; Layout.preferredHeight: 36
                }
                Text {
                    text: root.title
                    color: root.textColor
                    font { family: root.uiFont; pixelSize: 24; bold: true }
                }
            }
        }

        RowLayout {
            id: bigActions
            anchors { top: titleBand.bottom; topMargin: 30; horizontalCenter: parent.horizontalCenter }
            spacing: 44

            BigAction {
                art: "suspend"; label: root.kde("Sleep")
                visible: root.canSuspend
                onTriggered: root.suspendRequested(2)       // Solid SuspendState
            }
            BigAction {
                id: shutdownAction
                art: "shutdown"; label: root.kde("Shut Down")
                visible: root.canShutdown
                onTriggered: root.haltRequested()
            }
            BigAction {
                art: "restart"; label: root.kde("Restart")
                visible: root.canShutdown
                onTriggered: root.rebootRequested()
            }
        }

        RowLayout {
            anchors { left: parent.left; leftMargin: 24; bottom: parent.bottom; bottomMargin: 22 }
            spacing: 14
            SmallAction {
                art: "logout"; label: root.kde("Log Out")
                visible: root.canLogOut
                onTriggered: root.logoutRequested()
            }
            SmallAction {
                art: "switch-user"; label: root.kde("Lock")
                onTriggered: root.lockScreenRequested()
            }
        }

        Button {
            id: cancelButton
            anchors { right: parent.right; rightMargin: 28; bottom: parent.bottom; bottomMargin: 22 }
            text: root.kde("Cancel")
            font { family: root.uiFont; pixelSize: 16 }
            onClicked: root.cancelRequested()
            contentItem: Text {
                text: cancelButton.text; font: cancelButton.font; color: root.textColor
                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                implicitWidth: 120; implicitHeight: 40
                color: "transparent"
                border.color: cancelButton.activeFocus || cancelButton.hovered ? root.accent : root.edge
                border.width: 2
            }
        }
    }

    Component.onCompleted: shutdownAction.forceActiveFocus()

    // A big XP-style action: framed icon (normal/hover art per palette) and label below.
    component BigAction: AbstractButton {
        id: action
        property string art
        property string label
        signal triggered()
        hoverEnabled: true
        focusPolicy: Qt.StrongFocus
        Accessible.name: label
        onClicked: triggered()
        Keys.onReturnPressed: triggered()
        Keys.onEnterPressed: triggered()
        Keys.onSpacePressed: triggered()
        implicitWidth: 120
        implicitHeight: 150
        contentItem: ColumnLayout {
            spacing: 10
            Image {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 96; Layout.preferredHeight: 96
                sourceSize: Qt.size(96, 96)
                source: "file:///usr/share/oldnet/shutdown-screen/" + action.art + "-" + root.pal
                        + (action.hovered || action.activeFocus ? "-hover" : "-normal") + ".svg"
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: action.label
                color: action.hovered || action.activeFocus ? root.accent : root.textColor
                font { family: root.uiFont; pixelSize: 17; bold: true }
            }
        }
        background: Item {}
    }

    // A small action on the bottom line (log out, lock).
    component SmallAction: AbstractButton {
        id: small
        property string art
        property string label
        signal triggered()
        hoverEnabled: true
        focusPolicy: Qt.StrongFocus
        Accessible.name: label
        onClicked: triggered()
        Keys.onReturnPressed: triggered()
        Keys.onEnterPressed: triggered()
        contentItem: RowLayout {
            spacing: 8
            Image {
                Layout.preferredWidth: 28; Layout.preferredHeight: 28
                sourceSize: Qt.size(28, 28)
                source: "file:///usr/share/oldnet/shutdown-screen/" + small.art + "-" + root.pal
                        + (small.hovered || small.activeFocus ? "-hover" : "-normal") + ".svg"
            }
            Text {
                text: small.label
                color: small.hovered || small.activeFocus ? root.accent : root.dimText
                font { family: root.monoFont; pixelSize: 14 }
            }
        }
        background: Item {}
    }
}
