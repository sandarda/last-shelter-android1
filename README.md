# Последнее убежище — v0.35.0

Godot 4.3 project for Android (ARM64). This package continues the working v0.34.1 build and applies the latest approved visual direction.

## v0.35.0 visual and gameplay update

- Replaced the hub background with the newly approved cliffside-bunker artwork; the former right-side action list is no longer present.
- Rebuilt the nine room backplates from the same approved artwork: bedroom, living room, lookout, laboratory, arsenal, kitchen, greenhouse, workshop, and storage.
- Removed the procedural room fallback: if a room image is missing, the project reports an asset error rather than drawing a primitive placeholder.
- Added a detailed transparent machine-gun turret sprite. The turret rotates toward the player's finger/mouse aim point, with firing flash, recoil, and ejected casings.
- Added a detailed zombie sprite for advancing targets. Zombie scale continues to grow from actual distance travelled from the surf toward the balcony.
- Moved the stair navigation and room movement planes to match the approved bunker composition.
- Preserved survival systems, save data, room stories, four defense waves, manual aiming, hold-to-fire, and infinite belt feed.

## Controls

- **Android hub:** tap a room to enter; use the bottom illustrated command strip for map, security, construction, research, production, inventory, journal, and defense.
- **Movement:** use the virtual joystick or tap a walkable floor area; tap the spiral stair landing to travel between adjacent floors.
- **Rooms:** use the on-screen left/right controls to walk across the room; use the action control for the room's activity; use the shelter control to return.
- **Balcony:** drag a finger across the beach to aim; hold the fire control to shoot. The mounted turret follows the aim direction. No reload is needed.
- **Desktop:** WASD/arrows to move, mouse click to move/aim, E near stairs, Space to fire, Escape to return.

## Build the APK with GitHub Actions

1. Upload the **contents** of this ZIP to the root of the GitHub repository, keeping the hidden `.github` directory.
2. Commit to `main` or `master`, or open **Actions → Last Shelter Android APK → Run workflow**.
3. The workflow runs the static validator, imports the project in headless Godot, runs a short main-scene smoke test, exports an ARM64 debug APK, verifies it, and uploads `LastShelter-Android` as an artifact.
4. Download the APK from the successful workflow run's **Artifacts** section.

## Verification boundary

The included static validator passes. This environment does not contain the Godot executable or Android export toolchain, so GDScript parsing, actual runtime behavior, device rendering, and APK export still require the GitHub Actions run. Do not treat the ZIP as an already-built APK. The debug APK is for device testing; production signing requires a private keystore and GitHub Secrets.

## Key files

- `project.godot` — Godot project settings.
- `scenes/main.tscn` — main scene.
- `scripts/game.gd` — gameplay, movement, UI, room scenes, and balcony defense.
- `art/ui/approved_fullscreen.png` — approved bunker hub artwork without the right-side action list.
- `art/ui/approved_balcony.png` — detailed balcony defense artwork.
- `art/rooms/*.png` — full-screen room backplates for all nine rooms.
- `art/defense/turret.png` — rotating turret artwork.
- `art/defense/zombie.png` — advancing infected artwork.
- `art/characters/survivor_sheet.png` — 4×4 transparent survivor animation sheet.
- `tools/validate_project.py` — static package validation.
- `docs/ANDROID_BUILD.md` — GitHub Actions build instructions.
