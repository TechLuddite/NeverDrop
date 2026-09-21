# Changelog

## 0.2.1

- Fix item loss on weapon swap. In 0.2.0, a swap that displaced an equipped item with nowhere to go (full inventory, or a slot-to-slot swap where the item did not fit the other slot) left it parented to nothing. It was not saved and vanished on the next zone change. The mod now checks the item actually landed in a grid or slot, then tries free inventory space in both rotations, and if there is still no room lets vanilla drop it as a world pickup.

## 0.2.0

- Replace-hooks `Interface.Drop`. Fast Drop, context-menu Drop, drag-off-grid, and closing the inventory while dragging put the item back instead of spawning a world pickup.
- Replace-hooks `Placer.Collided`. Walking into geometry no longer drops a carried item. Place (default G) still puts it down. Display wall-mount is unchanged.
