#!/usr/bin/env python3
"""Static integrity checks for the Last Shelter Godot prototype.
Does not replace opening/running the project in Godot.
"""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
errors = []
notes = []

def require(condition, message):
    (notes if condition else errors).append(("OK" if condition else "ERROR", message))

project = ROOT / "project.godot"
scene = ROOT / "scenes/main.tscn"
script = ROOT / "scripts/game.gd"
require(project.is_file(), "project.godot exists")
require(scene.is_file(), "main scene exists")
require(script.is_file(), "main GDScript exists")

if project.exists():
    p = project.read_text(encoding="utf-8")
    require('run/main_scene="res://scenes/main.tscn"' in p, "main scene path matches project settings")
    require('config/name="Последнее убежище"' in p, "project title is configured")
    require('config/version="0.33.0"' in p, "project version matches final source package")
if scene.exists():
    s = scene.read_text(encoding="utf-8")
    require('res://scripts/game.gd' in s, "main scene references game.gd")
if script.exists():
    g = script.read_text(encoding="utf-8")
    required_functions = ["_ready", "_process", "_draw", "_save_game", "_load_game",
                          "_use_stairs_up", "_use_stairs_down", "_validate_room_connectivity"]
    for fn in required_functions:
        require(re.search(r"^func\s+" + re.escape(fn) + r"\s*\(", g, re.M) is not None,
                f"required function {fn} exists")
    # Check declared room identifiers and graph links for each floor.
    expected = {"storage", "greenhouse", "techblock", "workshop", "arsenal", "kitchen", "bedroom", "living", "lookout"}
    found = set(re.findall(r'\{"id":"([a-z0-9_]+)"', g))
    require(expected.issubset(found), "all nine planned rooms are declared")
    require('"links"' in g and '"rooms"' in g, "room connectivity data is present")
    require('SAVE_PATH := "user://last_shelter_save.cfg"' in g, "save path uses Godot user data")

concept = ROOT / "art/reference/cliffside_shelter_concept.png"
require(concept.is_file() and concept.stat().st_size > 100_000, "cliffside concept reference is included")
for room_id in ["bedroom", "living", "kitchen", "workshop", "storage", "arsenal", "guest1", "guest2"]:
    asset = ROOT / "art/rooms" / f"{room_id}.png"
    require(asset.is_file() and asset.stat().st_size > 5_000, f"illustrated room asset exists: {room_id}")
survivor = ROOT / "art/characters/survivor_sheet.png"
require(survivor.is_file() and survivor.stat().st_size > 2_000, "animated survivor sprite sheet exists")
if script.exists():
    g = script.read_text(encoding="utf-8")
    require("_load_art_assets" in g and "approved_ui_texture = load(approved_path)" in g and "active_texture: Texture2D = balcony_ui_texture if defense_mode else approved_ui_texture" in g, "approved bunker and balcony full-screen artwork are loaded and rendered")
    require("func _enter_balcony_defense(" in g and "func _leave_balcony_defense(" in g, "balcony defense scene transitions exist")
    require("func _process_defense(" in g and "defense_wave_counts := [8, 12, 16, 20]" in g, "four timed zombie attack waves are implemented")
    require("func _fire_machinegun(" in g and "func _reload_machinegun(" in g, "machine-gun firing and reload actions exist")
    require("func _update_defense_hud(" in g and "ammo_loaded" in g and "ammo_reserve" in g, "dynamic ammunition and defense HUD state exist")
    require("func _add_dynamic_counter(" in g and 'dynamic_counters["health"].text' in g, "survival resource counters update over approved artwork")
    balcony = ROOT / "art/ui/approved_balcony.png"
    require(balcony.is_file() and balcony.stat().st_size > 500_000, "approved first-person balcony defense artwork is included")
    require("_update_facing" in g and "animation_frame" in g, "survivor directional walk animation is wired")
    require("_try_furniture_interaction" in g and "_interact_with_furniture" in g, "furniture hotspots trigger contextual interactions")
    require("_try_stair_navigation" in g and "pending_stair_floor" in g, "stairwell tap navigation is implemented")
    require("func _draw_room_structure(" in g, "reinforced room framing is drawn")
    require("func _draw_room_badge(" in g, "selected room signage is drawn")
    require("art/ui/approved_fullscreen.png" in g and "1536, 864" in g, "approved bunker-and-coast composition is used as the full-screen layer")
    require("func _add_hotspot(" in g and "_add_hotspot(layer" in g, "approved artwork controls have interactive hit areas")
    require("_process_stair_transition" in g and "stair_path_points" in g, "stair movement uses an animated waypoint path")
    require("_begin_stair_transition" in g and "_finish_stair_transition" in g, "stair traversal starts and finishes without an instant floor teleport")
    require("STAIR_LANDINGS" in g and "Vector2(275.0, 485.0)" in g, "stair landings align with the left-side spiral staircase")
    require("Ты спокойно поднимаешься по лестнице" in g and "Ты спокойно спускаешься по лестнице" in g, "stair traversal preserves the relaxed at-home character behavior")

