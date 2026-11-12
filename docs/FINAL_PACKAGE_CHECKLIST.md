# Final handoff checklist — v0.33.0

## Included in this source package
- Godot 4.3 project and main scene.
- The approved bunker overview and first-person balcony defense artwork.
- A three-floor room graph aligned to the approved image: bedroom/living/lookout; workshop/arsenal/kitchen; storage/greenhouse/technical block.
- A transparent 4×4 survivor animation sheet: casual plaid shirt, everyday trousers and boots, no backpack.
- Floor-specific walkable areas, touch joystick tracking, tap-to-move, furniture approach/interact behavior, and animated stair waypoint traversal.
- Survival needs, time/weather, resources, crafting, gardening, radio, exploration, journal, injury, morale, upgrades, and persistent save data.
- Balcony combat with moving target actors, aim-based hit detection, later-wave multi-hit enemies, ammunition/reload, breach damage, and wave rewards.
- ARM64 Android export preset and GitHub Actions workflow.

## Checks completed in this environment
- `python3 tools/validate_project.py`: 105 passed, 0 failed.
- GitHub Actions YAML parsed successfully.
- All `res://` asset references resolve to files in the project.
- Artwork and sprite assets decode; sprite sheet is 512×640 RGBA.
- ZIP archive integrity checked after packaging.

## Checks still required on GitHub
This working environment does not contain Godot or the Android export toolchain. GDScript parsing, runtime behavior, device rendering/touch response, and APK export have therefore **not** been confirmed locally. The workflow first validates the source, then imports the project in headless Godot, launches a short smoke test, exports a debug-signed ARM64 APK, and uploads it as `LastShelter-Android`. A green Actions run is the final technical acceptance gate.

## Upload steps
1. Download and extract this archive.
2. Open the extracted `last-shelter-android-main` folder.
3. Upload all contents to the root of the GitHub repository, including the hidden `.github` folder and `.gitignore`.
4. Commit/push to `main` or `master`.
5. Open GitHub → Actions → Last Shelter Android APK.
6. When the run succeeds, download `LastShelter-Android` under Artifacts.

The generated APK is debug-signed for device testing, not Play Store publication. Production signing requires a private release keystore and GitHub Secrets.
