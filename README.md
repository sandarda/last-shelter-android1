# Последнее убежище — v0.33.0

Godot 4.3 project for Android (ARM64), with two fixed approved visual references: the full bunker overview and the first-person balcony defense screen. The current package is intended for GitHub Actions to build a debug APK.

## Current playable systems

- Three connected floors aligned with the approved cutaway: upper living level (bedroom, living room, lookout), middle work level (workshop, arsenal, kitchen), lower service level (storage, greenhouse, technical block).
- Calm survivor movement in everyday clothes: red plaid shirt, cargo trousers, boots, no backpack.
- Tap-to-move, keyboard movement, Android virtual joystick, floor-specific walkable regions, and waypoint-based spiral stair transitions.
- Furniture interaction that sends the survivor to the selected object before running the action.
- Survival needs, day clock, weather, inventory, gathering, food, water, crafting, garden, radio, island exploration, injury, morale, upgrades, and journal progression.
- Autosave and persistence of player, inventory, world, island, and defense state.
- Balcony defense with four escalating waves, moving targets, aim-based hit registration, multi-hit enemies in later waves, ammo/reload, shelter breach damage, and rewards.
- Approved full-screen bunker and balcony artwork is used as the fixed visual base; live counters, reticle, character, target actors, and touch controls are layered over it.

## Controls

- **Android:** use the lower-left virtual joystick to walk; tap a clear floor area to move to it; tap interactive furniture to walk up and use it; tap the spiral staircase to travel between floors.
- **Balcony defense:** drag/tap the beach to aim, hold Fire to shoot, Reload to refill the belt, and use the return control to leave the balcony.
- **Desktop:** WASD/arrows to move, mouse click to set a destination, E near the stairs, Space to fire, R to reload, Escape to return from defense.

## Build the APK with GitHub Actions

1. Upload the **contents** of this ZIP to the root of your GitHub repository; keep the hidden `.github` directory.
2. Commit to `main` or `master`, or open **Actions → Last Shelter Android APK → Run workflow**.
3. Wait for the workflow to finish successfully. It runs the static validator, imports the project in headless Godot, runs a short main-scene smoke test, exports a debug-signed ARM64 APK, and uploads `LastShelter-Android` as an artifact.
4. Download the APK from the successful workflow run's **Artifacts** section.

## Verification boundary

The local package has passed the included static project checks and ZIP integrity check. This working environment does not contain the Godot executable or Android export toolchain, so GDScript parsing, actual runtime behavior, device rendering, and APK export are **not yet verified here**. The first successful GitHub Actions run is the required engine/build verification gate. The generated debug APK is for testing, not Play Store publication; production release signing requires a private keystore and GitHub Secrets.

## Project files

- `project.godot` — Godot project settings.
- `scenes/main.tscn` — main scene.
- `scripts/game.gd` — gameplay, UI overlays, movement, survival, and defense logic.
- `art/ui/approved_fullscreen.png` — approved bunker overview.
- `art/ui/approved_balcony.png` — approved first-person balcony defense.
- `art/characters/survivor_sheet.png` — 4×4 transparent survivor animation sheet.
- `tools/validate_project.py` — static package validation.
- `docs/ANDROID_BUILD.md` — detailed GitHub Actions build instructions.
