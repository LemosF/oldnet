import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami
import org.kde.taskmanager as TaskManager

// OldNet Tabs: one tab per KDE activity (Desktop, Mail, Messages, Games, Code).
// Switching, creating missing activities and hiding the taskbar are done by
// /usr/bin/oldnet-tab, which the Meta+1..5 shortcuts also use. Clicking an empty tab
// that has a launcher (Mail, Messages) starts its app there.
PlasmoidItem {
    id: root

    preferredRepresentation: fullRepresentation
    Plasmoid.constraintHints: Plasmoid.CanFillArea

    readonly property var tabNames: Plasmoid.configuration.tabNames
    readonly property var icons: Plasmoid.configuration.tabIcons
    readonly property var launchers: Plasmoid.configuration.tabLaunchers

    // Bumped whenever windows or activities change, so names and counts re-evaluate.
    property int revision: 0

    TaskManager.ActivityInfo {
        id: activities
        onCurrentActivityChanged: {
            root.revision++
            // Also covers switches made outside the bar (Meta+Q, Meta+Tab).
            const name = activityName(currentActivity)
            if (root.tabNames.indexOf(name) >= 0) root.run("oldnet-tab panel " + name)
        }
        onNumberOfRunningActivitiesChanged: root.revision++
    }

    TaskManager.TasksModel {
        id: tasks
        groupMode: TaskManager.TasksModel.GroupDisabled
        filterByActivity: false
        onRowsInserted: root.revision++
        onRowsRemoved: root.revision++
        onDataChanged: root.revision++
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        onNewData: (source, data) => disconnectSource(source)
    }

    function run(command) {
        executable.connectSource(command)
    }

    function activityIdOf(name, revision) {
        const ids = activities.runningActivities()
        for (let i = 0; i < ids.length; i++) {
            if (activities.activityName(ids[i]) === name) return ids[i]
        }
        return ""
    }

    function currentName(revision) {
        return activities.activityName(activities.currentActivity)
    }

    function windowsOn(name, revision) {
        const id = activityIdOf(name, revision)
        if (!id) return 0
        let count = 0
        for (let i = 0; i < tasks.count; i++) {
            const idx = tasks.index(i, 0)
            if (tasks.data(idx, TaskManager.AbstractTasksModel.IsWindow) !== true) continue
            const ids = tasks.data(idx, TaskManager.AbstractTasksModel.Activities) || []
            // An empty list means "on all activities": not counted on any one tab.
            if (ids.indexOf(id) !== -1) count++
        }
        return count
    }

    function activate(index) {
        let command = "oldnet-tab switch " + (index + 1)
        // Tabs that own an app (Mail, Messages) open it when they are empty;
        // oldnet-tab finds the app's desktop file (RPM or Flatpak).
        if ((launchers[index] || "none") !== "none" && windowsOn(tabNames[index], revision) === 0) {
            command += " --launch"
        }
        run(command)
    }

    Component.onCompleted: run("oldnet-tab ensure")

    fullRepresentation: MouseArea {
        Layout.fillWidth: true
        Layout.minimumWidth: tabRow.implicitWidth
        Layout.preferredHeight: Kirigami.Units.gridUnit * 1.6
        acceptedButtons: Qt.NoButton

        // Scroll over the bar to move between tabs.
        onWheel: wheel => {
            const n = root.tabNames.length
            const current = Math.max(0, root.tabNames.indexOf(root.currentName(root.revision)))
            const step = wheel.angleDelta.y < 0 ? 1 : -1
            root.run("oldnet-tab switch " + (((current + step + n) % n) + 1))
        }

        RowLayout {
            id: tabRow
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing

            Repeater {
                model: root.tabNames
                delegate: TabItem {
                    required property string modelData
                    required property int index
                    number: index + 1
                    label: modelData
                    iconName: root.icons[index] || ""
                    active: modelData === root.currentName(root.revision)
                    windows: root.windowsOn(modelData, root.revision)
                    showWindowCount: Plasmoid.configuration.showWindowCount
                    onActivated: root.activate(index)
                }
            }
            Item { Layout.fillWidth: true }
        }
    }
}
