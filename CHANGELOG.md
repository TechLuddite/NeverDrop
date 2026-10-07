# Changelog

## 0.3.2

- Return loose items that remain outside a shelter's indoor volumes for about two seconds, including items that settle after a collision. Reuse the stock return effect, message, and audio; preserve item data and stored contents.
- Return escaped loose items before shelter serialization, preventing stock's below-map position check from omitting them during a transition.
- Use the six shelters' actual convex volumes (Attic, Bunker, Cabin, Classroom, Garage, Tent), including Cabin's and Garage's sloped roofs, with a 0.2 m edge margin. Exclude held and frozen items, placed furniture, and ordinary game zones.
- Keep Place, display mounting, and inventory drop mechanics unchanged. Boundary recovery does not detect items clipped into furniture while their origin stays indoors.
- Tested on game 0.2.0.5 (Steam build 25710663). Headless physics and Metro hook tests pass on Godot 4.6.3 with Metro 3.4.1 and 3.4.2. Played on 3.4.1 with no script errors, and loads cleanly on 3.4.2.

## 0.3.1

- Verified on game Build 2 (0.2.0.0) with Metro 3.4.1. `Placer.gd` is unchanged in Build 2, so the mod code is unchanged.
- Declare the ModWorkshop listing (`[updates] source="modworkshop:59110"`) so Metro can check for updates.

## 0.3.0

- Remove the `Interface.Drop` hook. The mod no longer changes inventory drop: Fast Drop, context-menu Drop, drag-off-grid, and closing the inventory while dragging all behave as vanilla again. That hook was never meant to be part of the mod.
- Collision drop handling (`Placer.Collided`) is unchanged.

## 0.2.1

- Fix item loss on weapon swap. In 0.2.0, a swap that displaced an equipped item with nowhere to go (full inventory, or a slot-to-slot swap where the item did not fit the other slot) left it parented to nothing. It was not saved and vanished on the next zone change. The mod now checks the item actually landed in a grid or slot, then tries free inventory space in both rotations, and if there is still no room lets vanilla drop it as a world pickup.

## 0.2.0

- Replace-hooks `Interface.Drop`. Fast Drop, context-menu Drop, drag-off-grid, and closing the inventory while dragging put the item back instead of spawning a world pickup.
- Replace-hooks `Placer.Collided`. Walking into geometry no longer drops a carried item. Place (default G) still puts it down. Display wall-mount is unchanged.
