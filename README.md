# BO1 GobbleGum MOD

---

## 1. Module Structure
- **`gumballs.gsc` (Core logic)**
  - Gum registry & activation dispatcher
  - Player lifecycle hooks (spawn, death, disconnect)
  - Selection & round watcher
  - Gum activation & consumption model
  - Effect implementations
- **`gb_hud.gsc` (HUD & UX)**
  - Precache shaders/fonts
  - Top-Center HUD (icon, name, uses, description)
  - Bottom-Right HUD (icon, progress bar, hint text, label)
  - Fade, animation, delayed show/hide
- **`gb_helpers.gsc` (Utilities)**
  - Map-specific helpers (death machine maps, cosmodrome VO trigger)
  - Perk/weapon/wonder-weapon helpers
  - Power-up spawn helpers
  - Safe `set_if_changed` wrappers
  - Math, pluralization, clamp
  - Thread safety wrappers
  - Legacy no-op stubs (compatibility)

---

## 2. Data Model

### Gum Definition
- `id` — internal identifier
- `name` — display/loc string
- `shader` — HUD icon material
- `description` — display/loc string
- `activation_type` — AUTO or USER
- `consumption_type` — timed / rounds / uses
- `activate_func` — string key → dispatcher
- **Metadata**
  - `tags` — categories (powerup, perk, economy, weapon)
  - `map_whitelist`/`blacklist` — enforce availability (e.g., Fatal Contraption on Ascension/Coast/Moon only)
  - `exclusion_groups` — gums that cannot overlap
  - `rarity_weight` — pool weighting

### Player State
- Current gum snapshot
- Uses/rounds/duration remaining
- Armed gum flags (wall_power_active, crate_power_active, wonderbar_active)
- Wonderbar choice cache
- HUD fade tokens, defer-hide timestamps
- Selection pools (full vs. remaining)
- Activation debounce
- Effect end timers (e.g., Stock Option, Shopping Free)

---

## 3. HUD Specification & API

### Layout

#### Top Center (TC)
- Icon (56×56)  
- Gum Name (scale 1.5)  
- Uses/Activation line (scale 1.15)  
- Description (scale 1.15)  

**Behavior**
- Fade in on selection
- Auto-hide after 7.5s
- Refresh on state change

---

#### Bottom Right (BR)
- Hint text (scale 1.15)  
- Icon (48×48)  
- Progress Bar (shader `"white"`, width 75, height 5)  
  - Modes: uses / rounds / timer
- Optional label (e.g., Wonderbar preview)

**Behavior**
- Fade in on selection
- Auto-hide when consumed/cleared
- Supports **delayed show** (smooth UX after selection/activation)
- Hint text set/cleared dynamically
- Label can be **suppressed and reasserted** (e.g., during Fire Sale suppression loop)

---

### HUD API
- `hud.init_player(player)`  
- `hud.show_tc(player, gum)` / `hud.hide_tc_after(player, secs, expected_name)`  
- `hud.update_tc(player, gum)`  
- `hud.show_br(player, gum)` / `hud.hide_br(player)`  
- `hud.show_br_after_delay(player, secs, expected_name)` *(added for smooth transitions)*  
- `hud.set_hint(player, text)` / `hud.clear_hint(player)`  
- `hud.br_set_mode(player, mode)`  
- `hud.br_set_total_uses(player, n)` / `hud.br_consume_use(player)`  
- `hud.br_set_total_rounds(player, n)` / `hud.br_consume_round(player)`  
- `hud.br_start_timer(player, secs)` / `hud.br_stop_timer(player)`  

---

### Visual Rules
- Fade: 0.25s (token-based, prevents overlaps)
- TC auto-hide: 7.5s
- BR auto-hide: when gum ends
- **Grace window**: short defer-hide for Wonderbar, etc.
- **Delayed show**: fade in BR after ~1.5s if needed
- Anchors respect safe area
- Accessibility: text is primary, colors secondary

---

## 4. Gum Selection Logic

- Build pool (`pool_full` → `pool_remaining`)
- Watch `round_number` (0.25s cadence)
- On round start:
  - Cancel active effects (`gg_gum_cleared`)
  - Round 1 delay: 10s before first gum
  - Pick gum: skip invalid (e.g., Perkaholic with full perks), reset cycle if empty
  - Apply gum: set player vars, init HUD BR bar
  - Show HUD: fade in TC + BR
  - Auto-gums: activate immediately
  - Remove gum from `pool_remaining` (no repeats until reset)
  - Schedule TC auto-hide (7.5s)

### Manual Override
- `gg_set_selected_gum_name()` + `gg_apply_selected_gum()`  
- Applies gum immediately, HUD updates  
- Policy toggle: whether overrides affect pool uniqueness  

### Special Case
- **Ascension/Perkaholic**: also trigger `perk_bought_func` VO hooks for free perks.  

---

## 5. Activation & Consumption

### User Activation
- Input: `+actionslot 4`  
- 200ms debounce  
- If gum is user type and has uses:  
  - Timed: start timer, dispatch effect, consume  
  - Rounds: dispatch effect, decrement rounds  
  - Uses: dispatch effect, consume use  

### Auto Activation
- Immediate on selection if AUTO  
- Mirrors user path, but without input  
- Armed gums (Wall/Crate/Wonderbar) consume only when triggered (weapon acquired)  

### Dispatcher
- Function map: string → int code (fast path)  
- Fallback: string compare (exhaustive list)  

---

## 6. Effect Catalog (with Notes)

