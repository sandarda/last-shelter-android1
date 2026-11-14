# Shelter architecture — v0.37.0

The project is a single Godot 4.3 Node2D game scene with a script-driven illustrated hub, contextual full-screen room views, and a dedicated balcony-defense mode. The hub retains the approved cliffside cutaway and fixed hero illustration. Nine room hitboxes map to nine separate high-detail room assets.

Room state and story progression are persisted in the save file. Autosave runs periodically and the Android pause/resume lifecycle triggers a save. Balcony defense uses a separate background asset, a 4×4 transparent animated zombie sprite sheet, perspective scaling, aim/zoom projection, hit detection, waves, and a 5+25 ammunition supply.
