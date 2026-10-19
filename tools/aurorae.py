"""Aurorae window decoration (one theme per palette), used by gen-themes.py.

Geometry: the SVG frame borders are S px wide but the client is inset only
VISIBLE px (Layout section), so the client covers the inner part of each side
border. That leaves room for the 10 px chamfer on the title bar's top-left
corner, which a FrameSvg corner can only be as wide as its side border.
"""

S = 13         # SVG side/bottom border size
VISIBLE = 3    # visible border (client inset)
T = 30         # title bar height = TitleEdgeTop + TitleHeight + TitleEdgeBottom
C = 10         # title bar chamfer
CB = 6         # bottom-right chamfer
BW, BH = 26, 20  # button size

HIDDEN = 'fill="#000" fill-opacity="0"'


def _frame(prefix, top, bottom, line, edge, y0, chamfer=True):
    grad = f"url(#g-{prefix})"
    # Each element is laid out on its own row so the bounding boxes never overlap.
    parts = [f'<linearGradient id="g-{prefix}" x1="0" y1="0" x2="0" y2="1">'
             f'<stop offset="0" stop-color="{top}"/><stop offset="1" stop-color="{bottom}"/>'
             f'</linearGradient>']

    def el(name, x, y, w, h, body):
        parts.append(f'<g id="{prefix}-{name}" transform="translate({x},{y})">'
                     f'<rect width="{w}" height="{h}" {HIDDEN}/>{body}</g>')

    y = y0
    if chamfer:
        tl = (f'<polygon points="{C},0 {S},0 {S},{T} 0,{T} 0,{C}" fill="{grad}"/>'
              f'<polyline points="1,{T} 1,{C + 0.4} {C + 0.4},1 {S},1" fill="none" '
              f'stroke="{line}" stroke-width="2"/>')
    else:
        tl = (f'<rect width="{S}" height="{T}" fill="{grad}"/>'
              f'<rect width="{S}" height="2" fill="{line}"/>'
              f'<rect y="2" width="1" height="{T - 2}" fill="{edge}"/>')
    el("topleft", 0, y, S, T, tl)
    el("top", 20, y, 1, T, f'<rect width="1" height="{T}" fill="{grad}"/>'
                           f'<rect width="1" height="2" fill="{line}"/>')
    el("topright", 30, y, S, T, f'<rect width="{S}" height="{T}" fill="{grad}"/>'
                                f'<rect width="{S}" height="2" fill="{line}"/>'
                                f'<rect x="{S - 1}" y="2" width="1" height="{T - 2}" fill="{edge}"/>')
    y += T + 10
    el("left", 0, y, S, 1, f'<rect width="{S}" height="1" fill="{bottom}"/>'
                           f'<rect width="1" height="1" fill="{edge}"/>')
    el("center", 20, y, 1, 1, f'<rect width="1" height="1" fill="{bottom}"/>')
    el("right", 30, y, S, 1, f'<rect width="{S}" height="1" fill="{bottom}"/>'
                             f'<rect x="{S - 1}" width="1" height="1" fill="{edge}"/>')
    y += 10
    el("bottomleft", 0, y, S, S, f'<rect width="{S}" height="{S}" fill="{bottom}"/>'
                                 f'<rect width="1" height="{S}" fill="{edge}"/>'
                                 f'<rect y="{S - 1}" width="{S}" height="1" fill="{edge}"/>')
    el("bottom", 20, y, 1, S, f'<rect width="1" height="{S}" fill="{bottom}"/>'
                              f'<rect y="{S - 1}" width="1" height="1" fill="{edge}"/>')
    el("bottomright", 30, y, S, S,
       f'<polygon points="0,0 {S},0 {S},{S - CB} {S - CB},{S} 0,{S}" fill="{bottom}"/>'
       f'<polyline points="{S - 0.5},0 {S - 0.5},{S - CB} {S - CB},{S - 0.5} 0,{S - 0.5}" '
       f'fill="none" stroke="{edge}" stroke-width="1"/>')
    return "".join(parts)


def decoration_svg(p):
    active = dict(top=p["decoTop"], bottom=p["decoBottom"], line=p["decoLine"], edge=p["frame"])
    inactive = dict(top=p["titleInactive"], bottom=p["titleInactive"], line=p["border"],
                    edge=p["border"])
    body = (_frame("decoration", **active, y0=0) +
            _frame("decoration-inactive", **inactive, y0=120) +
            _frame("decoration-maximized", **active, y0=240, chamfer=False) +
            _frame("decoration-maximized-inactive", **inactive, y0=360, chamfer=False))
    return _svg(60, 4 * 120, body)


