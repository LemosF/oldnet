// OldNet welcome app: four steps (welcome, appearance, packs, tabs) in the OldNet skin.
// Context objects from main.py: backend (palette, packs, start-up flag), dataDir.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Window

ApplicationWindow {
    id: win
    width: 1000
    height: 680
    minimumWidth: 860
    minimumHeight: 600
    visible: true
    title: t("title")
    color: c.bg

    // Night Market colours for the app itself (it is the first thing a user sees).
    readonly property var c: ({ bg: "#0A0A0C", surf: "#121216", raised: "#1C1C22", edge: "#2A2A33",
                                text: "#ECE9E4", dim: "#9A98A3", a1: "#FF5468", a2: "#3CF0B0",
                                a3: "#3AD7E8", onA2: "#0A0A0C" })
    readonly property string uiFont: "Chakra Petch"
    readonly property string monoFont: "IBM Plex Mono"
    property int step: 0
    property string palette: "NightMarket"

    // --- texts (pt / en)
    readonly property bool pt: Qt.locale().name.indexOf("pt") === 0
    readonly property var texts: ({
        title:      ["Bem-vindo ao OldNet OS", "Welcome to OldNet OS"],
        s0:         ["BEM-VINDO", "WELCOME"], s1: ["ASPETO", "LOOK"], s2: ["PACKS", "PACKS"], s3: ["TABS", "TABS"],
        intro1:     ["Liga-te. O OldNet junta a estrutura familiar do Windows XP a uma pele cyberpunk sóbria, sobre a base do Bazzite: jogos, desenvolvimento, streaming e família no mesmo sistema.",
                     "Jack in. OldNet blends the familiar layout of Windows XP with a restrained cyberpunk skin, on top of Bazzite: games, development, streaming and family on one system."],
        intro2:     ["Em quatro passos escolhes o aspeto, instalas apps extra e conheces as tabs.",
                     "In four steps you pick a look, install extra apps and meet the tabs."],
        start:      ["COMEÇAR", "START"], next: ["SEGUINTE", "NEXT"], back: ["VOLTAR", "BACK"], finish: ["TERMINAR", "FINISH"],
        lookTitle:  ["Escolhe a tua paleta", "Pick your palette"],
        lookNote:   ["Muda as cores, as janelas, os ícones e o terminal. Podes voltar a mudar aqui ou nas Definições.",
                     "Changes colours, windows, icons and the terminal. You can change it again here or in Settings."],
        applied:    ["Aplicada", "Applied"],
        packsTitle: ["Packs de apps", "App packs"],
        packsNote:  ["Instaladas a partir do Flathub. O sistema pode pedir a tua password.",
                     "Installed from Flathub. The system may ask for your password."],
        install:    ["INSTALAR", "INSTALL"], installing: ["A INSTALAR…", "INSTALLING…"],
        installed:  ["INSTALADO", "INSTALLED"], failed: ["FALHOU — TENTAR DE NOVO", "FAILED — TRY AGAIN"],
        tabsTitle:  ["As tabs do OldNet", "The OldNet tabs"],
        tabsNote:   ["Cada tab é um ambiente próprio, com as suas janelas. Muda com um clique na barra de cima ou com Meta + número.",
                     "Each tab is its own space with its own windows. Switch with a click on the top bar or with Meta + number."],
        tDesktop:   ["O teu ambiente de trabalho, com a barra de tarefas.", "Your desktop, with the taskbar."],
        tMail:      ["O email ocupa a tab inteira.", "Email fills the whole tab."],
        tMessages:  ["As mensagens (Matrix) ocupam a tab inteira.", "Messages (Matrix) fill the whole tab."],
        tGames:     ["Os teus jogos e o Steam.", "Your games and Steam."],
        tCode:      ["Desenvolvimento.", "Development."],
        showStart:  ["Mostrar esta janela no arranque", "Show this window at start-up"]
    })
    function t(key) { return texts[key] ? texts[key][pt ? 0 : 1] : key }
    function loc(obj) { return obj ? (pt ? obj.pt : obj.en) : "" }

    // --- install state per pack: "", "installing", "installed", "failed"
    property var packState: ({})
    property string lastLine: ""
    Connections {
        target: backend
        function onInstallOutput(line) { win.lastLine = line }
        function onInstallFinished(packId, ok) {
            const s = Object.assign({}, win.packState); s[packId] = ok ? "installed" : "failed"
            win.packState = s
        }
    }

    // --- layout: step strip, page, footer
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Step strip (like the OldNet tab bar)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            color: c.surf
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 2; color: c.a1 }
            RowLayout {
                anchors { left: parent.left; leftMargin: 24; verticalCenter: parent.verticalCenter }
                spacing: 8
                Image {
                    source: "file:///usr/share/icons/hicolor/scalable/apps/oldnet.svg"
                    sourceSize: Qt.size(30, 30)
                    Layout.preferredWidth: 30; Layout.preferredHeight: 30
                    Layout.rightMargin: 12
                }
                Repeater {
                    model: ["s0", "s1", "s2", "s3"]
                    delegate: Item {
                        id: stepTab
                        required property string modelData
                        required property int index
                        readonly property bool current: index === win.step
                        implicitWidth: stepLabel.implicitWidth + 40
                        implicitHeight: 38
                        Shape {
                            anchors.fill: parent
                            ShapePath {
                                fillColor: current ? Qt.alpha(c.a3, 0.16) : "transparent"
                                strokeColor: current ? Qt.alpha(c.a3, 0.7) : c.edge; strokeWidth: 1
                                startX: 0; startY: 0
                                PathLine { x: stepTab.width - 14; y: 0 }
                                PathLine { x: stepTab.width; y: stepTab.height }
                                PathLine { x: 0; y: stepTab.height }
                                PathLine { x: 0; y: 0 }
                            }
                        }
                        Text {
                            id: stepLabel
                            anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                            text: "0" + (index + 1) + " " + win.t(modelData)
                            color: current ? c.a3 : c.dim
                            font { family: win.monoFont; pixelSize: 14; letterSpacing: 1; bold: current }
                        }
                    }
                }
            }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: win.step

            // 01 Welcome
            Item {
                Image {
                    id: header
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    height: width / 4
                    source: dataDir + "/header-a-1920x480.png"
                    fillMode: Image.PreserveAspectCrop
                }
                ColumnLayout {
                    anchors { top: header.bottom; left: parent.left; right: parent.right; margins: 48 }
                    spacing: 18
                    Text {
                        text: win.t("title"); color: c.text
                        font { family: win.uiFont; pixelSize: 36; bold: true }
                    }
                    Rectangle { width: 180; height: 3; color: c.a1 }
                    Text {
                        Layout.fillWidth: true; wrapMode: Text.Wrap
                        text: win.t("intro1"); color: c.text; lineHeight: 1.3
                        font { family: win.uiFont; pixelSize: 17 }
                    }
                    Text {
                        Layout.fillWidth: true; wrapMode: Text.Wrap
                        text: win.t("intro2"); color: c.dim
                        font { family: win.monoFont; pixelSize: 14 }
                    }
                }
            }

            // 02 Appearance
            ColumnLayout {
                spacing: 16
                Item { Layout.preferredHeight: 20 }
                PageTitle { text: win.t("lookTitle"); note: win.t("lookNote") }
                RowLayout {
                    Layout.leftMargin: 48; Layout.rightMargin: 48
                    spacing: 20
                    Repeater {
                        model: [
                            { id: "NightMarket", name: "Night Market", sw: ["#0A0A0C", "#121216", "#FF5468", "#3CF0B0", "#3AD7E8", "#ECE9E4"] },
                            { id: "HoloTablet", name: "Holo Tablet", sw: ["#061416", "#0B2226", "#3AD7E8", "#E3A83B", "#7EF0FF", "#DFF7F9"] },
                            { id: "Daylight", name: "Daylight", sw: ["#F3EFE6", "#FFFFFF", "#C8283D", "#0A7F63", "#0B6F80", "#141418"] }
                        ]
                        delegate: Card {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 170
                            selected: win.palette === modelData.id
                            onClicked: { win.palette = modelData.id; backend.applyPalette(modelData.id) }
                            ColumnLayout {
                                anchors { fill: parent; margins: 18 }
                                spacing: 12
                                Text {
                                    text: modelData.name; color: c.text
                                    font { family: win.uiFont; pixelSize: 19; bold: true }
                                }
                                RowLayout {
                                    spacing: 0
                                    Repeater {
                                        model: modelData.sw
                                        delegate: Rectangle {
                                            required property string modelData
                                            Layout.fillWidth: true; Layout.preferredHeight: 44
                                            color: modelData
                                        }
                                    }
                                }
                                Text {
                                    visible: win.palette === modelData.id
                                    text: "● " + win.t("applied"); color: c.a2
                                    font { family: win.monoFont; pixelSize: 13 }
                                }
                            }
                        }
                    }
                }
                Item { Layout.fillHeight: true }
            }

            // 03 Packs
            ColumnLayout {
                spacing: 16
                Item { Layout.preferredHeight: 20 }
                PageTitle { text: win.t("packsTitle"); note: win.t("packsNote") }
                GridLayout {
                    Layout.leftMargin: 48; Layout.rightMargin: 48
                    columns: 2; rowSpacing: 16; columnSpacing: 16
                    Repeater {
                        model: backend.packs
                        delegate: Card {
                            id: packCard
                            required property var modelData
                            readonly property string state_: win.packState[modelData.id] || ""
                            Layout.fillWidth: true
                            Layout.preferredHeight: 150
                            hoverable: false
                            RowLayout {
                                anchors { fill: parent; margins: 16 }
                                spacing: 16
                                Image {
                                    source: "file:///usr/share/icons/OldNet/scalable/apps/" + packCard.modelData.icon + ".svg"
                                    sourceSize: Qt.size(64, 64)
                                    Layout.preferredWidth: 64; Layout.preferredHeight: 64
                                    Layout.alignment: Qt.AlignTop
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    Text {
                                        text: win.loc(packCard.modelData.name); color: c.text
                                        font { family: win.uiFont; pixelSize: 18; bold: true }
                                    }
                                    Text {
                                        Layout.fillWidth: true; wrapMode: Text.Wrap
                                        text: win.loc(packCard.modelData.description); color: c.dim
                                        font { family: win.uiFont; pixelSize: 13 }
                                    }
                                    Text {
                                        Layout.fillWidth: true; elide: Text.ElideRight
                                        text: packCard.modelData.apps.map(a => a.name).join(" · "); color: c.a3
                                        font { family: win.monoFont; pixelSize: 12 }
                                    }
                                    Item { Layout.fillHeight: true }
                                    HudButton {
                                        text: packCard.state_ === "installing" ? win.t("installing")
                                              : packCard.state_ === "installed" ? "✓ " + win.t("installed")
                                              : packCard.state_ === "failed" ? win.t("failed") : win.t("install")
                                        enabled: packCard.state_ !== "installing" && packCard.state_ !== "installed"
                                                 && !win.anyInstalling
                                        primary: packCard.state_ !== "installed"
                                        onClicked: {
                                            const s = Object.assign({}, win.packState)
                                            s[packCard.modelData.id] = "installing"
                                            win.packState = s
                                            backend.installPack(packCard.modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                Text {
                    Layout.leftMargin: 48; Layout.rightMargin: 48; Layout.fillWidth: true
                    visible: win.anyInstalling
                    elide: Text.ElideRight
                    text: "> " + win.lastLine; color: c.dim
                    font { family: win.monoFont; pixelSize: 12 }
                }
                Item { Layout.fillHeight: true }
            }

            // 04 Tabs
            ColumnLayout {
                spacing: 16
                Item { Layout.preferredHeight: 20 }
                PageTitle { text: win.t("tabsTitle"); note: win.t("tabsNote") }
                Repeater {
                    model: [["DESKTOP", "tDesktop"], ["MAIL", "tMail"], ["MESSAGES", "tMessages"],
                            ["GAMES", "tGames"], ["CODE", "tCode"]]
                    delegate: RowLayout {
                        required property var modelData
                        required property int index
                        Layout.leftMargin: 48; Layout.rightMargin: 48
                        spacing: 16
                        Text {
                            Layout.preferredWidth: 90
                            text: "META+" + (index + 1); color: c.a3
                            font { family: win.monoFont; pixelSize: 14; bold: true }
                        }
                        Text {
                            Layout.preferredWidth: 150
                            text: "0" + (index + 1) + " " + modelData[0]; color: c.text
                            font { family: win.monoFont; pixelSize: 15; letterSpacing: 1 }
                        }
                        Text {
                            Layout.fillWidth: true; wrapMode: Text.Wrap
                            text: win.t(modelData[1]); color: c.dim
                            font { family: win.uiFont; pixelSize: 15 }
                        }
                    }
                }
                Item { Layout.fillHeight: true }
                CheckBox {
                    id: showCheck
                    Layout.leftMargin: 44
                    checked: backend.showAtStartup
                    onToggled: backend.showAtStartup = checked
                    contentItem: Text {
                        leftPadding: showCheck.indicator.width + 8
                        text: win.t("showStart"); color: c.text
                        font { family: win.uiFont; pixelSize: 14 }
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        // Footer: back / next
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 76
            color: c.surf
            Rectangle { width: parent.width; height: 1; color: c.edge }
            RowLayout {
                anchors { fill: parent; leftMargin: 24; rightMargin: 24 }
                Text {
                    text: "OLDNET OS · BASED ON BAZZITE"; color: c.dim
                    font { family: win.monoFont; pixelSize: 12; letterSpacing: 2 }
                }
                Item { Layout.fillWidth: true }
                HudButton {
                    visible: win.step > 0
                    text: win.t("back"); primary: false
                    onClicked: win.step--
                }
                HudButton {
                    text: win.step === 0 ? win.t("start") : win.step === 3 ? win.t("finish") : win.t("next")
                    onClicked: {
                        if (win.step === 3) {
                            backend.showAtStartup = showCheck.checked
                            Qt.quit()
                        } else {
                            win.step++
                        }
                    }
                }
            }
        }
    }

    readonly property bool anyInstalling: Object.values(packState).indexOf("installing") >= 0

    // --- components
    component PageTitle: ColumnLayout {
        property alias text: titleText.text
        property alias note: noteText.text
        Layout.leftMargin: 48; Layout.rightMargin: 48
        spacing: 8
        Text {
            id: titleText; color: win.c.text
            font { family: win.uiFont; pixelSize: 28; bold: true }
        }
        Rectangle { width: 120; height: 3; color: win.c.a1 }
        Text {
            id: noteText
            Layout.fillWidth: true; wrapMode: Text.Wrap; color: win.c.dim
            font { family: win.uiFont; pixelSize: 14 }
        }
    }

    // A chamfered card (top-left and bottom-right corners), selectable.
    component Card: AbstractButton {
        id: card
        property bool selected: false
        property bool hoverable: true
        readonly property real cut: 14
        hoverEnabled: hoverable
        background: Shape {
            ShapePath {
                fillColor: win.c.surf
                strokeColor: card.selected ? win.c.a3 : (card.hovered ? win.c.dim : win.c.edge)
                strokeWidth: card.selected ? 2 : 1
                startX: card.cut; startY: 0
                PathLine { x: card.width; y: 0 }
                PathLine { x: card.width; y: card.height - card.cut }
                PathLine { x: card.width - card.cut; y: card.height }
                PathLine { x: 0; y: card.height }
                PathLine { x: 0; y: card.cut }
                PathLine { x: card.cut; y: 0 }
            }
        }
    }

    component HudButton: Button {
        id: btn
        property bool primary: true
        implicitHeight: 42
        leftPadding: 22; rightPadding: 22
        font { family: win.uiFont; pixelSize: 15; bold: true; letterSpacing: 1 }
        contentItem: Text {
            text: btn.text; font: btn.font
            color: btn.primary ? win.c.onA2 : win.c.text
            opacity: btn.enabled ? 1 : 0.5
            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: btn.primary ? (btn.down ? Qt.darker(win.c.a2, 1.2) : win.c.a2) : "transparent"
            border.color: btn.primary ? (btn.activeFocus ? win.c.text : "transparent") : (btn.hovered ? win.c.a3 : win.c.edge)
            border.width: btn.primary ? (btn.activeFocus ? 2 : 0) : 1
            opacity: btn.enabled ? 1 : 0.5
        }
    }
}
