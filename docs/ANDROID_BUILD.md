# GitHub build instructions
# Android APK build — Last Shelter 0.33

## Included automation
`.github/workflows/main.yml` builds a **debug-signed ARM64 APK** with Godot 4.3 and Java 17. It runs when code is pushed to `main`/`master`, or manually from GitHub Actions using **Run workflow**.

The workflow:
1. Checks out the repository.
2. Installs Java 17 and Android SDK platform/build tools plus the pinned NDK.
3. Installs Godot 4.3 and matching export templates.
4. Configures Android SDK/JDK paths and a temporary debug keystore.
5. Imports the project and runs a headless scene smoke test.
6. Exports `build/LastShelter.apk` using the `Android` preset.
7. Uploads the APK as the `LastShelter-Android` workflow artifact.

## Build from GitHub
1. Create or open the GitHub repository.
2. Upload the **contents** of this ZIP to the repository root (the `.github` folder must remain present).
3. Commit/push to `main` (or `master`).
4. Open **Actions → Last Shelter Android APK**.
5. Wait for the green successful run, open it, and download **LastShelter-Android** under Artifacts.

## Signing
The workflow creates a temporary debug keystore. This APK is for installation/testing, not Play Store publication. Do not commit signing keys or passwords. A separate private release keystore and GitHub Secrets are required for a release build.

## Verification boundary
The source package has static project checks. Godot parsing, runtime behavior, rendering, and APK export must be confirmed by the GitHub Actions run. This working environment does not have Godot or the Android export toolchain installed, so no APK is included here and no successful build is claimed.


## Static validation and runtime gate

GitHub Actions runs `python3 tools/validate_project.py` before importing the project. It then imports the project in headless Godot, launches the main scene for a short smoke test, and exports a signed debug APK for ARM64. A successful ZIP/static check is not an APK build; use the green GitHub Actions result and the uploaded `LastShelter-Android` artifact as the release gate.