# v0.20 feature wiring checks (static only)
if script.exists():
    g = script.read_text(encoding="utf-8")
    for fn in ["_walkable_rectangles", "_can_stand_at", "_craft_medkit", "_use_medkit"]:
        require(re.search(r"^func\s+" + re.escape(fn) + r"\s*\(", g, re.M) is not None,
                f"v0.20 function {fn} exists")
    require("if _can_stand_at(axis_candidate)" in g, "movement checks room/corridor collision geometry")
    require("ProgressBar.new()" in g and "needs_bars" in g, "survival meters are displayed as progress bars")
    require('cfg.set_value("inventory", "medkits", medkits)' in g, "medkits are persisted in saves")
    require('medkits = maxi(medkits, 0)' in g, "loaded inventory values are sanitized")
    require("ПРОРЫВ!" in g, "breached shelter has a player health consequence")

# v0.21 ten-stage feature checks (static only)
if script.exists():
    g = script.read_text(encoding="utf-8")
    for fn in ["_fish", "_scavenge", "_purify_water", "_upgrade_barricades", "_journal_update"]:
        require(re.search(r"^func\s+" + re.escape(fn) + r"\s*\(", g, re.M) is not None,
                f"v0.21 gameplay action {fn} exists")
    require('weather = ["ЯСНО", "ТУМАН", "ДОЖДЬ", "ВЕТЕР"]' in g, "daily weather variation exists")
    require('weather = ["ЯСНО", "ТУМАН", "ДОЖДЬ", "ВЕТЕР"]' in g and 'minute_of_day' in g, "day/night clock and weather state remain wired under approved art")
    require('noise_level' in g and 'Шум:' in g, "noise attracts threats and is shown in HUD")
    require('purified_water' in g and 'Очистить воду' in g, "water purification and clean-water inventory exist")
    require('barricade_level' in g and 'Улучшить баррикады' in g, "barricade upgrade progression exists")
    require('journal_step' in g and 'Записать в журнал' in g, "survivor journal progression exists")
    require('morale' in g and 'Боевой дух' in g, "morale stat is implemented")
    require('cfg.set_value("world", "weather", weather)' in g and 'cfg.set_value("world", "journal_step", journal_step)' in g, "new survival systems are saved")

# v0.22 ten-stage island-survival systems (static wiring only)
if script.exists():
    g = script.read_text(encoding="utf-8")
    v022_functions = ["_explore_island", "_forage", "_tend_garden", "_craft_spear", "_hunt", "_collect_rainwater", "_use_radio", "_upgrade_workshop", "_treat_injury", "_process_salvage"]
    for fn in v022_functions:
        require(re.search(r"^func\s+" + re.escape(fn) + r"\s*\(", g, re.M) is not None, f"v0.22 system {fn} exists")
    require('cfg.set_value("island", "location", island_location)' in g, "island location is persisted")
    require('cfg.set_value("island", "garden_progress", garden_progress)' in g, "garden progression is persisted")
    require('cfg.set_value("island", "spear_durability", spear_durability)' in g, "weapon durability is persisted")
    require('cfg.set_value("island", "radio_battery", radio_battery)' in g, "radio batteries are persisted")
    require('inventory_label.text = "Дерево %d' in g and 'Ягоды %d' in g, "new resources are visible in inventory HUD")

