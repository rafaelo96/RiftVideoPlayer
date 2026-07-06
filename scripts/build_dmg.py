#!/usr/bin/env python3
"""Build Rift.dmg with custom background using dmgbuild."""

import dmgbuild
import plistlib
import os

settings = {
    "filename": "Rift.dmg",
    "volume_name": "Rift",
    "format": "UDZO",
    "compression_level": 9,
    "size": None,
    "files": ["Rift.app"],
    "symlinks": {"Applications": "/Applications"},
    "icon": "Rift.app/Contents/Resources/Rift.icns",
    "background": "dmg-background.tiff",
    "icon_size": 96,
    "icon_locations": {
        "Rift.app": (160, 210),
        "Applications": (560, 210),
    },
    "window_rect": ((100, 80), (720, 420)),
    "text_size": 12,
    "exclude": [".DS_Store", ".fseventsd"],
    "badge_icon": None,
    "show_status_bar": False,
    "show_toolbar": False,
    "show_pathbar": False,
    "show_sidebar": False,
    "show_icon_preview": True,
    "show_item_info": True,
    "arrange_by": None,
    "grid_offset": (0, 0),
    "grid_spacing": 100,
    "scroll_position": (0, 0),
    "background_color": None,
}

print("Building Rift.dmg with custom background...")
dmgbuild.build_dmg(
    filename=settings["filename"],
    volume_name=settings["volume_name"],
    settings=settings
)
print("Done!")
