# Upload v0.34.0 to GitHub

1. Download and extract the complete `last_shelter_v0_34_0_github.zip` archive.
2. Open the extracted `last-shelter-android-main` folder.
3. In the repository's `main` branch, replace the project files with the contents of this folder. Keep the folder contents at the repository root; do not upload the enclosing folder as an extra nested directory.
4. Confirm `.gitignore`, `project.godot`, `export_presets.cfg`, `scenes/`, `scripts/`, `art/`, `tools/`, and `.github/` are all at the repository root.
5. Commit the update. GitHub Actions should start automatically.
6. Wait for the Godot import, headless smoke test, Android export, APK verification, and artifact upload steps.

The package increments Android version code to 35 and app version to 0.34.0 so it can be installed as an update over the previously built 0.33.x APK.

The bundled `validation_report.txt` records 113 passing static checks. This report is not a substitute for the Godot import, runtime smoke test, or actual Android export in GitHub Actions.


## v0.34.1 — Zombie perspective scale

Replace the project with this package to use distance-based zombie scaling. Each zombie records its own water spawn Y coordinate and starting scale. Its scale then follows smoothstep progress from that spawn line to the balcony breach line (Y=640), reaching 1.55x at the foreground. Scaling is based on travelled distance, not elapsed time. Android version code: 36; version name: 0.34.1.
