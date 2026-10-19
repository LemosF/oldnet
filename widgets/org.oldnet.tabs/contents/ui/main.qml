import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami
import org.kde.taskmanager as TaskManager

// OldNet Tabs: one tab per virtual desktop. Clicking an empty tab that has a
// launcher (Mail, Messages) starts its app; KWin rules then place the window.
PlasmoidItem {
    id: root

    preferredRepresentation: fullRepresentation
    Plasmoid.constraintHints: Plasmoid.CanFillArea

    readonly property var icons: Plasmoid.configuration.tabIcons
    readonly property var launchers: Plasmoid.configuration.tabLaunchers

    // Bumped whenever windows change, so the per-tab counts re-evaluate.
    property int tasksRevision: 0

    TaskManager.VirtualDesktopInfo { id: desktops }
    TaskManager.ActivityInfo { id: activities }

    TaskManager.TasksModel {
        id: tasks
        groupMode: TaskManager.TasksModel.GroupDisabled
        filterByActivity: true
        activity: activities.currentActivity
        onRowsInserted: root.tasksRevision++
        onRowsRemoved: root.tasksRevision++
        onDataChanged: root.tasksRevision++
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        onNewData: (source, data) => disconnectSource(source)
    }

    function windowsOn(desktopId, revision) {
        let count = 0;
        for (let i = 0; i < tasks.count; i++) {
            const idx = tasks.index(i, 0);
            if (tasks.data(idx, TaskManager.AbstractTasksModel.IsWindow) !== true) {
                continue;
            }
            const onAll = tasks.data(idx, TaskManager.AbstractTasksModel.IsOnAllVirtualDesktops);
            const ids = tasks.data(idx, TaskManager.AbstractTasksModel.VirtualDesktops) || [];
            if (!onAll && ids.indexOf(desktopId) !== -1) {
                count++;
            }
        }
        return count;
    }

    function launch(desktopFileId) {
        // Desktop file ids only: refuse anything that could reach the shell.
        if (!/^[A-Za-z0-9._-]+$/.test(desktopFileId)) {
            return;
        }
        executable.connectSource("gtk-launch " + desktopFileId);
    }

    function activate(index) {
        const id = desktops.desktopIds[index];
        desktops.requestActivate(id);
        const launcher = launchers[index] || "none";
        if (launcher !== "none" && windowsOn(id, tasksRevision) === 0) {
            launch(launcher);
        }
    }

    fullRepresentation: MouseArea {
        Layout.fillWidth: true
        Layout.minimumWidth: tabRow.implicitWidth
        Layout.preferredHeight: Kirigami.Units.gridUnit * 1.6
        acceptedButtons: Qt.NoButton

        // Scroll over the bar to move between tabs.
        onWheel: wheel => {
            const n = desktops.numberOfDesktops;
            const current = desktops.desktopIds.indexOf(desktops.currentDesktop);
            const step = wheel.angleDelta.y < 0 ? 1 : -1;
            desktops.requestActivate(desktops.desktopIds[(current + step + n) % n]);
        }

        RowLayout {
            id: tabRow
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing

            Repeater {
                model: desktops.desktopIds
                delegate: TabItem {
                    required property var modelData
                    required property int index
                    number: index + 1
                    label: desktops.desktopNames[index] || i18n("Tab %1", index + 1)
                    iconName: root.icons[index] || ""
                    active: modelData === desktops.currentDesktop
                    windows: root.windowsOn(modelData, root.tasksRevision)
                    showWindowCount: Plasmoid.configuration.showWindowCount
                    onActivated: root.activate(index)
                }
            }
            Item { Layout.fillWidth: true }
        }
    }
}