# v0.23 Android build preparation checks
preset = ROOT / "export_presets.cfg"
workflow = ROOT / ".github/workflows/main.yml"
icon = ROOT / "art/app_icon.png"
build_doc = ROOT / "docs/ANDROID_BUILD.md"
require(preset.is_file() and 'name="Android"' in preset.read_text(encoding="utf-8"), "Android export preset exists")
require(preset.is_file() and 'architectures/arm64-v8a=true' in preset.read_text(encoding="utf-8"), "Android preset targets ARM64")
require(preset.is_file() and 'version/code=33' in preset.read_text(encoding="utf-8") and 'version/name="0.33.0"' in preset.read_text(encoding="utf-8"), "Android version code/name are updated")
require(workflow.is_file() and 'godot --headless --path . --export-debug "Android"' in workflow.read_text(encoding="utf-8") and 'godot --headless --path . --quit-after 5' in workflow.read_text(encoding="utf-8"), "GitHub Actions Android export workflow and runtime smoke test exist")
require(icon.is_file() and icon.stat().st_size > 1000, "application icon asset exists")
require(build_doc.is_file() and "GitHub build" in build_doc.read_text(encoding="utf-8"), "Android build instructions exist")
gitignore = ROOT / ".gitignore"
require(gitignore.is_file() and ".godot/" in gitignore.read_text(encoding="utf-8") and "*.keystore" in gitignore.read_text(encoding="utf-8"), "generated Godot files and signing keys are excluded from Git")
if project.exists():
    ptxt = project.read_text(encoding="utf-8")
    require('window/handheld/orientation=4' in ptxt, "mobile landscape orientation configured")
    require('window/stretch/aspect="keep"' in ptxt, "16:9 composition preserved on mobile displays")
if script.exists():
    g = script.read_text(encoding="utf-8")
    require("AUTOSAVE_INTERVAL := 60.0" in g and "_save_game_silent()" in g, "periodic autosave is wired")
    require("NOTIFICATION_APPLICATION_PAUSED" in g and "NOTIFICATION_APPLICATION_RESUMED" in g, "mobile pause/resume lifecycle is handled")

# v0.33 movement and defense gameplay checks (static wiring only)
if script.exists():
    g = script.read_text(encoding="utf-8")
    require("FLOOR_CENTERS_Y := [620.0, 420.0, 220.0]" in g, "each floor has its own visible movement plane")
    require('"id":"greenhouse"' in g and '"id":"techblock"' in g and '"id":"lookout"' in g, "room graph matches the three floors in the approved bunker artwork")
    require("room_rects.clear()" in g and "room_rects.append(r)" in g, "room interaction rectangles are populated on every floor")
    require("event.index == joystick_touch_index" in g and "_update_virtual_joystick(event.position)" in g, "Android virtual joystick touch tracking is wired")
    require("var source := Rect2(float(animation_frame) * 128.0, float(facing_row) * 160.0, 128.0, 160.0)" in g, "high-resolution casual survivor sprite animation is rendered")
    require("defense_targets.append" in g and "aim_position.distance_to(target_pos)" in g, "zombie targets spawn and shots require aiming accuracy")
    require('"hp": 1 if defense_wave < 3 else 2' in g, "late-wave armored zombies require multiple hits")
    require('"lookout":\n\t\t\t_enter_balcony_defense()' in g, "lookout room interaction enters the dedicated balcony defense mode")
    require("pos.y >= 625.0" in g and "defense_targets.remove_at(i)" in g, "escaped zombies damage the shelter and leave the active wave")
    require("var reticle_radius := 14.0 if zoom_mode" in g, "aim and zoom modes change the on-screen reticle")

sprite = ROOT / "art/characters/survivor_sheet.png"
if sprite.exists():
    try:
        from PIL import Image
        with Image.open(sprite) as im:
            require(im.size == (512, 640) and im.mode == "RGBA", "survivor sprite sheet is 4x4 high-resolution transparent RGBA")
    except Exception:
        require(False, "survivor sprite sheet can be decoded")

print("LAST SHELTER — STATIC PROJECT CHECK")
for status, message in notes + errors:
    print(f"[{status}] {message}")
print(f"\n{len(notes)} passed, {len(errors)} failed")
if errors:
    sys.exit(1)
print("NOTE: Static checks do not validate GDScript parsing, runtime behavior, rendering, or Android export.")

