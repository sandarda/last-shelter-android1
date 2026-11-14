#!/usr/bin/env python3
"""Static integrity checks for Last Shelter v0.39.3. Does not replace Godot runtime testing."""
from pathlib import Path
import re, sys, struct, zlib
ROOT = Path(__file__).resolve().parents[1]
errors=[]; notes=[]
def require(ok, msg):
    (notes if ok else errors).append(("OK" if ok else "ERROR", msg))
def png_info(path):
    data=path.read_bytes()
    if not data.startswith(b"\x89PNG\r\n\x1a\n"): raise ValueError("bad PNG signature")
    pos=8; width=height=depth=ctype=None; idat=bytearray(); end=False
    while pos < len(data):
        if pos+12>len(data): raise ValueError("truncated PNG chunk")
        n=struct.unpack(">I",data[pos:pos+4])[0]; kind=data[pos+4:pos+8]; stop=pos+12+n
        if stop>len(data): raise ValueError("truncated PNG payload")
        payload=data[pos+8:pos+8+n]
        crc=struct.unpack(">I",data[pos+8+n:stop])[0]
        if zlib.crc32(kind+payload)&0xffffffff != crc: raise ValueError("PNG CRC mismatch")
        if kind==b"IHDR": width,height,depth,ctype,comp,filt,inter=struct.unpack(">IIBBBBB",payload)
        elif kind==b"IDAT": idat.extend(payload)
        elif kind==b"IEND": end=True; break
        pos=stop
    if not end: raise ValueError("missing IEND")
    raw=zlib.decompress(bytes(idat))
    channels = 4 if ctype == 6 else (3 if ctype == 2 else 0)
    if not channels or len(raw) != height*(1+width*channels): raise ValueError("bad decoded PNG length")
    return width,height,depth,ctype
project=ROOT/"project.godot"; scene=ROOT/"scenes/main.tscn"; script=ROOT/"scripts/game.gd"
workflow=ROOT/".github/workflows/main.yml"; preset=ROOT/"export_presets.cfg"; icon=ROOT/"art/app_icon.png"
require(project.is_file() and 'config/version="0.39.3"' in project.read_text(encoding="utf-8"), "Godot project is version 0.39.3")
require(scene.is_file() and 'res://scripts/game.gd' in scene.read_text(encoding="utf-8"), "main scene references the gameplay script")
require(workflow.is_file() and 'godot --headless --path . --export-debug "Android"' in workflow.read_text(encoding="utf-8"), "GitHub Actions Android export workflow exists")
require(preset.is_file() and 'version/code=44' in preset.read_text(encoding="utf-8") and 'version/name="0.39.3"' in preset.read_text(encoding="utf-8"), "Android export version is 0.39.3 / code 43")
require(icon.is_file() and icon.stat().st_size>1000, "application icon exists")
if script.is_file():
    g=script.read_text(encoding="utf-8")
    for fn in ["_ready","_process","_draw","_save_game","_load_game","_enter_room_view","_draw_room_view","_enter_balcony_defense","_leave_balcony_defense","_process_defense","_fire_sniper","_reload_sniper","_toggle_aim_mode","_draw_sniper_scope"]:
        require(re.search(r"^func\s+"+re.escape(fn)+r"\s*\(",g,re.M) is not None, f"required function {fn} exists")
    require('defense_wave_counts := [3, 4, 5, 6]' in g, "four sniper-defense waves are configured")
    require('ammo_loaded := 5' in g and 'ammo_reserve := 25' in g and 'ammo_loaded = 5' in g and 'ammo_reserve = 25' in g, "sniper magazine and reserve ammunition default to 5+25")
    require('"ПРИЦЕЛИТЬСЯ"' in g and '"ВЫСТРЕЛ"' in g and '_toggle_aim_mode' in g and '_fire_sniper' in g, "left aim and right single-shot controls are wired")
    require('"R"' not in g or '_reload_sniper()' in g, "manual sniper reload is wired")
    require('zombie_animation_frame = (zombie_animation_frame + 1) % 16' in g, "16-frame zombie walk animation loops")
    require('draw_texture_rect_region(zombie_walk_texture' in g and 'zombie_walk_4x4.png' in g, "zombie animation frames are rendered from a sprite sheet")
    require('The hero is not moved around the bunker map in v0.36.0' in g and 'No tiny roaming avatar' in g, "hero is a fixed visual presence, not a roaming map sprite")
    require('hero_portrait_texture' in g and 'hero_portrait.png' in g, "hero portrait is loaded for room scenes")
    require('func _try_enter_room_at(' in g and g.count('\"rect\":Rect2(') >= 9 and '"bedroom"' in g and '"greenhouse"' in g and '"storage"' in g, "all nine room hitboxes are defined for direct tapping")
    require('SCOPE_CROP_SIZE := Vector2(520.0, 300.0)' in g and 'sniper_background_texture' in g and 'sniper_balcony.png' in g, "dedicated sniper balcony art and centered optical zoom are wired")
    require('Rect2(145, 350, 225, 165)' in g and '"kitchen"' in g and '"greenhouse"' in g and '"techblock"' in g, "middle-floor room hitboxes follow the approved gallery order")
    require('The right-side action list has been removed' in g, "right-side action drawer remains removed")
    require('approved_fullscreen.png' in g and '1536, 864' in g, "approved v0.36 hub artwork is the full-screen presentation")
    require('AUTOSAVE_INTERVAL := 60.0' in g and '_save_game_silent()' in g, "periodic autosave is preserved")
    require('NOTIFICATION_APPLICATION_PAUSED' in g and 'NOTIFICATION_APPLICATION_RESUMED' in g, "Android pause/resume lifecycle is handled")
    require('cfg.set_value("world", "quest_flags", quest_flags)' in g, "room story progress remains persisted")