### Power-Ups
- Cache Back (Max Ammo)  
- Dead of Nuclear Winter (Nuke)  
- Kill Joy (Insta Kill)  
- Licensed Contractor (Carpenter)  
- Immolation Liquidation (Fire Sale) — suppress Wonderbar label for 35s  
- Who’s Keeping Score (Double Points)  
- On the House (Free Perk)  
- Fatal Contraption (Death Machine) — only on maps that allow  
- Extra Credit (Bonus Points)  
- Reign Drops (all power-ups at once)

### Weapons / Perks
- Hidden Power (PaP current weapon)  
- Wall Power (next wall buy upgraded, 3s grace)  
- Crate Power (next box gun upgraded, 3s grace)  
- Wonderbar (next box gun is WW)  
  - Label shows WW name  
  - Label reasserts visibility every 0.25s until gum ends  
  - Suppressed during Fire Sale  

- Perkaholic (all map perks; Ascension triggers perk VO)  

### Economy / Round Control
- Round Robbin (end round, +1600 pts each player)  
- Shopping Free (all purchases free for 60s)  
  - **Implementation**: adds +50k points baseline, refunds purchases, removes unused at end  
- Stock Option (ammo taken from stockpile for 60s)  
  - Fire monitor + expiry monitor  

### Future / Placeholders
- Near Death Experience (stub)  
- Respin Cycle (stub)  

---

## 7. Thread & Safety Model
- Always `endon("disconnect")`  
- Gum effect threads also `endon("gg_gum_cleared")`  
- Fade tokens prevent overlapping fades  
- Armed gums use **3s grace window** to avoid false triggers  
- Wonderbar ends via both `gg_wonderbar_end` notify and cleanup path  
- Round watcher: 0.25s polling  

---

## 8. API Surfaces

### Core → HUD
- All HUD functions above (show/hide/update, bar, hint, delay)  

### Core → Helpers
- `helpers.map_allows("death_machine")`  
- `helpers.is_cosmodrome()`  
- `helpers.get_wonder_pool(map)`  
- `helpers.upgrade_weapon(player, base)`  
- `helpers.drop_powerup(player, code, pos|dist)`  
- `helpers.player_has_all_map_perks(player)`  

### Legacy Stubs (no-op, for compatibility)
- `gg_on_gum_used`  
- `gg_round_monitor`  
- `gg_assign_gum_for_new_round`  
- `gg_on_round_flow`  
- `gg_on_match_end`  

---

## 9. Configurable Knobs
- Round-1 delay (default 10s)  
- TC auto-hide (default 7.5s)  
- HUD fade duration (default 0.25s)  
- Armed gum grace window (default 3s)  
- Wonderbar label suppression (default 35s during Fire Sale)  
- BR delayed show (default 1.5s)  
- Selection cadence (round-based vs. alternative)  
- Override policy for manual gums  

---

## 10. Build Order
1. Skeleton registry + HUD stubs  
2. Round watcher + gum selection → dummy HUD updates  
3. Dispatcher + dummy effect stubs  
4. Consumption logic (uses/rounds/timer)  
5. Implement core power-up gums  
6. Add armed gums (Wall, Crate, Wonderbar)  
7. Add economy/round gums (Shopping Free, Stock Option, Round Robbin)  
8. Harden map/perk checks + Ascension VO hooks  
9. Refine HUD polish (hint text, delayed show, suppression)  
10. Add placeholders, rarity weights, and debug commands  

---

## 11. Lifecycle State Diagram

```mermaid
stateDiagram-v2
    direction LR

    [*] --> NoGum

    state "RoundStart" as RoundStart
    state "Selected (TC+BR show)" as Selected
    state "Activated" as Activated
    state "Effect Active" as Active
    state "Armed Awaiting Trigger" as Armed
    state "Timer Active" as Timer
    state "Rounds Active" as Rounds
    state "Instant/Uses Drain" as Instant

    NoGum --> RoundStart: round change / spawn
    RoundStart --> Selected: assign gum\n(init BR mode)
    Selected --> Activated: AUTO gum (immediate)
    Selected --> Activated: USER gum\n(+actionslot 4, debounce)

    Activated --> Timer: consumption_type = timed\nstart BR timer
    Activated --> Rounds: consumption_type = rounds\ninit rounds left
    Activated --> Armed: armed gums (Wall/Crate/Wonderbar)\n3s grace window
    Activated --> Instant: uses-based instant effect\nconsume 1 use

    Timer --> Selected: timer expires\nconsume 1 use (if applicable)
    Rounds --> Selected: round consumed\nupdate BR bar\n[if rounds left > 0 remain Active]
    Armed --> Selected: trigger satisfied\nconsume 1 use
    Instant --> Selected: after effect

    Selected --> NoGum: uses == 0 → hide BR
    Active --> NoGum: uses == 0 → hide BR

    %% Global interrupts
    Selected --> NoGum: gg_gum_cleared / death / disconnect
    Timer --> NoGum: gg_gum_cleared / death / disconnect
    Rounds --> NoGum: gg_gum_cleared / death / disconnect
    Armed --> NoGum: gg_gum_cleared / death / disconnect
    Instant --> NoGum: gg_gum_cleared / death / disconnect

    %% UX side-states (notes)
    note right of Selected
      TC auto-hide after 7.5s
      BR delayed show optional (~1.5s)
    end note

    note right of Armed
      Wonderbar label:
      - Preview name shown
      - Reassert every 0.25s
      - Suppress during Fire Sale
    end note
