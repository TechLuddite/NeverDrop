# NeverDrop

A [Road to Vostok](https://store.steampowered.com/app/1963610) mod. When you carry something in front of you, bumping into a wall, a door or furniture no longer knocks it out of your hands. It stays held until you put it down with Place (default G).

- Mounting weapons, attachments, knives and grenades on a display still works.
- Your inventory is untouched. Dropping items from it works as normal.

Works with game version 0.1.1.3. Needs [Metro Mod Loader](https://github.com/ametrocavich/vostok-mod-loader) 3.0 or newer.

## Install

1. Install Metro: put `modloader.gd` and `override.cfg` next to `RTV.exe`.
2. Download `NeverDrop.vmz` from [Releases](https://github.com/TechLuddite/NeverDrop/releases/latest). Do not use the "Source code" zip. Metro rejects it.
3. Put it in the game's `mods` folder, for example `steamapps/common/Road to Vostok/mods/NeverDrop.vmz`.
4. Launch the game, enable NeverDrop on the Mods tab, then launch modded.

To turn it off, disable it on the same tab.

## For modders

The mod replace-hooks one method, `Placer.Collided`, through Metro's `placer-collided` hook. On a collision it skips vanilla so the item stays held, except when the item hits a `Display` and is a Weapon, Attachment, Knife or Grenade, where vanilla runs and mounts it.

Build with `python3 scripts/pack.py`, which writes `dist/NeverDrop.vmz`. Merging a `mod.txt` version bump to `main` publishes release `v<version>` automatically.
