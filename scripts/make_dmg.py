#!/usr/bin/env python3
"""Create Rift.dmg with custom background, icon positions, and Applications link."""

import os, shutil, subprocess, tempfile, struct, plistlib

TEMP_RW = ".build/rift-rw.dmg"
FINAL_DMG = "Rift.dmg"
APP_PATH = "Rift.app"
BG_PATH = "dmg-background.png"
VOLNAME = "Rift"
ICON_PATH = f"{APP_PATH}/Contents/Resources/Rift.icns"

# Step 1: Create a read-write DMG
subprocess.run([
    "hdiutil", "create", "-ov", "-size", "100m",
    "-fs", "HFS+J", "-volname", VOLNAME,
    "-nospotlight", TEMP_RW
], check=True, capture_output=True)

# Step 2: Mount it
result = subprocess.run([
    "hdiutil", "attach", TEMP_RW
], check=True, capture_output=True, text=True)

mount_line = [l for l in result.stdout.split("\n") if "/Volumes" in l][-1]
mount_point = mount_line.strip().split()[-1]
print(f"Mounted at: {mount_point}")

# Step 3: Copy contents
shutil.copytree(APP_PATH, f"{mount_point}/{APP_PATH}", symlinks=True)
os.makedirs(f"{mount_point}/.background", exist_ok=True)
shutil.copy2(BG_PATH, f"{mount_point}/.background/dmg-background.png")
os.symlink("/Applications", f"{mount_point}/Applications")
if os.path.exists(ICON_PATH):
    shutil.copy2(ICON_PATH, f"{mount_point}/.VolumeIcon.icns")
    subprocess.run(["SetFile", "-a", "C", mount_point])

# Step 4: Create DS_Store with icon positions and background
DS_STORE = f"{mount_point}/.DS_Store"

# Use ds_store library to create the DS_Store
from ds_store import DSStore
from mac_alias import Bookmark, Alias

def make_bookmark(path):
    """Create a bookmark/alias for a file."""
    return Bookmark.default_bookmark(path)

with DSStore.open(DS_STORE, "w+") as d:
    # Set background image
    bg_path = f"{mount_point}/.background/dmg-background.png"
    if os.path.exists(bg_path):
        d["backgroundImageData"] = ("bimg", open(bg_path, "rb").read())
        # Also set as backgroundImage
        bg_alias = make_bookmark(bg_path)
        d[".background"]["dmg-background.png"] = ("BKGD", bg_alias)
    
    # Window settings
    d["."]["blWi"] = ("blWi", struct.pack("<i2I", 0, 100, 80))  # window position
    d["."]["fwSw"] = ("fwSw", struct.pack("<I", 1))  # icon view
    d["."]["icvt"] = ("icvt", struct.pack("<H", 1))  # icon view
    d["."]["iCtT"] = ("iCtT", struct.pack("<I", 1))  # icon view
    d["."]["view"] = ("view", struct.pack("<I", 1))  # icon view
    d["."]["showToolbar"] = ("showToolbar", struct.pack("<?", False))
    d["."]["showStatusBar"] = ("showStatusBar", struct.pack("<?", False))
    d["."]["showSidebar"] = ("showSidebar", struct.pack("<?", False))
    d["."]["showPathbar"] = ("showPathbar", struct.pack("<?", False))
    d["."]["windowPos"] = ("windowPos", struct.pack("<2f", 100.0, 80.0))
    d["."]["windowSize"] = ("windowSize", struct.pack("<2f", 720.0, 420.0))
    d["."]["icgo"] = ("icgo", struct.pack("<?", True))  # grid spacing
    d["."]["lsvD"] = ("lsvD", struct.pack("<I", 0))  # not arranged
    d["."]["iIlS"] = ("iIlS", struct.pack("<I", 96))  # icon size
    d["."]["iItS"] = ("iItS", struct.pack("<I", 13))  # text size
    d["."]["iIso"] = ("iIso", struct.pack("<?", True))  # show item info
    d["."]["iIlp"] = ("iIlp", struct.pack("<?", True))  # icon label position
    
    # Set background image
    # Use the icvo with background image
    d["."]["icvo"] = ("icvo", struct.pack(">I", 0x1))  # icon view options
    
    # Icon positions
    try:
        app_alias = make_bookmark(f"{mount_point}/{APP_PATH}")
        d[APP_PATH][".bckg"] = ("bckg", app_alias)
    except:
        pass
    
    # Actually, let's use a simpler approach for icon positions
    # The DS_Store format stores icon positions in "Iloc" records
    from ds_store._ds_store import _DSStoreEntry
    
    # Iloc format: 4 floats (x, y, 0, 0)
    app_path = f"{APP_PATH}:"
    d[app_path] = ("Iloc", struct.pack("<4f", 160.0, 210.0, 0.0, 0.0))
    
    appl_path = "Applications:"
    d[appl_path] = ("Iloc", struct.pack("<4f", 560.0, 210.0, 0.0, 0.0))

print("DS_Store created")

# Step 5: Detach
subprocess.run(["hdiutil", "detach", mount_point, "-force"], check=True, capture_output=True)
print("Detached")

# Step 6: Convert to read-only compressed DMG
subprocess.run(["rm", "-f", FINAL_DMG])
subprocess.run([
    "hdiutil", "convert", TEMP_RW, "-ov",
    "-format", "UDZO", "-imagekey", "zlib-level=9",
    "-o", FINAL_DMG
], check=True)
print("Converted to UDZO")

# Cleanup
os.unlink(TEMP_RW)

size = os.path.getsize(FINAL_DMG)
print(f"Done: {FINAL_DMG} ({size/1024/1024:.0f} MB)")
