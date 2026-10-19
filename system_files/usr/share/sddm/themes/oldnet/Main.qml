// OldNet SDDM theme (NAO TESTADO). Qt6/SDDM 0.21. Contexto: sddm, userModel, sessionModel, config.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes

Rectangle {
    id: root
    width: 1920
    height: 1080

    readonly property var palettes: ({
        "a":     { bg: "#0A0A0C", surf: "#121216", edge: "#2A2A33", text: "#ECE9E4", dim: "#9A98A3", a1: "#FF5468", a2: "#3CF0B0", a3: "#3AD7E8", onA2: "#0A0A0C" },
        "b":     { bg: "#061416", surf: "#0B2226", edge: "#12363C", text: "#DFF7F9", dim: "#5E8A90", a1: "#E3A83B", a2: "#7EF0FF", a3: "#3AD7E8", onA2: "#061416" },
        "light": { bg: "#F3EFE6", surf: "#FFFFFF", edge: "#C9C2B4", text: "#141418", dim: "#6B665D", a1: "#C8283D", a2: "#0A7F63", a3: "#0B6F80", onA2: "#FFFFFF" }
    })
    readonly property string pal: (config.palette && palettes[config.palette]) ? config.palette : "a"
    readonly property var c: palettes[pal]
    color: c.bg

    Image {
        anchors.fill: parent
        source: "backgrounds/background-" + root.pal + "-3840x2160.png"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    // barra superior
    Item {
        id: topBar
        width: parent.width; height: 110
        Text { x: 80; anchors.verticalCenter: parent.verticalCenter; text: "OLDNET OS"; color: root.c.text
               font.family: "Chakra Petch"; font.pixelSize: 34; font.bold: true; font.letterSpacing: 6 }
        Text { id: clock; anchors.right: parent.right; anchors.rightMargin: 80; anchors.verticalCenter: parent.verticalCenter
               color: root.c.a2; font.family: "IBM Plex Mono"; font.pixelSize: 26
               text: Qt.formatTime(new Date(), "hh:mm") }
        Timer { interval: 1000; running: true; repeat: true; onTriggered: clock.text = Qt.formatTime(new Date(), "hh:mm") }
    }

    Column {
        x: 140; y: 400; spacing: 14
        Text { text: "Bem-vindo"; color: root.c.text; font.family: "Chakra Petch"; font.pixelSize: 76; font.bold: true }
        Text { text: "ESCOLHE UM UTILIZADOR PARA ENTRAR"; color: root.c.dim; font.family: "IBM Plex Mono"; font.pixelSize: 22; font.letterSpacing: 3 }
        Rectangle { width: 260; height: 4; color: root.c.a1 }
    }

    // painel de login (chanfrado)
    Item {
        id: panel
        x: parent.width - 700 - 180; y: 290; width: 600; height: 480
        Shape {
            anchors.fill: parent
            ShapePath {
                fillColor: root.c.surf; strokeColor: root.c.edge; strokeWidth: 2
                startX: 0; startY: 0
                PathLine { x: 560; y: 0 } PathLine { x: 600; y: 40 } PathLine { x: 600; y: 480 }
                PathLine { x: 40; y: 480 } PathLine { x: 0; y: 440 } PathLine { x: 0; y: 0 }
            }
            ShapePath {
                fillColor: "transparent"; strokeColor: root.c.a1; strokeWidth: 4
                startX: 0; startY: 0
                PathLine { x: 560; y: 0 } PathLine { x: 600; y: 40 }
            }
        }
        ColumnLayout {
            anchors { fill: parent; margins: 48 }
            spacing: 16
            ComboBox {
                id: userBox
                Layout.fillWidth: true
                model: userModel
                textRole: "name"
                currentIndex: userModel.lastIndex
                font.family: "Chakra Petch"; font.pixelSize: 24
            }
            TextField {
                id: password
                Layout.fillWidth: true
                echoMode: TextInput.Password
                placeholderText: "Palavra-passe"
                font.family: "IBM Plex Mono"; font.pixelSize: 20
                color: root.c.a3
                focus: true
                Keys.onReturnPressed: doLogin()
                Keys.onEnterPressed: doLogin()
                background: Rectangle { color: root.c.bg; border.color: root.c.a3; border.width: 2 }
            }
            ComboBox {
                id: sessionBox
                Layout.fillWidth: true
                model: sessionModel
                textRole: "name"
                currentIndex: sessionModel.lastIndex
                font.family: "IBM Plex Mono"; font.pixelSize: 16
            }
            Text { id: err; color: root.c.a1; font.family: "IBM Plex Mono"; font.pixelSize: 16; text: "" }
            Item { Layout.fillHeight: true }
            Button {
                Layout.preferredWidth: 260; Layout.preferredHeight: 56
                text: "ENTRAR"
                font.family: "Chakra Petch"; font.pixelSize: 24; font.bold: true
                onClicked: doLogin()
                contentItem: Text { text: parent.text; font: parent.font; color: root.c.onA2; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                background: Rectangle { color: root.c.a2 }
            }
        }
    }

    function doLogin() {
        err.text = ""
        sddm.login(userBox.currentText, password.text, sessionBox.currentIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() { err.text = "Falha no inicio de sessao"; password.text = ""; password.forceActiveFocus() }
    }

    // rodape: energia
    Row {
        anchors { right: parent.right; rightMargin: 80; bottom: parent.bottom; bottomMargin: 20 }
        spacing: 24
        Repeater {
            model: [ { k: "suspend", f: function() { sddm.suspend() } },
                     { k: "restart", f: function() { sddm.reboot() } },
                     { k: "shutdown", f: function() { sddm.powerOff() } } ]
            delegate: Image {
                width: 64; height: 64
                source: "assets/" + modelData.k + "-" + root.pal + (ma.containsMouse ? "-hover" : "-normal") + ".svg"
                MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: modelData.f() }
            }
        }
    }
    Text { x: 80; anchors.bottom: parent.bottom; anchors.bottomMargin: 40; text: "BASEADO NO BAZZITE"; color: root.c.dim
           font.family: "IBM Plex Mono"; font.pixelSize: 16; font.letterSpacing: 3 }
}
