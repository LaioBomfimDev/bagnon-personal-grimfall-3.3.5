# Bagnon — Grimfall (3.3.5a)

A small adaptation of the classic **Bagnon** (originally by Tuller) so it runs correctly on Grimfall's 3.3.5a client, plus a level-based layout added on top to make gear organization easier while leveling.

## Install

1. Download/clone this repo.
2. Copy these folders into `Interface/AddOns/`:
   - `Bagnon` (required)
   - `Bagnon_Config` — options window
   - `Bagnon_GuildBank` — guild bank window
   - `Bagnon_Tooltips` — tooltip enhancements
   - `Bagnon_VoidStorage` — void storage window
   - `Bagnon_Forever` — remembers item/frame state across sessions
3. Fully restart the WoW client (not just `/reload`).
4. Enable all of them on the character-select AddOns screen.

## What's added on top of stock Bagnon

- **Level Group layout** — bags and bank are grouped into level bands (1-9, 10-19, 20-29... up to 60+) instead of one flat grid, and every item shows the level required to use it right on its icon.
- **One-click toggle** — switch between the normal Bagnon view and the Level Group view. Stock Bagnon's own layout is still great for a lot of things, so both are kept instead of losing one for the other.
- **Equipment type filter** — Cloth / Leather / Mail / Plate / Weapon 1H / Weapon 2H. Narrows the Level Group view to one gear type at a time, so comparing upgrades in one slot is easier.
- **Level-aware cleanup** — the physical "clean items" sort button now follows the same level-band order when Level Group is on, instead of sorting against it.
- Both toggle buttons live in the left button row of the title bar (next to sort/search), so they stay visible even with bag-skinning addons like DragonUI active.

## Usage

- `/bagnon` or `/bgn` — open the bag window (see all commands with `/bagnon ?`).
- `/bagnon level` — toggle Level Group grouping for both bags and bank.
- The title bar of the bag/bank window has two extra buttons: one toggles Level Group, the other opens the equipment type filter menu.

## Version history

- **v1.0 — Base fix + Level Group**
  - Fixed stock Bagnon so it actually loads and runs on Grimfall's 3.3.5a client.
  - Added the Level Group layout: bags and bank grouped into level bands (1-9 up to 60+).
  - Added the required level shown on each item icon.
  - Added a one-click toggle between the normal Bagnon view and Level Group.
- **v1.1 — Equipment type filter**
  - Added a filter (Cloth / Leather / Mail / Plate / Weapon 1H / Weapon 2H) to narrow the Level Group view to one gear type at a time.
- **v1.2 — Bug fixes + full addon suite**
  - Found: switching back to the normal view left the level band headers stuck on screen. Fixed.
  - Found: sorting while in Level Group view left items looking randomly placed until the bag was closed and reopened. Fixed — the grouped view now updates in real time as items move.
  - Found: bag-skinning addons like DragonUI redraw the top-right corner, hiding our buttons there. Fixed — both buttons moved into the left button row instead.
  - Added the full companion addon suite to the download: Config, GuildBank, Tooltips, VoidStorage, Forever.
- **v1.3 — Dungeon-scaled item levels**
  - Found: some dungeon-scaled items (the same item, dropped at a different level) showed in the wrong level band — their static item data stayed wrong even after a full client restart.
  - Fixed: now reads the real required level from the tooltip text itself when the game's stored item data disagrees with it.

## Credit

All credit to Tuller and the Bagnon contributors for the original addon. This repo is just a compatibility fix plus the Level Group layer on top, adapted for Grimfall's 3.3.5a client.
