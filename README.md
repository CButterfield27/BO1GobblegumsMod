# BO1 GobbleGum MOD

---

## Solo Easter Mods

This project merges the Solo Easter Egg mods with the GobbleGum system. Only integration and compatibility updates were made here.

### Ascension

1. All four monkey-round buttons must be pressed within roughly 100 seconds of the first press.
2. The LUNA step auto-completes.
3. Final step: throw a Gersh Device at the light sphere and shoot it with a **Pack-a-Punched Thundergun** (Ray Gun no longer works).

### Call of the Dead

1. Unchanged from the original solo Easter Egg.
   The full sequence works normally with this mod active.

### Shangri-La

1. Activate all four stone switches in spawn quickly to trigger eclipse mode.
2. The stone-matching step auto-completes a few seconds after interacting with the explorers' dialogue switch.
3. For the waterslide pressure plate step, only one player needs to stand on the plate after pulling the slide switch.

### Moon

1. **Important:** Restart until spawning as Richtofen — he must hold the Golden Rod in the lower-right HUD corner.
2. Once playing as Richtofen, complete the Easter Egg as in co-op.
   *Note:* Mods that alter `common_zombie_patch.ff` may prevent picking up the P.E.S. on Moon.

---

## QOL Improvements

### Perma Perk Rewards (Ascension, Der Riese, Call of the Dead)

These Easter Eggs now grant a **permanent perk reward** upon completion.


| Map Script                     | Trigger                                                           | Behavior                                                            |
| ------------------------------ | ----------------------------------------------------------------- | ------------------------------------------------------------------- |
| **zombie_cod5_factory.gsc**    | `play_sound_2d("sam_fly_last")` when `level.flytrap_counter == 3` | Local perma perk reward; duplicate-safe and per-player threaded.    |
| **zombie_cosmodrome_eggs.gsc** | `wait_for_gersh_vox()` → `reward_wait()`                          | Same perma perk logic, guarded threads, no external calls.          |
| **zombie_coast_eggs.gsc**      | `consequences_will_never_be_the_same()` after Tesla drop          | Local reward dispatch for each player; mirrors Moon SQ / Temple SQ. |


---

## 1. Module Structure

### `gumballs.gsc` (Core Logic)

* Registry and activation dispatcher
* Player lifecycle hooks (spawn/death/disconnect)
* Round and selection watchers
* Activation and consumption models
* Built-in gums (Wall Power, Crate Power, Wonderbar)
* Reads dev DVARs (`gg_enable`, `gg_debug`, etc.)
* Registry helpers: `gg_register_gum`, `gg_find_gum_by_id`
* Player-state builder and HUD linkage
* Bootstrapped via:

  ```c
  level thread maps\gobblegum\gumballs::gumballs_init();
  ```

### `gb_hud.gsc` (HUD & UX)

* Precache shaders/fonts
* Top-Center HUD (icon, name, uses, description)
* Bottom-Right HUD (icon, progress bar, hint)
* Safe-area anchors and token-based fade logic
* API supports all consumption models (uses, rounds, timers)

### `gb_helpers.gsc` (Utilities)

* Map and weapon helpers
* Enum getters and constants
* Safe setters and math helpers
* Compatibility stubs for legacy functions

### `_zombiemode.gsc` Entry Order

```c
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gb_hud;
#include maps\gobblegum\gumballs;
```

**Order Rationale:**

1. Helpers expose functions first.
2. HUD assets must be precached before any player HUD builds.
3. Core initializes last, ensuring safe dependency access.

---

## 2. Data Model

### Gum Definition

* `id`: internal identifier
* `name`: display string
* `shader`: HUD icon material
* `desc`: short description
* `uses_description`: shown under gum name
* `activation_type`: AUTO / USER
* `consumption_type`: timed / rounds / uses
* `activate_func`: function name key
* `tags`: categories (perk, powerup, economy, weapon)
* `map_whitelist` / `blacklist`: enforce availability
* `exclusion_groups`: prevent conflicts
* `rarity_weight`: pool weighting

### Player State

Tracks per-player gum information, including active gum ID, remaining uses/timer, and HUD references.
State variables:

* `gg.selected_id`
* `gg.effect_active`, `gg.effect_id`
* `gg.uses_remaining`, `gg.rounds_remaining`, `gg.timer_endtime`
* `gg.hud` (HUD ref struct)
* `gg.armed_flags` (armed gum tracking)

---

## 3. HUD Specification & API

### Layout

**Top Center (TC):**

* Icon (56×56)
* Name / Uses Line / Description
* Auto-hides after 7.5s (configurable)

**Bottom Right (BR):**

* Hint line, icon, usage bar
* Fade in/out token-based
* Timer, rounds, or uses modes
* Wonderbar label uses shared hint pipeline

**Behavior Highlights:**

* All fades use token logic to prevent overlaps
* Anchors: TC = center/top; BR = right/bottomright
* `gg_br_delayed_show_secs` (default 1.5s) controls delayed reveal
* Debug HUD anchors top-left via `setPoint("LEFTTOP", ...)`

---

## 4. Gum Selection Logic

* Watches `round_number` every 0.25s
* Assigns new gum each round
* Cleans up unused gums
* Enforces uniqueness until pool reset
* Handles AUTO and USER activations
* Uses dev overrides (`set gg_force_gum <id>`) for testing

