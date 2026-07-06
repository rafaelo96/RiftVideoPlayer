#!/usr/bin/env python3
"""Set DMG background and icon positions using ds_store library."""

import os, struct, sys
from ds_store import DSStore
from mac_alias import Bookmark

mount = sys.argv[1] if len(sys.argv) > 1 else "/Volumes/Rift"

DS_STORE = os.path.join(mount, ".DS_Store")
BG_PATH = os.path.join(mount, ".background", "dmg-background.png")
APP = "Rift.app"
APPLICATIONS = "Applications"

if os.path.exists(DS_STORE):
    os.unlink(DS_STORE)

with DSStore.open(DS_STORE, "w+") as d:
    if os.path.exists(BG_PATH):
        with open(BG_PATH, "rb") as f:
            bg_data = f.read()

        bk = Bookmark.for_file(BG_PATH)

        d[".background"]["dmg-background.png"] = ("BKGD", bk)
        d["."]["bimg"] = ("bimg", bg_data)
        d["."]["bgnd"] = ("bgnd", bk)
        print("Background set")

    # Window settings: icon view
    d["."]["fwSw"] = ("fwSw", struct.pack("<I", 1))
    d["."]["icvt"] = ("icvt", struct.pack("<H", 1))
    d["."]["iCtT"] = ("iCtT", struct.pack("<I", 1))
    d["."]["view"] = ("view", struct.pack("<I", 1))
    d["."]["showToolbar"] = ("showToolbar", struct.pack("<?", False))
    d["."]["showStatusBar"] = ("showStatusBar", struct.pack("<?", False))
    d["."]["showSidebar"] = ("showSidebar", struct.pack("<?", False))
    d["."]["icgo"] = ("icgo", struct.pack("<?", True))
    d["."]["lsvD"] = ("lsvD", struct.pack("<I", 0))
    d["."]["iIlS"] = ("iIlS", struct.pack("<I", 96))
    d["."]["iItS"] = ("iItS", struct.pack("<I", 12))
    d["."]["iIso"] = ("iIso", struct.pack("<?", True))

    # Window position and size
    d["."]["windowPos"] = ("windowPos", struct.pack("<2f", 100.0, 80.0))
    d["."]["windowSize"] = ("windowSize", struct.pack("<2f", 720.0, 420.0))
    d["."]["blWi"] = ("blWi", struct.pack("<i4I", 0, 100, 80, 820, 500))

    # Icon positions (Iloc = x, y, 0, 0 as 32-bit floats)
    d[f"{APP}:"] = ("Iloc", struct.pack("<4f", 160.0, 210.0, 0.0, 0.0))
    d[f"{APPLICATIONS}:"] = ("Iloc", struct.pack("<4f", 560.0, 210.0, 0.0, 0.0))

    print(f"Icon positions set: {APP} at 160,210 | {APPLICATIONS} at 560,210")

print("DS_Store written successfully")
