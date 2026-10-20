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

    // The background has two 150 px bands (accent lines at y=147 and y=930, mirrored).
    // Their contents are centred vertically in them.
    readonly property real band: 150 * s

    // Top band: name and clock
    Text {
        x: 80 * root.s
        anchors { verticalCenter: parent.top; verticalCenterOffset: root.band / 2 }
        text: "OLDNET OS"
        color: root.c.text
        font { family: root.uiFont; pixelSize: 34 * root.s; bold: true; letterSpacing: 6 * root.s }
    }
    Text {
        id: clock
        anchors { right: parent.right; rightMargin: 80 * root.s
                  verticalCenter: parent.top; verticalCenterOffset: root.band / 2 }
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
        readonly property real pad: 36 * root.s
        anchors { right: parent.right; rightMargin: 180 * root.s; verticalCenter: parent.verticalCenter }
        width: 680 * root.s
        height: form.implicitHeight + 2 * pad   // fits its content: no empty band in the middle
        transform: Translate { id: shake }       // moved by the login-failed animation

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

        // Login-failed flash: the whole chamfered outline lights up in the accent colour.
        Shape {
            id: flash
            anchors.fill: parent
            opacity: 0
            ShapePath {
                fillColor: "#10" + root.c.a1.substring(1)   // #AARRGGBB: accent at ~6% alpha
                strokeColor: root.c.a1; strokeWidth: 3 * root.s
                startX: 0; startY: 0
                PathLine { x: panel.width - panel.cut; y: 0 }
                PathLine { x: panel.width; y: panel.cut }
                PathLine { x: panel.width; y: panel.height }
                PathLine { x: panel.cut; y: panel.height }
                PathLine { x: 0; y: panel.height - panel.cut }
                PathLine { x: 0; y: 0 }
            }
        }
        // ...and a scan line sweeps down the panel.
        Rectangle {
            id: scan
            x: 0; width: panel.width; height: 2 * root.s
            color: root.c.a1
            opacity: 0
        }

        // One hidden item per user, so the picture can follow the selected user's icon role.
        Repeater {
            id: userIcons
            model: userModel
            delegate: Item {
                required property string icon
                readonly property string iconPath: icon
            }
        }

        ColumnLayout {
            id: form
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: panel.pad }
            spacing: 14 * root.s

            RowLayout {
                spacing: 20 * root.s

                // XP-style user picture. SDDM finds the image set in System Settings > Users
                // (AccountsService); without one, the user's initial is shown instead.
                Item {
                    id: avatar
                    readonly property real chamfer: 12 * root.s
                    readonly property var entry: userIcons.count > userBox.currentIndex
                                                 ? userIcons.itemAt(userBox.currentIndex) : null
                    Layout.preferredWidth: 132 * root.s
                    Layout.preferredHeight: 132 * root.s
                    Layout.alignment: Qt.AlignTop
                    Accessible.role: Accessible.Graphic
                    Accessible.name: userBox.currentText

                    // SDDM hands out its own dark default face (/usr/share/sddm/faces) when a
                    // user has no picture; that counts as "no picture" here.
                    readonly property string iconPath: entry ? String(entry.iconPath) : ""
                    readonly property bool hasPicture: iconPath !== ""
                                                       && iconPath.indexOf("/sddm/faces/") < 0
                                                       && face.status === Image.Ready

                    Rectangle { anchors { fill: parent; margins: 8 * root.s } color: root.c.bg }
                    Image {
                        id: face
                        anchors { fill: parent; margins: 8 * root.s }
                        source: avatar.iconPath.indexOf("/sddm/faces/") < 0 ? avatar.iconPath : ""
                        sourceSize: Qt.size(width, height)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: avatar.hasPicture
                    }
                    // No picture: a translucent white silhouette (head and shoulders).
                    Shape {
                        id: silhouette
                        visible: !avatar.hasPicture
                        anchors { fill: parent; margins: 8 * root.s }
                        readonly property real w: width
                        readonly property real h: height
                        ShapePath {
                            fillColor: "#59FFFFFF"   // white, ~35% opacity
                            strokeColor: "transparent"
                            // head
                            startX: silhouette.w * 0.5 + silhouette.w * 0.17; startY: silhouette.h * 0.36
                            PathArc {
                                x: silhouette.w * 0.5 - silhouette.w * 0.17; y: silhouette.h * 0.36
                                radiusX: silhouette.w * 0.17; radiusY: silhouette.w * 0.17
                            }
                            PathArc {
                                x: silhouette.w * 0.5 + silhouette.w * 0.17; y: silhouette.h * 0.36
                                radiusX: silhouette.w * 0.17; radiusY: silhouette.w * 0.17
                            }
                        }
                        ShapePath {
                            fillColor: "#59FFFFFF"
                            strokeColor: "transparent"
                            // shoulders, cut off by the frame's bottom edge
                            startX: silhouette.w * 0.14; startY: silhouette.h
                            PathCubic {
                                x: silhouette.w * 0.86; y: silhouette.h
                                control1X: silhouette.w * 0.14; control1Y: silhouette.h * 0.56
                                control2X: silhouette.w * 0.86; control2Y: silhouette.h * 0.56
                            }
                            PathLine { x: silhouette.w * 0.14; y: silhouette.h }
                        }
                    }
                    Shape {
                        anchors.fill: parent
                        ShapePath {
                            fillColor: "transparent"; strokeColor: root.c.a3; strokeWidth: 3 * root.s
                            joinStyle: ShapePath.MiterJoin
                            startX: 0; startY: 0
                            PathLine { x: avatar.width - avatar.chamfer; y: 0 }
                            PathLine { x: avatar.width; y: avatar.chamfer }
                            PathLine { x: avatar.width; y: avatar.height }
                            PathLine { x: avatar.chamfer; y: avatar.height }
                            PathLine { x: 0; y: avatar.height - avatar.chamfer }
                            PathLine { x: 0; y: 0 }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12 * root.s

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
                        // Caps Lock is inferred from the keys themselves: SDDM's keyboard.capsLock
                        // only works on X11 and this greeter runs on Wayland.
                        Keys.onPressed: (event) => {
                            root.trackCaps(event)
                            event.accepted = false   // let the field still receive the key
                        }
                        onTextChanged: if (text.length > 0) root.loginError = false
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
                }
            }
            // Message line: the login error (animated) or the Caps Lock warning. Height is fixed
            // so the panel does not jump when one appears.
            Item {
                id: alert
                Layout.fillWidth: true
                Layout.preferredHeight: 30 * root.s
                readonly property string errorText: root.txt("loginFailed").toUpperCase()
                property int shown: 0          // characters revealed (typewriter)
                property real ghost: 0         // strength of the cyan/coral glitch copies

                Row {
                    id: errorRow
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10 * root.s
                    // Hidden during the two bips; the bzzt sets ghost/shown and reveals it.
                    visible: root.loginError && (alert.shown > 0 || alert.ghost > 0)

                    Rectangle {
                        width: errTag.implicitWidth + 12 * root.s
                        height: errTag.implicitHeight + 4 * root.s
                        color: root.c.a1
                        Text {
                            id: errTag
                            anchors.centerIn: parent
                            text: "ERR"
                            color: root.c.bg
                            font { family: root.monoFont; pixelSize: 14 * root.s; bold: true }
                        }
                    }
                    Item {
                        width: errMain.implicitWidth; height: errMain.implicitHeight
                        readonly property string line: alert.errorText.substring(0, alert.shown)
                                                       + (alert.shown < alert.errorText.length ? "_" : "")
                        Text {   // glitch copy, cyan, pushed right
                            x: 3 * root.s * alert.ghost; text: parent.line; opacity: alert.ghost
                            color: root.c.a3; font: errMain.font
                        }
                        Text {   // glitch copy, accent, pushed left
                            x: -3 * root.s * alert.ghost; text: parent.line; opacity: alert.ghost
                            color: root.c.a2; font: errMain.font
                        }
                        Text {
                            id: errMain
                            text: parent.line
                            color: root.c.a1
                            font { family: root.monoFont; pixelSize: 18 * root.s; bold: true; letterSpacing: 2 * root.s }
                        }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !root.loginError && root.capsOn
                    text: "▲ " + root.txt("capslockWarning")
                    color: root.c.a1
                    font { family: root.monoFont; pixelSize: 16 * root.s }
                }
            }
            Button {
                id: loginButton
                Layout.alignment: Qt.AlignRight
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

    // Caps Lock, inferred from typed letters (Wayland greeter: keyboard.capsLock stays false).
    property bool capsOn: keyboard.capsLock
    function trackCaps(event) {
        if (event.key === Qt.Key_CapsLock) {
            capsOn = !capsOn
            return
        }
        const t = event.text
        if (t.length !== 1 || t.toUpperCase() === t.toLowerCase())
            return   // not a letter: tells nothing about Caps Lock
        const upper = t === t.toUpperCase()
        const shift = (event.modifiers & Qt.ShiftModifier) !== 0
        capsOn = upper !== shift
    }

    property bool loginError: false

    Connections {
        target: sddm
        function onLoginFailed() {
            password.text = ""
            root.loginError = true
            if (errorSound.item) errorSound.item.play()
            failAnim.restart()
            password.forceActiveFocus()
        }
    }

    // Login-failed sound; empty when QtMultimedia is missing.
    Loader { id: errorSound; source: "ErrorSound.qml" }

    // Login failed, timed to the sound (bip 0.00 s, bip 0.12 s, bzzt 0.26-0.45 s):
    // the outline pulses softly on each bip, then on the bzzt the panel jolts, flashes,
    // a scan line sweeps down and the message types itself in with a short glitch.
    readonly property int bzztAt: 260
    SequentialAnimation {
        id: failAnim
        // Start clean (a previous error may still be on screen); ERR appears on the bzzt.
        PropertyAction { target: alert; property: "shown"; value: 0 }
        PropertyAction { target: alert; property: "ghost"; value: 0 }
        // Two soft pulses, one per bip.
        NumberAnimation { target: flash; property: "opacity"; to: 0.45; duration: 25 }
        NumberAnimation { target: flash; property: "opacity"; to: 0; duration: 70 }
        PauseAnimation { duration: 25 }
        NumberAnimation { target: flash; property: "opacity"; to: 0.45; duration: 25 }
        NumberAnimation { target: flash; property: "opacity"; to: 0; duration: 70 }
        PauseAnimation { duration: root.bzztAt - 215 }
        // The bzzt: everything at once. The jolt (~0.25 s) spans the bzzt (0.26-0.45 s).
        ParallelAnimation {
            SequentialAnimation {
                NumberAnimation { target: shake; property: "x"; to: -14 * root.s; duration: 40 }
                NumberAnimation { target: shake; property: "x"; to: 12 * root.s; duration: 50 }
                NumberAnimation { target: shake; property: "x"; to: -8 * root.s; duration: 50 }
                NumberAnimation { target: shake; property: "x"; to: 5 * root.s; duration: 50 }
                NumberAnimation { target: shake; property: "x"; to: 0; duration: 60 }
            }
            SequentialAnimation {
                NumberAnimation { target: flash; property: "opacity"; to: 1; duration: 50 }
                NumberAnimation { target: flash; property: "opacity"; to: 0.25; duration: 70 }
                NumberAnimation { target: flash; property: "opacity"; to: 1; duration: 50 }
                NumberAnimation { target: flash; property: "opacity"; to: 0; duration: 450; easing.type: Easing.OutQuad }
            }
            SequentialAnimation {
                PropertyAction { target: scan; property: "opacity"; value: 0.9 }
                NumberAnimation { target: scan; property: "y"; from: 0; to: panel.height; duration: 320; easing.type: Easing.InOutQuad }
                PropertyAction { target: scan; property: "opacity"; value: 0 }
            }
            SequentialAnimation {
                PropertyAction { target: alert; property: "ghost"; value: 1 }
                NumberAnimation { target: alert; property: "shown"; from: 0; to: alert.errorText.length; duration: 300 }
                NumberAnimation { target: alert; property: "ghost"; to: 0.35; duration: 60 }
                NumberAnimation { target: alert; property: "ghost"; to: 0.8; duration: 60 }
                NumberAnimation { target: alert; property: "ghost"; to: 0; duration: 220 }
            }
        }
    }

    // Bottom band, right: power actions the system allows
    Row {
        anchors { right: parent.right; rightMargin: 80 * root.s
                  verticalCenter: parent.bottom; verticalCenterOffset: -root.band / 2 }
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
        anchors { verticalCenter: parent.bottom; verticalCenterOffset: -root.band / 2 }
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
