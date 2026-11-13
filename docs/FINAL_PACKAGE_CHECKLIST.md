# v0.36.0 final package checklist

- [x] Godot project and Android export preset set to v0.36.0 / version code 38
- [x] GitHub Actions workflow retained
- [x] New main hub artwork includes the fixed hero portrait
- [x] Tiny roaming avatar is no longer drawn on the main map
- [x] All nine standalone room illustrations retained and directly tappable
- [x] Hero portrait asset included for room scenes
- [x] Sniper rifle replaces the machine gun; left aim and right single-shot controls wired
- [x] 5-round magazine and 25-round reserve with manual reload
- [x] 16-frame transparent zombie walking sprite sheet included and animated
- [x] Perspective scaling of approaching zombies retained
- [x] Autosave and Android lifecycle handling retained
- [x] Static project validator passes

The GitHub Actions workflow must still perform Godot import, headless runtime smoke test, Android export, APK verification, and artifact upload.
