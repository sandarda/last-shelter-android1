# Room storylines — v0.34.0

Each room is entered as a full-screen scene. The player can move left/right along the floor, activate the room's contextual action, return with the yellow “УБЕЖИЩЕ” button, or use “К ЛЕСТНИЦЕ” to reach the stair landing.

| Room | Story thread | Main activity |
|---|---|---|
| Bedroom | The survivor's old diary and personal memories | Rest, morale and diary entries |
| Living room | Radio recordings and the safe heart of the shelter | Spend time by the fireplace and restore morale |
| Kitchen | Rationing and food preparation | Cook meals |
| Workshop | Repairing tools and building equipment | Work and maintain equipment |
| Storage | Inventory control and preparation for expeditions | Review food, water, wood and metal reserves |
| Armory | Readiness and maintenance of defensive equipment | Inspect and service weapons |
| Greenhouse | Food autonomy and plant care | Tend the garden |
| Technical block | Filters, pumps and life-support systems | Purify water |
| Lookout | Watch the lagoon and detect threats | Enter the dedicated balcony defense mode |

Room story action counts are saved in `user://last_shelter_save.cfg` under the world quest flags.

## Three-stage narrative arcs

- **Bedroom — The owner's diary:** the first days in the cliff shelter; a hidden photograph and note; the hero decides to preserve his personal history.
- **Living room — A signal in the static:** a pre-apocalypse radio recording; a repeating signal hidden in interference; a possible sign of other survivors is logged.
- **Kitchen — The ration book:** inventory and spoilage review; an old recipe is recovered; a practical multi-day meal plan is prepared.
- **Workshop — The failing pump:** a worn pump component is identified; a replacement is fashioned from scrap; the workbench is ready for harder repairs.
- **Storage — The missing crate:** stock records do not match; a forgotten cache is discovered; supplies are reorganized and expedition kits prepared.
- **Armory — Keeping the weapons ready:** worn parts are found; the weapons are serviced; defensive readiness is recorded.
- **Greenhouse — First harvest:** healthy seedlings are found; irrigation and planting are restored; the first small harvest improves food autonomy.
- **Technical block — Clean water:** a clogged filter is diagnosed; the pump and cartridge are serviced; clean water production is restored.
- **Lookout — A signal by the yacht:** a faint reflection is spotted offshore; movement is seen approaching through the water; the hero raises the alarm and enters the turret defense mode.

Each action advances the relevant room's story counter up to three stages. The stage counter is stored with the normal save data.
