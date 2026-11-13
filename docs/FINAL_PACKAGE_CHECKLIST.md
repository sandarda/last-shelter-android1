# Final handoff checklist — v0.35.0

## Included in this source package
- Godot 4.3 project and main scene, Android ARM64 export preset, and GitHub Actions workflow.
- Updated approved bunker hub artwork without the right-side action list.
- Full-screen image backplates for all nine rooms: bedroom, living room, lookout, laboratory, arsenal, kitchen, greenhouse, workshop, and storage.
- No procedural fallback for room interiors; missing room art raises an asset error instead of showing primitive placeholders.
- Transparent 4×4 survivor animation sheet: casual clothes, no backpack.
- Detailed transparent turret artwork, manual horizontal aiming, hold-to-fire, recoil, muzzle flash, and ejected casings.
- Textured zombie actors with distance-based perspective scaling from the waterline toward the balcony.
- Repositioned room interaction areas and stair traversal aligned to the approved bunker image.
- Existing survival systems, room story progress, autosave, and four defense waves.

## Checks completed in this environment
- `python3 tools/validate_project.py`: 120 passed, 0 failed.
- PNG assets are present; defense turret and zombie images are RGBA.
- GitHub Actions workflow includes static validation, headless Godot import, smoke test, ARM64 debug APK export, and artifact upload.

## Checks still required on GitHub
This environment does not contain the Godot executable or Android export toolchain. GDScript parsing, runtime behavior, device rendering/touch response, and APK export are therefore **not confirmed locally**. A successful GitHub Actions run is the final technical acceptance gate.

## Upload steps
1. Download and extract this archive.
2. Open the extracted `last_shelter_v0_35_0` folder.
3. Upload all contents to the root of the GitHub repository, including the hidden `.github` folder and `.gitignore`.
4. Commit/push to `main` or `master`.
5. Open GitHub → Actions → Last Shelter Android APK.
6. When the run succeeds, download `LastShelter-Android` under Artifacts.

The exported APK is debug-signed for device testing, not Play Store publication. Production signing requires a private release keystore and GitHub Secrets.
