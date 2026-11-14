# v0.37.0 package checklist

- [x] Godot project and Android export preset set to v0.37.0 / version code 39
- [x] GitHub Actions workflow retained
- [x] Approved main bunker artwork retained with fixed hero portrait
- [x] Small roaming avatar removed from the main location
- [x] All nine full-screen room illustrations retained and wired to corrected room hitboxes
- [x] Temporary guest-room placeholder images removed
- [x] Hero portrait has subtle breathing motion in room views
- [x] Dedicated balcony sniper scene added
- [x] Left aim / optical zoom and right single-shot controls wired
- [x] Optical zoom crop and animated targets use the same projection
- [x] Sniper ammunition set to 5 loaded + 25 reserve
- [x] 16-frame transparent zombie walking sprite sheet retained and animated
- [x] Zombie perspective scaling retained
- [x] Autosave and Android lifecycle handling retained
- [x] Static validation passes

The GitHub Actions workflow must still perform Godot import, headless runtime smoke test, Android export, APK verification, and artifact upload.
