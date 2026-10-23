#!/usr/bin/python3
"""OldNet welcome app: palette choice, Flatpak packs, a tour of the tabs.

    oldnet-welcome               open the app
    oldnet-welcome --first-run   open it only if the user has not dismissed it yet
    oldnet-welcome --check       load the interface offscreen and exit (build test)
"""
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

from PySide6.QtCore import Property, QObject, QProcess, QTimer, Signal, Slot
from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine

HERE = Path(__file__).resolve().parent
DATA = Path("/usr/share/oldnet/welcome")
CONFIG = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
DONE_FLAG = CONFIG / "oldnet" / "welcome-done"

# Palette id -> what it switches (colour scheme, window frame, icons).
PALETTES = {
    "NightMarket": {"icons": "OldNet"},
    "HoloTablet": {"icons": "OldNet-Holo"},
    "Daylight": {"icons": "OldNet-Daylight"},
}


def run(*cmd):
    """Run a helper, ignoring failures: a missing tool must not break the app."""
    try:
        subprocess.run(cmd, check=False, timeout=30)
    except (OSError, subprocess.TimeoutExpired):
        pass


class Backend(QObject):
    installOutput = Signal(str)
    installFinished = Signal(str, bool)   # pack id, success
    showAtStartupChanged = Signal()

    def __init__(self):
        super().__init__()
        with open(DATA / "packs.json", encoding="utf-8") as f:
            self._packs = json.load(f)["packs"]
        self._process = None
        self._installing = ""

    # --- packs
    @Property("QVariantList", constant=True)
    def packs(self):
        return self._packs

    @Slot(str)
    def installPack(self, pack_id):
        if self._process is not None:
            return
        pack = next((p for p in self._packs if p["id"] == pack_id), None)
        if pack is None:
            return
        ids = [a["id"] for a in pack["apps"]]
        self._installing = pack_id
        self._process = QProcess(self)
        self._process.setProcessChannelMode(QProcess.MergedChannels)
        self._process.readyReadStandardOutput.connect(self._read_output)
        self._process.finished.connect(self._install_done)
        # System-wide like Bazzite's own apps; Flatpak asks for the password itself.
        self._process.start("flatpak", ["install", "-y", "--noninteractive", "flathub", *ids])

    def _read_output(self):
        text = bytes(self._process.readAllStandardOutput()).decode(errors="replace")
        for line in text.replace("\r", "\n").splitlines():
            if line.strip():
                self.installOutput.emit(line.strip())

    def _install_done(self, code, _status):
        pack_id, self._installing = self._installing, ""
        self._process.deleteLater()
        self._process = None
        self.installFinished.emit(pack_id, code == 0)

    # --- appearance
    @Slot(str)
    def applyPalette(self, palette_id):
        if palette_id not in PALETTES:
            return
        run("plasma-apply-colorscheme", f"OldNet{palette_id}")
        run("kwriteconfig6", "--file", "kwinrc", "--group", "org.kde.kdecoration2",
            "--key", "library", "org.kde.kwin.aurorae")
        run("kwriteconfig6", "--file", "kwinrc", "--group", "org.kde.kdecoration2",
            "--key", "theme", f"__aurorae__svg__OldNet-{palette_id}")
        run("busctl", "--user", "call", "org.kde.KWin", "/KWin", "org.kde.KWin", "reconfigure")
        changeicons = "/usr/libexec/plasma-changeicons"
        if os.path.exists(changeicons):
            run(changeicons, PALETTES[palette_id]["icons"])
        self._konsole_palette(palette_id)

    def _konsole_palette(self, palette_id):
        """A user copy of the OldNet Konsole profile with this palette's colours."""
        system = Path("/usr/share/konsole/OldNet.profile")
        if not system.exists():
            return
        user = Path.home() / ".local" / "share" / "konsole" / "OldNet.profile"
        user.parent.mkdir(parents=True, exist_ok=True)
        lines = [f"ColorScheme=OldNet{palette_id}" if l.startswith("ColorScheme=") else l
                 for l in system.read_text(encoding="utf-8").splitlines()]
        user.write_text("\n".join(lines) + "\n", encoding="utf-8")

    # --- start-up
    def _get_show(self):
        return not DONE_FLAG.exists()

    def _set_show(self, show):
        if show:
            DONE_FLAG.unlink(missing_ok=True)
        else:
            DONE_FLAG.parent.mkdir(parents=True, exist_ok=True)
            DONE_FLAG.touch()
        self.showAtStartupChanged.emit()

    showAtStartup = Property(bool, _get_show, _set_show, notify=showAtStartupChanged)

    @Slot(str)
    def openSettings(self, module):
        if shutil.which("systemsettings"):
            subprocess.Popen(["systemsettings", module], start_new_session=True)


def drop_bazzite_portal():
    """The OldNet welcome replaces Bazzite's portal: remove the autostart copy Bazzite
    put in the user's config, and only when it is exactly that file."""
    f = CONFIG / "autostart" / "bazzite-portal.desktop"
    try:
        if f.is_file() and "Exec=yafti_gtk.py" in f.read_text(encoding="utf-8"):
            f.unlink()
    except OSError:
        pass


def main():
    args = sys.argv[1:]
    check = "--check" in args
    if "--first-run" in args:
        drop_bazzite_portal()
        if DONE_FLAG.exists():
            return 0

    # Basic style: every control is drawn by Main.qml, no platform style to fight.
    os.environ.setdefault("QT_QUICK_CONTROLS_STYLE", "Basic")
    app = QGuiApplication(sys.argv)
    app.setApplicationName("oldnet-welcome")
    app.setApplicationDisplayName("OldNet")
    app.setDesktopFileName("org.oldnet.welcome")
    app.setWindowIcon(QIcon.fromTheme("oldnet-welcome"))

    engine = QQmlApplicationEngine()
    backend = Backend()
    engine.rootContext().setContextProperty("backend", backend)
    engine.rootContext().setContextProperty("dataDir", "file://" + str(DATA))
    engine.load(str(HERE / "Main.qml"))
    if not engine.rootObjects():
        print("oldnet-welcome: the interface failed to load", file=sys.stderr)
        return 1
    if check:
        QTimer.singleShot(1500, app.quit)
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