---

## 5. Activation & Consumption

* USER activation: `+actionslot 4`
* AUTO activation: fires on selection
* Consumption models:

  * **Uses:** decrements per trigger
  * **Rounds:** decrements per round
  * **Timed:** countdown timer

Dispatcher routes each gum’s `activate_func` to a defined logic function.

---

## 6. Effect Catalog

**Power-ups:**
Cache Back, Dead of Nuclear Winter, Kill Joy, Licensed Contractor, Immolation Liquidation, Who’s Keeping Score, On the House, Fatal Contraption, Extra Credit, Reign Drops.

**Weapons / Perks:**
Hidden Power, Wall Power, Crate Power, Wonderbar, Perkaholic.

**Economy / Round Control:**
Gift Card, Round Robbin, Shopping Free, Stock Option.

Each gum defines behavior, consumption, HUD response, and debug output controlled by `gg_debug`.

---

## 7. Thread & Safety Model

* Every thread `endon("disconnect")` and `endon("gg_gum_cleared")`.
* Round watcher reads `level.round_number` every 0.25s (non-invasive).
* Tokens prevent overlapping fades and misfires.
* Armed gums include a 3s grace period.
* Debug HUD and logs tied to `gg_debug`.

---

## 8. API Surfaces

### Core / HUD

All HUD show/hide, fade, and progress functions (`hud.show_tc`, `hud.show_br`, `hud.br_start_timer`, etc.).

### Core / Helpers

Functions for map detection, wonder weapon pools, perk safety, and weapon display names.

### Legacy Stubs

No-op compatibility entries for older builds.

---

## 9. Configurable Knobs

| Category   | Variable                         | Default | Description                  |
| ---------- | -------------------------------- | ------- | ---------------------------- |
| Core       | `gg_enable`                      | 1       | Enables GobbleGum system     |
| Debug      | `gg_debug`                       | 0       | Enables debug HUD/logging    |
| Selection  | `gg_round1_delay`                | 10.0    | Delay before first gum       |
| HUD        | `GG_TC_AUTOHIDE_SECS`            | 7.5     | Top-center fade timeout      |
| Armed Gums | `gg_armed_grace_secs`            | 3.0     | Trigger grace window         |
| Wonderbar  | `gg_wonder_label_suppress_ms`    | 35000   | Fire Sale label suppression  |
| Economy    | `gg_gift_card_points`            | 30000   | Points for Gift Card         |
| Perkaholic | `gg_perkaholic_grant_all_perks`  | 1       | Grants full perk set         |
| Perkaholic | `gg_perkaholic_include_mulekick` | 1       | Includes Mule Kick when safe |

---

## Debug Logging

* All logs go through `helpers.gg_log("<msg>")`.
* `[gg]` prefix standard for filtering.
* `gg_debug` toggles all debug visibility.
* When 1, logs show gum dispatch, Perkaholic grants, Wonderbar activity, and HUD events.
* When 0, all debug elements and queues are destroyed.
* HUD text stacks in top-left with fadeout after ~3s.

---

### Common User Settings (Console Commands)

```
set gg_enable 1                       // Enables the GobbleGum system (default 0)
set gg_debug 1                        // Shows debug HUD/logs (default 0)
set gg_force_gum ID                   // Forces a specific gum for testing
set gg_perkaholic_include_mulekick 1  // Include Mule Kick for Perkaholic (default 0)
```

### Available Gums

| Name                   | ID                     | Description                                   |
| ---------------------- | ---------------------- | --------------------------------------------- |
| Perkaholic             | perkaholic             | All map perks                                 |
| Wall Power             | wall_power             | Next wall-buy is PaP                          |
| Cache Back             | cache_back             | Spawns a Max Ammo Power-Up                    |
| Crate Power            | crate_power            | Next Mystery Box gun is PaP                   |
| Dead of Nuclear Winter | dead_of_nuclear_winter | Spawns a Nuke Power-Up                        |
| Extra Credit           | extra_credit           | Spawns a Bonus Points Power-Up                |
| Gift Card              | gift_card              | Adds 15,000 points to your score              |
| Fatal Contraption      | fatal_contraption      | Spawns a Death Machine Power-Up               |
| Hidden Power           | hidden_power           | Pack-a-Punch your current weapon instantly    |
| Immolation Liquidation | immolation             | Spawns a Fire Sale Power-Up                   |
| Kill Joy               | kill_joy               | Spawns an Insta-Kill Power-Up                 |
| Licensed Contractor    | licensed_contractor    | Spawns a Carpenter Power-Up                   |
| On the House           | on_the_house           | Spawns a free perk Power-Up                   |
| Reign Drops            | reign_drops            | Spawns all core Power-Ups at once             |
| Round Robbin           | round_robbin           | Ends the current round; all players gain 1600 |
| Who’s Keeping Score    | whos_keeping_score     | Spawns a Double Points Power-Up               |
| Wonderbar              | wonderbar              | Next box gun is a Wonder Weapon               |

---

## Changelog

### v1.1 – Perma Perk EE Hooks

* Added **local perma perk reward** dispatch to:

  * `zombie_cod5_factory.gsc` (Fly Trap completion)
  * `zombie_cosmodrome_eggs.gsc` (Gersh’s final dialogue)
  * `zombie_coast_eggs.gsc` (post-Tesla drop)
---
