# Approved interface implementation — v0.30

The full-screen user-approved 1536x864 artwork is now the actual in-game visual layer (`art/ui/approved_fullscreen.png`), not a concept-only reference or a newly drawn approximation.

Godot `Control` hit areas are placed over the illustrated controls so the existing survival logic remains callable:
- Left rail: shelter, craft, inventory, radio, map, tasks, diary, development.
- Room hotspots: bedroom, living room, lookout, workshop, armory, kitchen, storage, greenhouse, technical block.
- Right panel: objectives and threat response.
- Bottom row: gather resources, scouting, upgrades, research, defense, rest.

The design viewport is 1536x864 (16:9) and scales through the existing `canvas_items` stretch mode for Android. The art is kept intact; interaction is implemented as transparent clickable regions over the matching illustrated elements.

The art itself contains a static presentation of values and objectives. Runtime numeric overlays and dynamic task rendering are a follow-up integration task; game state and save logic continue to operate underneath.


## v0.32 — relaxed survivor and stair traversal

The survivor approaches the spiral staircase on the left side of the approved bunker artwork, then follows a multi-waypoint switchback path for both ascent and descent. Floor changes occur only after the traversal animation reaches the destination landing; there is no instant floor teleport. The character keeps the calm, at-home movement pace and uses the existing directional walk-cycle frames.


## v0.33 — movement presentation

The survivor is rendered as a transparent 4×4 directional sprite sheet, wearing a red plaid shirt, everyday trousers, and boots; there is no backpack. The lower-left touch joystick is tracked by touch index so the movement axis remains stable until that finger is released. The three floor walkable planes align to the bunker artwork: lower level at y=620, residential level at y=420, upper level at y=220.
