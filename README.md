# NeverDrop

A [Road to Vostok](https://store.steampowered.com/app/1963610) mod. When you carry something in front of you, bumping into a wall, a door or furniture no longer knocks it out of your hands. It stays held until you put it down with Place (default G).

- Loose items knocked outside a shelter return in front of you after about two seconds, using the game's item-return effect. Items are also returned before a shelter save so they can be saved safely.
- Mounting weapons, attachments, knives and grenades on a display still works.
- Inventory drops work as normal. Held items and frozen stash or display items are excluded from boundary recovery.

Tested on game 0.2.0.5 (Build 2) with Metro 3.4.1 and 3.4.2. Needs [Metro Mod Loader](https://github.com/ametrocavich/vostok-mod-loader) 3.0 or newer; on Build 2 use Metro 3.4.1 or newer. The carry hook was also verified on 0.1.1.3 and 0.2.0.0.

Recovery uses each shelter's indoor volume with a small edge margin. Items clipped into furniture while their origin remains indoors are outside this boundary check's coverage.

Also on [ModWorkshop](https://modworkshop.net/mod/59110).

## Install

1. Install Metro: put `modloader.gd` and `override.cfg` next to `RTV.exe`.
2. Download `NeverDrop.vmz` from [Releases](https://github.com/TechLuddite/NeverDrop/releases/latest). Do not use the "Source code" zip. Metro rejects it.
3. Put it in the game's `mods` folder, for example `steamapps/common/Road to Vostok/mods/NeverDrop.vmz`.
4. Launch the game, enable NeverDrop on the Mods tab, then launch modded.

To turn it off, disable it on the same tab.

## For modders

The mod replace-hooks `Placer.Collided` through Metro's `placer-collided` hook. On a collision it skips vanilla so the item stays held, except when the item hits a `Display` and is a Weapon, Attachment, Knife or Grenade, where vanilla runs and mounts it. `ShelterReturn.gd` checks loose pickups against stock Indoor areas and calls stock `Killbox.HandleItem`. A non-replacing `Loader.SaveShelter` pre-hook flushes escaped items before stock serialization. No inventory or drop hook is installed.

Build with `python3 scripts/pack.py`, which writes `dist/NeverDrop.vmz`. Merging a `mod.txt` version bump to `main` publishes release `v<version>` automatically.
