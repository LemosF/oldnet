import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

// One tab: chamfered right edge, accent stripe on top when active (as in the mockup).
Item {
    id: tab

    property int number: 1
    property string label
    property string iconName
    property bool active: false
    property int windows: 0
    property bool showWindowCount: true

    signal activated()

    readonly property real slant: Math.round(height * 0.6)
    readonly property string monoFamily: "IBM Plex Mono"

    implicitWidth: content.implicitWidth + Kirigami.Units.largeSpacing * 2 + slant
    Layout.fillHeight: true

    Accessible.role: Accessible.PageTab
    Accessible.name: label
    Accessible.description: number <= 5 ? i18n("Meta+%1", number) : ""
    Accessible.onPressAction: tab.activated()

    Shape {
        anchors.fill: parent
        ShapePath {
            strokeWidth: 1
            strokeColor: tab.active ? Qt.alpha(Kirigami.Theme.highlightColor, 0.6)
                                    : Qt.alpha(Kirigami.Theme.textColor, 0.12)
            fillColor: tab.active ? Qt.alpha(Kirigami.Theme.highlightColor, 0.16)
                     : mouse.containsMouse ? Qt.alpha(Kirigami.Theme.textColor, 0.07)
                     : "transparent"
            startX: 0; startY: 0
            PathLine { x: tab.width - tab.slant; y: 0 }
            PathLine { x: tab.width; y: tab.height }
            PathLine { x: 0; y: tab.height }
            PathLine { x: 0; y: 0 }
        }
    }

    Rectangle {
        visible: tab.active
        anchors { left: parent.left; top: parent.top }
        width: parent.width - tab.slant
        height: 2
        color: Kirigami.Theme.activeTextColor // palette accent (coral in Night Market)
    }

    RowLayout {
        id: content
        anchors.verticalCenter: parent.verticalCenter
        x: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            visible: tab.iconName !== "" && tab.iconName !== "none"
            source: tab.iconName
            Layout.preferredWidth: Kirigami.Units.iconSizes.small
            Layout.preferredHeight: Kirigami.Units.iconSizes.small
        }
        PlasmaComponents.Label {
            text: String(tab.number).padStart(2, "0")
            font.family: tab.monoFamily
            color: tab.active ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
        }
        PlasmaComponents.Label {
            text: tab.label.toUpperCase()
            font.family: tab.monoFamily
            font.letterSpacing: 1
            font.weight: tab.active ? Font.DemiBold : Font.Normal
        }
        PlasmaComponents.Label {
            visible: tab.showWindowCount && !tab.active && tab.windows > 0
            text: "[" + tab.windows + "]"
            font.family: tab.monoFamily
            color: Kirigami.Theme.positiveTextColor // mint
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: tab.activated()
    }
}
