"""Thunderbird themes (one per palette), used by gen-themes.py.

A Thunderbird theme is a WebExtension with only a manifest: colours, no shapes. The
image build zips each folder into an .xpi and a Thunderbird policy installs them
(build_files/22-thunderbird.sh).
"""
import json

GECKO_PREFIX = "oldnet-"
GECKO_DOMAIN = "@themes.oldnet.os"


def theme_id(scheme_id):
    # NightMarket -> oldnet-nightmarket@themes.oldnet.os
    return f"{GECKO_PREFIX}{scheme_id.lower()}{GECKO_DOMAIN}"


def manifest(scheme_id, p):
    dark = p["dark"]
    window = p["bg"] if dark else p["surface"]       # main panes
    chrome = p["surface"] if dark else p["bg"]       # toolbars, tab strip
    colors = {
        "frame": p["bg"] if dark else p["raised"],
        "frame_inactive": p["bg"] if dark else p["raised"],
        "tab_background_text": p["muted"],
        "tab_selected": chrome,
        "tab_text": p["text"],
        "tab_line": p["accent"],                       # accent line on the active tab
        "tab_loading": p["hover"],
        "toolbar": chrome,
        "toolbar_text": p["text"],
        "toolbar_top_separator": p["border"],
        "toolbar_bottom_separator": p["border"],
        "toolbar_field": window,
        "toolbar_field_text": p["text"],
        "toolbar_field_border": p["border"],
        "toolbar_field_focus": window,
        "toolbar_field_text_focus": p["text"],
        "toolbar_field_border_focus": p["focus"],
        "toolbar_field_highlight": p["selection"],
        "toolbar_field_highlight_text": p["selectionText"],
        "button_background_hover": p["raised"],
        "button_background_active": p["alt"],
        "icons": p["text"],
        "icons_attention": p["positive"],
        "popup": p["raised"],
        "popup_text": p["text"],
        "popup_border": p["border"],
        "popup_highlight": p["selection"],
        "popup_highlight_text": p["selectionText"],
        "sidebar": window,
        "sidebar_text": p["text"],
        "sidebar_border": p["border"],
        "sidebar_highlight": p["selection"],
        "sidebar_highlight_text": p["selectionText"],
    }
    return {
        "manifest_version": 2,
        "name": p["name"],
        "description": "OldNet OS colour theme. Generated from themes/palettes/palettes.json.",
        "version": "0.1",
        "author": "OldNet OS",
        "homepage_url": "https://github.com/LemosF/oldnet",
        "browser_specific_settings": {
            "gecko": {"id": theme_id(scheme_id), "strict_min_version": "115.0"}
        },
        "theme": {
            "colors": colors,
            "properties": {
                "color_scheme": "dark" if dark else "light",
                "content_color_scheme": "dark" if dark else "light",
            },
        },
    }


def files(scheme_id, p):
    """Yield (relative path under usr/share/oldnet/thunderbird/themes, text)."""
    yield f"{theme_id(scheme_id)}/manifest.json", json.dumps(manifest(scheme_id, p), indent=2) + "\n"
