# NeverDrop

A [Road to Vostok](https://store.steampowered.com/app/1963610) mod. Inventory drop and world collision drop are blocked. Place (default G) still puts an item down, and display wall-mount still works.

Written against game version 0.1.1.3. Requires [Metro Mod Loader](https://github.com/ametrocavich/vostok-mod-loader) 3.0 or newer.

## Install

1. Install Metro if you have not already. Put `modloader.gd` and `override.cfg` next to `RTV.exe`.
2. Download `NeverDrop.vmz` from [Releases](https://github.com/TechLuddite/NeverDrop/releases/latest). Do not use GitHub's "Source code" zip; Metro will reject it.
3. Copy `NeverDrop.vmz` into the game `mods` folder:

   ```
   <Steam library>/steamapps/common/Road to Vostok/mods/NeverDrop.vmz
   ```

4. Launch the game, enable NeverDrop on the Mods tab, then launch modded.

Disable it in that same tab to restore vanilla drop.

## What it changes

Vanilla inventory drop all goes through `Interface.Drop`: Fast Drop, the context-menu Drop action, releasing a drag off a grid, closing the inventory while an item is dragged, and a few overflow paths. The mod replace-hooks that method and returns the item to inventory instead of spawning a pickup.

Vanilla world carry drops the held item on any collision (`Placer.Collided`). The mod skip_supers that branch so the item stays in hand until Place. If the collider is in group `Display` and the item is a Weapon, Attachment, Knife, or Grenade, vanilla Collided still runs so wall-mount keeps working.

Death does not drop loot in 0.1.1.3. This mod does not touch death.

## Build

From the repo root:

```bash
python3 scripts/pack.py
```

That writes `dist/NeverDrop.vmz`. The archive root is `mod.txt`, then `mods/NeverDrop/Main.gd`. LICENSE is packed as `NeverDrop_LICENSE` so it does not mount over `res://LICENSE`.

## Releases

Version lives in `mod.txt`. Merging a version bump to `main` is what publishes: GitHub Actions packs the `.vmz`, and if `v<version>` does not already exist it creates that tag and attaches the archive. Merging without a bump rebuilds the CI artifact and leaves the current release alone.

There is no need to create tags by hand.
