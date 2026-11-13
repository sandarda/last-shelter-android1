# Shelter architecture — v0.36.0

The project uses a fixed, illustrated cliffside bunker hub. The hero is represented by a large permanent portrait in the hub art rather than a tiny roaming character. Room taps open separate full-screen illustrations.

## Art assets
- `art/ui/approved_fullscreen.png` — current hub artwork and persistent hero illustration.
- `art/rooms/` — nine full-screen room images.
- `art/characters/hero_portrait.png` — transparent hero portrait for room scenes.
- `art/defense/zombie_walk_4x4.png` — 16-frame RGBA zombie walk cycle.
- `art/defense/zombie.png` — fallback infected artwork.

## Gameplay systems
- Survival resources and existing save migration remain in `scripts/game.gd`.
- Sniper defense uses a 5-round magazine and 25-round reserve, with manual aiming, optical zoom, single-shot firing, and reload.
- Zombies advance along the beach, animate through the sprite sheet, and scale with their distance from the shelter.
- Room stories and progress remain stored in the existing save file.