GLYPHS = {
    "minimize": '<line x1="9" y1="13.5" x2="17" y2="13.5"/>',
    "maximize": '<rect x="9.5" y="5.5" width="7" height="8"/>',
    "restore": '<rect x="8.5" y="8.5" width="6" height="6"/>'
               '<polyline points="10.5,8.5 10.5,5.5 17.5,5.5 17.5,11.5 14.5,11.5"/>',
    "close": '<line x1="9" y1="6" x2="17" y2="14"/><line x1="17" y1="6" x2="9" y2="14"/>',
}

BUTTON_SHAPE = f"3,0 {BW},0 {BW},{BH - 3} {BW - 3},{BH} 0,{BH} 0,3"


def button_svg(name, p):
    hot = p["negative"] if name == "close" else p["selection"]

    def state(fill, alpha, glyph, glyph_alpha=1.0):
        bg = (f'<polygon points="{BUTTON_SHAPE}" fill="{fill}" fill-opacity="{alpha}"/>'
              if alpha else "")
        return (bg + f'<g fill="none" stroke="{glyph}" stroke-opacity="{glyph_alpha}" '
                f'stroke-width="1.5" stroke-linecap="square">{GLYPHS[name]}</g>')

    hover_glyph = p["selectionText"] if name == "close" else p["text"]
    states = {
        "active": state(hot, 0, p["titleActiveText"]),
        "hover": state(hot, 0.9 if name == "close" else 0.25, hover_glyph),
        "pressed": state(hot, 0.6 if name == "close" else 0.45, hover_glyph),
        "deactivated": state(hot, 0, p["muted"], 0.4),
        "inactive": state(hot, 0, p["titleInactiveText"]),
        "hover-inactive": state(hot, 0.9 if name == "close" else 0.25, hover_glyph),
        "pressed-inactive": state(hot, 0.6 if name == "close" else 0.45, hover_glyph),
        "deactivated-inactive": state(hot, 0, p["muted"], 0.4),
    }
    body = "".join(f'<g id="{sid}" transform="translate(0,{i * (BH + 10)})">'
                   f'<rect width="{BW}" height="{BH}" {HIDDEN}/>{content}</g>'
                   for i, (sid, content) in enumerate(states.items()))
    return _svg(BW, len(states) * (BH + 10), body)


def _svg(w, h, body):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" '
            f'viewBox="0 0 {w} {h}"><defs/>{body}</svg>\n')


def rc(p, rgb):
    title_edge_top = 4
    title_edge_bottom = 4
    return f"""[General]
ActiveTextColor={rgb(p["titleActiveText"])}
InactiveTextColor={rgb(p["titleInactiveText"])}
TitleAlignment=Left
TitleVerticalAlignment=Center
Animation=120
Shadow=false
UseTextShadow=false

[Layout]
BorderLeft={VISIBLE}
BorderRight={VISIBLE}
BorderBottom={VISIBLE}
TitleEdgeTop={title_edge_top}
TitleEdgeBottom={title_edge_bottom}
TitleEdgeLeft={C + 2}
TitleEdgeRight={VISIBLE + 1}
TitleEdgeTopMaximized=2
TitleEdgeBottomMaximized=2
TitleEdgeLeftMaximized=4
TitleEdgeRightMaximized=0
TitleBorderLeft=6
TitleBorderRight=6
TitleHeight={T - title_edge_top - title_edge_bottom}
ButtonWidth={BW}
ButtonHeight={BH}
ButtonSpacing=2
ButtonMarginTop=1
ExplicitButtonSpacer=8
PaddingTop=0
PaddingBottom=0
PaddingLeft=0
PaddingRight=0
"""


def metadata(theme, p):
    return f"""[Desktop Entry]
Name={p["name"]}
Comment=OldNet OS window decoration
X-KDE-PluginInfo-Name={theme}
X-KDE-PluginInfo-Author=OldNet OS
X-KDE-PluginInfo-Version=0.1
X-KDE-PluginInfo-Website=https://github.com/LemosF/oldnet
X-KDE-PluginInfo-Category=
X-KDE-PluginInfo-License=Apache-2.0
X-KDE-PluginInfo-EnabledByDefault=true
"""


def files(scheme_id, p, rgb):
    """Yield (relative path under usr/share/aurorae/themes, text) for one palette."""
    theme = f"OldNet-{scheme_id}"
    yield f"{theme}/metadata.desktop", metadata(theme, p)
    yield f"{theme}/{theme}rc", rc(p, rgb)
    yield f"{theme}/decoration.svg", decoration_svg(p)
    for name in GLYPHS:
        yield f"{theme}/{name}.svg", button_svg(name, p)
