// OldNet Tab Apps: on the Mail and Messages tabs, the app owns the tab. Its main window
// (the first window of the app) opens maximized and without a frame. Elsewhere, and for
// the app's other windows (composer, dialogs), nothing changes. Right after login the
// apps are preloaded from Desktop and their first window is moved to its tab.
//
// Activities have per-user ids, so /usr/bin/oldnet-tab writes them to kwinrc
// [Script-oldnet-tab-apps] (Mail=<id>, Messages=<id>) and asks KWin to reconfigure.

const APPS = [
    { tab: "Mail", match: /thunderbird/i },
    { tab: "Messages", match: /neochat/i },
];

function sameApp(a, b) {
    return String(a.resourceClass).toLowerCase() === String(b.resourceClass).toLowerCase();
}

function claim(window) {
    if (!window.normalWindow) return;
    const app = APPS.find(a => a.match.test(String(window.resourceClass)));
    if (!app) return;

    const activity = readConfig(app.tab, "");      // read each time: oldnet-tab updates it
    if (!activity) return;

    // Later windows (first-run wizard, account setup, composers, dialogs) follow the app:
    // if its main window lives on the tab, they open there too, as normal windows.
    // An app the user opened on Desktop keeps all its windows on Desktop.
    const others = workspace.windowList().filter(w => w !== window && sameApp(w, window));
    if (others.length > 0) {
        const appOnTab = others.some(w => w.activities.indexOf(activity) !== -1);
        if (appOnTab && window.activities.indexOf(activity) === -1) window.activities = [activity];
        return;
    }

    const onTab = window.activities.indexOf(activity) !== -1
        || (window.activities.length === 0 && workspace.currentActivity === activity);
    // At session start "oldnet-tab start" preloads the apps while the user is on Desktop;
    // for a short while their first window is moved onto its own tab.
    const preloading = Number(readConfig("PreloadUntil", 0)) > Date.now() / 1000;
    if (!onTab && !preloading) return;
    if (!onTab) window.activities = [activity];

    window.noBorder = true;
    window.setMaximize(true, true);
}

workspace.windowAdded.connect(claim);