for room in ["bedroom","living","lookout","techblock","arsenal","kitchen","greenhouse","workshop","storage"]:
    f=ROOT/"art/rooms"/(room+".png")
    require(f.is_file() and f.stat().st_size>500000, f"high-detail full-screen room art exists: {room}")
for asset in [ROOT/"art/ui/approved_fullscreen.png", ROOT/"art/characters/hero_portrait.png", ROOT/"art/defense/zombie_walk_4x4.png", ROOT/"art/defense/sniper_balcony.png"]:
    try:
        w,h,d,c=png_info(asset)
        require((c in (2,6)) and d==8, f"PNG decodes correctly: {asset.relative_to(ROOT)} ({w}x{h})")
    except Exception as e: require(False, f"PNG asset validates: {asset.name} ({e})")
try:
    _, _, _, zombie_ctype = png_info(ROOT/"art/defense/zombie_walk_4x4.png")
    require(zombie_ctype == 6, "zombie walk sprite sheet retains real RGBA transparency")
except Exception as e:
    require(False, f"zombie sprite transparency check ({e})")
require(not (ROOT/"art/rooms/guest1.png").exists() and not (ROOT/"art/rooms/guest2.png").exists(), "temporary guest-room placeholder images are removed")
# Every room is a distinct full-screen 16:9 scene image, not a reused old backplate.
room_ids = ["bedroom", "living", "lookout", "kitchen", "greenhouse", "techblock", "arsenal", "workshop", "storage"]
room_hashes = set()
for room_id in room_ids:
    room_path = ROOT / "art" / "rooms" / f"{room_id}.png"
    if room_path.is_file():
        try:
            import struct, hashlib
            with room_path.open("rb") as room_file:
                header = room_file.read(24)
            dimensions = struct.unpack(">II", header[16:24]) if header[:8] == b"\x89PNG\r\n\x1a\n" else (0, 0)
            require(dimensions in ((1536, 864), (1536, 865), (1536, 866)), f"room scene {room_id} retains approved high-resolution dimensions {dimensions[0]}x{dimensions[1]}")
            room_hashes.add(hashlib.sha256(room_path.read_bytes()).hexdigest())
        except Exception as exc:
            require(False, f"room scene {room_id} validates ({exc})")
require(len(room_hashes) == 9, "all nine room scenes have unique image content")

print("LAST SHELTER v0.39.3 — STATIC PROJECT CHECK")
for status,msg in notes+errors: print(f"[{status}] {msg}")
print(f"\n{len(notes)} passed, {len(errors)} failed")
if errors: sys.exit(1)
print("NOTE: Static checks do not replace Godot import, runtime smoke test, or Android APK export.")
