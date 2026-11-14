# Последнее убежище — v0.39.2

Android survival game built with Godot 4.3. The project is exported as a debug APK by GitHub Actions.

## v0.39.0 gameplay and presentation
- The tiny roaming player sprite is removed from the main location. A large, persistent hero illustration is part of the approved hub artwork; the same hero portrait appears in full-screen room views with a subtle breathing loop.
- The main cliffside bunker screen retains the nine detailed room areas and the warm comic-style art direction. Tapping any room opens its own full-screen room artwork.
- Balcony defense uses a sniper rifle instead of a machine gun. Left button toggles the optical scope, dragging on the beach adjusts aim, and the right button fires one shot. Magazine: 5 rounds; reserve: 25 rounds; `R` reloads.
- Zombies use a 4×4, 16-frame RGBA walking sprite sheet and animate while approaching from the beach. Their rendered size grows with their approach distance.
- The nine standalone room illustrations, room stories, autosave, and Android pause/resume handling are retained.

## Build APK with GitHub Actions
1. Replace the repository contents with this archive, including `.github/workflows`.
2. Commit the files to the `main` branch.
3. Open the repository's **Actions** tab and select **Build Android APK**.
4. Wait for **Import project**, **Smoke-test main scene**, **Build signed debug APK**, and **Upload APK** to finish.
5. Download the `LastShelter-Android` artifact from the successful workflow run.

## Project contents
- `project.godot` — Godot project configuration.
- `scripts/game.gd` — gameplay, room navigation, sniper defense, animation, and save systems.
- `art/ui/approved_fullscreen.png` — approved main bunker artwork with the persistent hero portrait.
- `art/rooms/*.png` — nine independent high-detail full-screen room illustrations.
- `art/characters/hero_portrait.png` — transparent hero portrait used in room views.
- `art/defense/sniper_balcony.png` — dedicated balcony sniper scene background.
- `art/defense/zombie_walk_4x4.png` — transparent 16-frame zombie walk sprite sheet.
- `tools/validate_project.py` — static project and asset integrity checks.
- `docs/UPDATE_GITHUB_V0_37.md` — update instructions.

Static validation does not replace Godot import, runtime smoke testing, or Android export. The GitHub workflow performs those final build steps.


## v0.38.0
Девять интерьерных сцен заменены новыми отдельными изображениями 1536×864. Снайперский боезапас сохраняется после каждого выстрела и перезарядки. См. `docs/UPDATE_GITHUB_V0_38.md`.


## v0.39.0 room artwork replacement
- Replaced all nine full-screen room backplates with separate crops from the user-provided 3×3 reference image: bedroom, living room, lookout, kitchen, greenhouse, laboratory, armory, workshop, and storage.
- Each room image is exported as an individual 1536×864 PNG matching the Godot room viewport.

## v0.39.0 approved room art
- Integrated the nine final room images approved individually by the user. Every room has its own 1536×864 PNG.
- Preserved the existing room navigation, stories, actions, save system, sniper defense, zombie logic, and hub artwork.
- See `docs/UPDATE_GITHUB_V0_39.md`.


## v0.39.2 — все девять утверждённых интерьеров

- Семь оставшихся комнат заменены точными изображениями, присланными и утверждёнными пользователем.
- Спальня и гостиная сохранены из v0.39.1.
- Android version code: 43.

## v0.39.2 — утверждённые спальня и гостиная
- Заменены `art/rooms/bedroom.png` и `art/rooms/living.png` на отдельные изображения, ранее утверждённые пользователем.
- Остальные семь утверждённых комнат и игровые скрипты не изменялись.
- Обновлена версия Android до 0.39.2 (version code 43).
