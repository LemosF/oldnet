"""OldNet Plasma desktop theme (frames for popups, notifications, tooltips, panels and
desktop widgets), used by gen-themes.py.

Palette-independent: shapes use Plasma's colour-scheme CSS classes, so the frames take
the colours of whichever OldNet colour scheme is active. Anything not drawn here (buttons,
sliders, ...) falls back to Breeze ("default").

Frames follow the mockup: top-left and bottom-right corners chamfered, a thin outline and
a 2 px accent line on the top edge (NegativeText = coral in Night Market and Daylight).
"""

STYLE = (
    '<style id="current-color-scheme" type="text/css">'
    ".ColorScheme-Background{color:#121216}"
    ".ColorScheme-Text{color:#ECE9E4}"
    ".ColorScheme-NegativeText{color:#FF5468}"
    "</style>"
)
BG = 'class="ColorScheme-Background" fill="currentColor"'
EDGE = 'class="ColorScheme-Text" fill="currentColor" fill-opacity="0.18"'
EDGE_STROKE = 'class="ColorScheme-Text" fill="none" stroke="currentColor" stroke-opacity="0.18" stroke-width="1"'
ACCENT = 'class="ColorScheme-NegativeText" fill="currentColor"'
ACCENT_STROKE = 'class="ColorScheme-NegativeText" fill="none" stroke="currentColor" stroke-width="2"'
HIDDEN = 'fill="#000" fill-opacity="0"'


class Sheet:
    """Collects FrameSvg elements; each one gets its own spot so boxes never overlap."""

    def __init__(self):
        self.parts = []
        self.y = 0

    def el(self, name, w, h, body, x=0):
        self.parts.append(f'<g id="{name}" transform="translate({x},{self.y})">'
                          f'<rect width="{w}" height="{h}" {HIDDEN}/>{body}</g>')

    def row(self, height):
        self.y += height + 10

    def svg(self):
        return (f'<svg xmlns="http://www.w3.org/2000/svg" width="200" height="{self.y + 10}">'
                f'<defs>{STYLE}</defs>{"".join(self.parts)}</svg>\n')


def chamfered_frame(sheet, prefix="", c=14, cut=9, accent_top=True):
    """A floating frame: corners c x c, chamfer `cut` on top-left and bottom-right."""
    p = f"{prefix}-" if prefix else ""
    acc_line = f'<rect width="{{w}}" height="2" {ACCENT}/>' if accent_top else ""

    tl = f'<polygon points="{cut},0 {c},0 {c},{c} 0,{c} 0,{cut}" {BG}/>'
    tl += (f'<path d="M1,{cut + 0.4} L{cut + 0.4},1 H{c}" {ACCENT_STROKE}/>' if accent_top
           else f'<path d="M0.5,{c} V{cut} L{cut},0.5 H{c}" {EDGE_STROKE}/>')
    tl += f'<path d="M0.5,{cut + 1} V{c}" {EDGE_STROKE}/>'
    sheet.el(p + "topleft", c, c, tl, 0)
    sheet.el(p + "top", 1, c, f'<rect width="1" height="{c}" {BG}/>' + acc_line.format(w=1), 30)
    sheet.el(p + "topright", c, c, f'<rect width="{c}" height="{c}" {BG}/>' + acc_line.format(w=c)
             + f'<rect x="{c - 1}" y="2" width="1" height="{c - 2}" {EDGE}/>', 50)
    sheet.row(c)

    sheet.el(p + "left", c, 1, f'<rect width="{c}" height="1" {BG}/><rect width="1" height="1" {EDGE}/>', 0)
    sheet.el(p + "center", 1, 1, f'<rect width="1" height="1" {BG}/>', 30)
    sheet.el(p + "right", c, 1, f'<rect width="{c}" height="1" {BG}/>'
             f'<rect x="{c - 1}" width="1" height="1" {EDGE}/>', 50)
    sheet.row(1)

    sheet.el(p + "bottomleft", c, c, f'<rect width="{c}" height="{c}" {BG}/>'
             f'<rect width="1" height="{c}" {EDGE}/><rect y="{c - 1}" width="{c}" height="1" {EDGE}/>', 0)
    sheet.el(p + "bottom", 1, c, f'<rect width="1" height="{c}" {BG}/>'
             f'<rect y="{c - 1}" width="1" height="1" {EDGE}/>', 30)
    sheet.el(p + "bottomright", c, c,
             f'<polygon points="0,0 {c},0 {c},{c - cut} {c - cut},{c} 0,{c}" {BG}/>'
             f'<path d="M{c - 0.5},0 V{c - cut} L{c - cut},{c - 0.5} H0" {EDGE_STROKE}/>', 50)
    sheet.row(c)

    # Content sits closer than the corner size.
    for side in ("top", "bottom", "left", "right"):
        w, h = (1, 8) if side in ("top", "bottom") else (8, 1)
        sheet.el(f"{p}hint-{side}-margin", w, h, "", 0)
        sheet.row(h)


def panel_frame(sheet, prefix, accent_edge):
    """Panel background: flat, thin outline, accent line on the edge facing the screen
    centre (top edge for a bottom panel, bottom edge for a top panel)."""
    p = f"{prefix}-" if prefix else ""
    b = 3

    def line(edge, w, h):
        if edge != accent_edge:
            return ""
        if edge == "top":
            return f'<rect width="{w}" height="2" {ACCENT}/>'
        return f'<rect y="{h - 2}" width="{w}" height="2" {ACCENT}/>'

    for row, (names, h) in enumerate(((("topleft", "top", "topright"), b),
                                      (("left", "center", "right"), 1),
                                      (("bottomleft", "bottom", "bottomright"), b))):
        for i, n in enumerate(names):
            w = 1 if n in ("top", "center", "bottom") else b
            edge = "top" if row == 0 else "bottom" if row == 2 else ""
            sheet.el(p + n, w, h, f'<rect width="{w}" height="{h}" {BG}/>' + line(edge, w, h), i * 20)
        sheet.row(h)


def dialog_svg():
    s = Sheet()
    chamfered_frame(s)
    return s.svg()


def tooltip_svg():
    s = Sheet()
    chamfered_frame(s, c=10, cut=6, accent_top=False)
    return s.svg()


def panel_svg():
    s = Sheet()
    panel_frame(s, "", accent_edge="none")        # side panels: no accent
    panel_frame(s, "south", accent_edge="top")    # bottom panel (taskbar)
    panel_frame(s, "north", accent_edge="bottom") # top panel (OldNet Tabs)
    return s.svg()


METADATA = """{
    "KPlugin": {
        "Authors": [{"Name": "OldNet OS"}],
        "Description": "OldNet OS Plasma theme: chamfered HUD frames, colours from the active OldNet colour scheme",
        "Description[pt_PT]": "Tema Plasma do OldNet OS: molduras HUD chamfradas, cores do esquema de cores OldNet ativo",
        "Id": "oldnet",
        "License": "Apache-2.0",
        "Name": "OldNet",
        "Version": "0.1",
        "Website": "https://github.com/LemosF/oldnet"
    },
    "X-Plasma-API-Minimum-Version": "6.0"
}
"""


def files():
    """Yield (relative path under usr/share/plasma/desktoptheme/oldnet, text)."""
    yield "metadata.json", METADATA
    yield "dialogs/background.svg", dialog_svg()      # popups, notifications, menus
    yield "widgets/background.svg", dialog_svg()      # desktop widgets
    yield "widgets/tooltip.svg", tooltip_svg()
    yield "widgets/panel-background.svg", panel_svg()
