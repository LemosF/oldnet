// OldNet default layout: XP-style taskbar at the bottom, OldNet Tabs bar at the top.
// Runs once, when a user's Plasma session starts with no layout yet.

var taskbar = new Panel;
taskbar.location = "bottom";
taskbar.height = 2 * Math.floor(gridUnit * 2.5 / 2);
taskbar.addWidget("org.kde.plasma.kickoff");
taskbar.addWidget("org.kde.plasma.icontasks");
taskbar.addWidget("org.kde.plasma.marginsseparator");
taskbar.addWidget("org.kde.plasma.systemtray");
taskbar.addWidget("org.kde.plasma.digitalclock");
taskbar.addWidget("org.kde.plasma.showdesktop");

var tabBar = new Panel;
tabBar.location = "top";
tabBar.height = 2 * Math.floor(gridUnit * 1.8 / 2);
tabBar.addWidget("org.oldnet.tabs");

var allDesktops = desktopsForActivity(currentActivity());
for (var i = 0; i < allDesktops.length; i++) {
    allDesktops[i].wallpaperPlugin = "org.kde.image";
}
