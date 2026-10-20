// OldNet SDDM theme (Qt 6 / SDDM 0.21). Context objects: sddm, userModel, sessionModel,
// keyboard, config. Laid out for 1920x1080 and scaled to the screen.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes

Rectangle {
    id: root

    readonly property var palettes: ({
        "a":     { bg: "#0A0A0C", surf: "#121216", edge: "#2A2A33", text: "#ECE9E4", dim: "#9A98A3", a1: "#FF5468", a2: "#3CF0B0", a3: "#3AD7E8", onA2: "#0A0A0C" },
        "b":     { bg: "#061416", surf: "#0B2226", edge: "#12363C", text: "#DFF7F9", dim: "#8FB3B8", a1: "#E3A83B", a2: "#7EF0FF", a3: "#3AD7E8", onA2: "#061416" },
        "light": { bg: "#F3EFE6", surf: "#FFFFFF", edge: "#C9C2B4", text: "#141418", dim: "#6B665D", a1: "#C8283D", a2: "#0A7F63", a3: "#0B6F80", onA2: "#FFFFFF" }
    })
    readonly property string pal: (config.palette && palettes[config.palette]) ? config.palette : "a"
    readonly property var c: palettes[pal]
    // 1 at 1920x1080; smaller screens (Steam Deck 1280x800) shrink everything evenly.
    readonly property real s: Math.min(width / 1920, height / 1080)
    readonly property string uiFont: "Chakra Petch"
    readonly property string monoFont: "IBM Plex Mono"

    // SDDM's translated strings live in SddmComponents' TextConstants, which a theme has to
    // create itself (it is not a context object). Created dynamically so a missing module
    // only drops translations; English fallbacks keep every label filled.
    readonly property var sddmText: {
        try {
            return Qt.createQmlObject("import SddmComponents 2.0; TextConstants {}", root, "TextConstants")
        } catch (e) {
            console.log("OldNet theme: SddmComponents unavailable, using English texts")
            return null
        }
    }
    readonly property var fallbackText: ({
        welcomeText: "Welcome to %1", promptSelectUser: "Select your user and enter password",
        userName: "User name", password: "Password", session: "Session",
        capslockWarning: "Caps Lock is on", login: "Log in", loginFailed: "Login failed",
        suspend: "Suspend", reboot: "Restart", shutdown: "Shut down"
    })
    function txt(key) {
        return (sddmText && sddmText[key]) ? sddmText[key] : fallbackText[key]
    }

    width: 1920
    height: 1080
    color: c.bg

    Image {
        anchors.fill: parent
        source: "backgrounds/background-" + root.pal + "-3840x2160.png"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    // Top bar: name and clock, kept inside the band above the background's accent line (y≈64)
    Text {
        x: 80 * root.s; y: 12 * root.s
        text: "OLDNET OS"
        color: root.c.text
        font { family: root.uiFont; pixelSize: 34 * root.s; bold: true; letterSpacing: 6 * root.s }
    }
    Text {
        id: clock
        anchors { right: parent.right; rightMargin: 80 * root.s }
        y: 16 * root.s
        color: root.c.a2
        font { family: root.monoFont; pixelSize: 26 * root.s }
        text: Qt.formatTime(new Date(), "hh:mm")
        Timer {
            interval: 1000; running: true; repeat: true
            onTriggered: clock.text = Qt.formatTime(new Date(), "hh:mm")
        }
    }

    // Left: greeting
    Column {
        anchors { left: parent.left; leftMargin: 140 * root.s; verticalCenter: parent.verticalCenter }
        width: panel.x - anchors.leftMargin - 60 * root.s
        spacing: 14 * root.s
        Text {
            width: parent.width
            text: root.txt("welcomeText").arg(sddm.hostName)
            color: root.c.text
            elide: Text.ElideRight
            font { family: root.uiFont; pixelSize: 56 * root.s; bold: true }
        }
        Text {
            width: parent.width
            text: root.txt("promptSelectUser").toUpperCase()
            color: root.c.dim
            wrapMode: Text.Wrap
            font { family: root.monoFont; pixelSize: 20 * root.s; letterSpacing: 3 * root.s }
        }
        Rectangle { width: 260 * root.s; height: 4 * root.s; color: root.c.a1 }
    }

    // Right: chamfered login panel
    Item {
        id: panel
        readonly property real cut: 40 * root.s
        anchors { right: parent.right; rightMargin: 180 * root.s; verticalCenter: parent.verticalCenter }
        width: 600 * root.s
        height: 480 * root.s

        Shape {
            anchors.fill: parent
            ShapePath {
                fillColor: root.c.surf; strokeColor: root.c.edge; strokeWidth: 2
                startX: 0; startY: 0
                PathLine { x: panel.width - panel.cut; y: 0 }
                PathLine { x: panel.width; y: panel.cut }
                PathLine { x: panel.width; y: panel.height }
                PathLine { x: panel.cut; y: panel.height }
                PathLine { x: 0; y: panel.height - panel.cut }
                PathLine { x: 0; y: 0 }
            }
            ShapePath {
                fillColor: "transparent"; strokeColor: root.c.a1; strokeWidth: 4 * root.s
                startX: 0; startY: 0
                PathLine { x: panel.width - panel.cut; y: 0 }
                PathLine { x: panel.width; y: panel.cut }
            }
        }

        ColumnLayout {
            anchors { fill: parent; margins: 48 * root.s }
            spacing: 16 * root.s

            HudCombo {
                id: userBox
                Layout.fillWidth: true
                model: userModel
                textRole: "name"
                currentIndex: userModel.lastIndex
                font { family: root.uiFont; pixelSize: 24 * root.s }
                Accessible.name: root.txt("userName")
            }
            TextField {
                id: password
                Layout.fillWidth: true
                echoMode: TextInput.Password
                placeholderText: root.txt("password")
                placeholderTextColor: root.c.dim
                color: root.c.a3
                selectionColor: root.c.a3
                selectedTextColor: root.c.bg
                font { family: root.monoFont; pixelSize: 20 * root.s }
                padding: 12 * root.s
                focus: true
                Keys.onReturnPressed: root.doLogin()
                Keys.onEnterPressed: root.doLogin()
                background: Rectangle {
                    color: root.c.bg
                    border.color: password.activeFocus ? root.c.a3 : root.c.edge
                    border.width: 2
                }
            }
            HudCombo {
                id: sessionBox
                Layout.fillWidth: true
                model: sessionModel
                textRole: "name"
                currentIndex: sessionModel.lastIndex
                font { family: root.monoFont; pixelSize: 16 * root.s }
                Accessible.name: root.txt("session")
                // theme.conf defaultSession (set on desktop images): pick it until someone has
                // logged in once; after that SDDM's remembered session is respected.
                Component.onCompleted: {
                    if (config.defaultSession && !userModel.lastUser) {
                        const i = find(config.defaultSession, Qt.MatchStartsWith)
                        if (i >= 0) currentIndex = i
                    }
                }
            }
            Text {
                id: message
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                color: root.c.a1
                font { family: root.monoFont; pixelSize: 16 * root.s }
                text: keyboard.capsLock ? root.txt("capslockWarning") : ""
            }
            Item { Layout.fillHeight: true }
            Button {
                id: loginButton
                Layout.preferredWidth: 260 * root.s
                Layout.preferredHeight: 56 * root.s
                text: root.txt("login").toUpperCase()
                font { family: root.uiFont; pixelSize: 24 * root.s; bold: true }
                onClicked: root.doLogin()
                contentItem: Text {
                    text: loginButton.text; font: loginButton.font; color: root.c.onA2
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: root.c.a2
                    border.color: root.c.text
                    border.width: loginButton.activeFocus ? 2 : 0
                }
            }
        }
    }

    function doLogin() {
        sddm.login(userBox.currentText, password.text, sessionBox.currentIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            message.text = root.txt("loginFailed")
            password.text = ""
            password.forceActiveFocus()
        }
    }

    // Bottom right: power actions the system allows
    Row {
        anchors { right: parent.right; rightMargin: 80 * root.s; bottom: parent.bottom; bottomMargin: 20 * root.s }
        spacing: 24 * root.s
        Repeater {
            model: [
                { k: "suspend",  label: root.txt("suspend"),  allowed: sddm.canSuspend },
                { k: "restart",  label: root.txt("reboot"),   allowed: sddm.canReboot },
                { k: "shutdown", label: root.txt("shutdown"), allowed: sddm.canPowerOff }
            ]
            delegate: AbstractButton {
                required property var modelData
                visible: modelData.allowed
                width: 64 * root.s; height: 64 * root.s
                hoverEnabled: true
                Accessible.name: modelData.label
                contentItem: Image {
                    sourceSize: Qt.size(width, height)
                    source: "assets/" + modelData.k + "-" + root.pal
                            + (parent.hovered || parent.activeFocus ? "-hover" : "-normal") + ".svg"
                }
                onClicked: {
                    if (modelData.k === "suspend") sddm.suspend()
                    else if (modelData.k === "restart") sddm.reboot()
                    else sddm.powerOff()
                }
            }
        }
    }
    Text {
        x: 80 * root.s
        anchors { bottom: parent.bottom; bottomMargin: 40 * root.s }
        text: "BASED ON BAZZITE"
        color: root.c.dim
        font { family: root.monoFont; pixelSize: 16 * root.s; letterSpacing: 3 * root.s }
    }

    // On-screen keyboard (Bazzite deck sets InputMethod=qtvirtualkeyboard). If the
    // module is missing the Loader just stays empty.
    Loader {
        id: virtualKeyboard
        source: "VirtualKeyboard.qml"
        width: Math.min(parent.width, 1400 * root.s)
        anchors.horizontalCenter: parent.horizontalCenter
        y: Qt.inputMethod.visible ? parent.height - height : parent.height
        visible: status === Loader.Ready && Qt.inputMethod.visible
        z: 10
        Behavior on y { NumberAnimation { duration: 150 } }
    }

    Component.onCompleted: password.forceActiveFocus()

    // Combo box drawn in the palette (the default style is light and clashes)
    component HudCombo: ComboBox {
        id: combo
        padding: 10 * root.s
        contentItem: Text {
            leftPadding: 4 * root.s
            text: combo.displayText
            font: combo.font
            color: root.c.text
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        indicator: Text {
            x: combo.width - width - combo.padding
            anchors.verticalCenter: combo.verticalCenter
            text: "▾"
            color: root.c.a3
            font.pixelSize: combo.font.pixelSize
        }
        background: Rectangle {
            color: root.c.bg
            border.color: combo.activeFocus ? root.c.a3 : root.c.edge
            border.width: 2
        }
        delegate: ItemDelegate {
            required property var model
            required property int index
            width: combo.width
            highlighted: combo.highlightedIndex === index
            contentItem: Text {
                text: model[combo.textRole]
                font: combo.font
                color: highlighted ? root.c.bg : root.c.text
                elide: Text.ElideRight
            }
            background: Rectangle { color: highlighted ? root.c.a3 : root.c.surf }
        }
        popup: Popup {
            y: combo.height
            width: combo.width
            padding: 2
            implicitHeight: Math.min(contentItem.implicitHeight + 4, 300 * root.s)
            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: combo.popup.visible ? combo.delegateModel : null
                currentIndex: combo.highlightedIndex
            }
            background: Rectangle { color: root.c.surf; border.color: root.c.a3; border.width: 1 }
        }
    }
}
