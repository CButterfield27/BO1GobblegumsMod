#include maps\_utility;
#include common_scripts\utility;

gg_debug_on()
{
    return (GetDvarInt("gg_debug") == 1);
}

gg_debug_set_dvar_if_changed(name, value)
{
    if (!isdefined(name) || name == "")
        return;

    current = GetDvarInt(name);
    if (current != value)
        SetDvar(name, value);
}

gg_debug_clear_overlay_fallback()
{
    if (isdefined(level.gg_debug_lines))
    {
        for (i = 0; i < level.gg_debug_lines.size; i++)
        {
            entry = level.gg_debug_lines[i];
            if (!isdefined(entry))
                continue;
            if (isdefined(entry.elem))
            {
                entry.elem notify("gg_debug_line_removed");
                entry.elem destroy();
            }
        }
        level.gg_debug_lines = [];
    }

    level.gg_debug_text = undefined;
    level.gg_debug_text_owner = undefined;
    level.gg_debug_hud_refs = [];
}

gg_sync_debug_state()
{
    enabled = gg_debug_on();

    if (!isdefined(level.gg_state))
        level.gg_state = spawnstruct();

    level.gg_state.debug_enabled = enabled;

    if (isdefined(level.gg_config))
        level.gg_config.consume_logs = enabled;

    return enabled;
}

gg_debug_apply_state(enabled)
{
    value = 0;
    if (enabled)
        value = 1;

    gg_debug_set_dvar_if_changed("gg_debug_hud", value);
    gg_debug_set_dvar_if_changed("gg_log_dispatch", value);
    gg_debug_set_dvar_if_changed("gg_consume_logs", value);

    gg_sync_debug_state();

    if (!enabled)
    {
        if (isdefined(level.gb_hud) && isdefined(level.gb_hud.debug_teardown))
            [[ level.gb_hud.debug_teardown ]]();
        else
            gg_debug_clear_overlay_fallback();

        if (isdefined(level.gg_debug_queue))
            level.gg_debug_queue = [];

        if (isdefined(level.players) && isdefined(level.players.size)
            && isdefined(level.gb_hud) && isdefined(level.gb_hud.clear_hint))
        {
            for (i = 0; i < level.players.size; i++)
            {
                player = level.players[i];
                if (!isdefined(player))
                    continue;
                [[ level.gb_hud.clear_hint ]](player);
            }
        }
    }

    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.on_debug_state_changed))
        [[ level.gb_hud.on_debug_state_changed ]](enabled);
}

gg_debug_watch_thread()
{
    last = undefined;

    while (true)
    {
        state = gg_debug_on();

        if (!isdefined(last) || state != last)
        {
            gg_debug_apply_state(state);
            last = state;
        }

        wait(0.1);
    }
}

gg_debug_queue_message(message)
{
    if (!isdefined(level.gg_debug_queue))
        level.gg_debug_queue = [];

    level.gg_debug_queue[level.gg_debug_queue.size] = message;

    max_queue = 16;
    if (level.gg_debug_queue.size > max_queue)
    {
        trim = [];
        start = level.gg_debug_queue.size - max_queue;
        for (i = start; i < level.gg_debug_queue.size; i++)
        {
            trim[trim.size] = level.gg_debug_queue[i];
        }
        level.gg_debug_queue = trim;
    }
}

gg_log(msg)
{
    if (!gg_debug_on())
        return;

    if (!isdefined(msg))
        msg = "";

    message = "[gg] " + msg;
    print(message);

    gg_debug_queue_message(message);
}

// Literal-return helpers (constants)
ACT_AUTO() { return 1; }
ACT_USER() { return 2; }
CONS_TIMED() { return 1; }
CONS_ROUNDS() { return 2; }
CONS_USES() { return 3; }
GG_TC_AUTOHIDE_SECS() { return 7.5; }
GG_HUD_FADE_SECS() { return 0.25; }
GG_FADE_SECS() { return GG_HUD_FADE_SECS(); }
GG_BR_DELAYED_SHOW_SECS() { return 1.5; }
GG_ARMED_GRACE_SECS() { return 3.0; }

helpers_array_contains(arr, value)
{
    if (!isdefined(arr))
        return false;
    for (i = 0; i < arr.size; i++)
    {
        if (arr[i] == value)
            return true;
    }
    return false;
}

normalize_mapname(name)
{
    if (!isdefined(name) || name == "")
        return "";

    lower = tolower(name);
    if (!isdefined(lower) || lower == "")
        return "";

    if (lower == "cosmodrome" || lower == "zm_cosmodrome")
        return "zombie_cosmodrome";

    if (lower == "coast" || lower == "zm_coast" || lower == "shangri_la")
        return "zombie_coast";

    if (lower == "kino" || lower == "kino_der_toten" || lower == "theater" || lower == "zm_theater")
        return "zombie_theater";

    if (lower == "moon" || lower == "zm_moon")
        return "zombie_moon";

    return lower;
}

get_current_mapname()
{
    name = undefined;
    if (isdefined(level.script))
    {
        name = level.script;
    }
    if (!isdefined(name) || name == "")
    {
        name = GetDvar("mapname");
    }
    return normalize_mapname(name);
}

// Returns true for features supported by the current map.
// Step 1: only special-case "death_machine" on cosmodrome/coast/moon.
map_allows(feature)
{
    if (!isdefined(feature))
        return true;

    if (feature == "death_machine")
    {
        name = get_current_mapname();
        if (!isdefined(name))
            return false;

        // Allow-list: cosmodrome (Ascension), coast (Shangri-La), moon
        if (name == "zombie_cosmodrome"
            || name == "zombie_coast"
            || name == "zombie_moon")
        {
            return true;
        }
        return false;
    }

    // Default allow for other features in Step 1
    return true;
}

map_allows_death_machine()
{
    return map_allows("death_machine");
}

is_cosmodrome()
{
    name = get_current_mapname();
    if (!isdefined(name))
        return false;
    return (name == "zombie_cosmodrome");
}

get_map_perk_list()
{
    if (isdefined(level.gb_helpers) && isdefined(level.gb_helpers.map_perk_cache))
        return level.gb_helpers.map_perk_cache;

    perks = [];

    triggers = GetEntArray("zombie_vending", "targetname");
    if (!isdefined(triggers))
        triggers = [];

    for (i = 0; i < triggers.size; i++)
    {
        trig = triggers[i];
        if (!isdefined(trig) || !isdefined(trig.script_noteworthy))
            continue;

        perk = trig.script_noteworthy;
        if (!isdefined(perk) || perk == "")
            continue;

        if (!helpers_array_contains(perks, perk))
            perks[perks.size] = perk;
    }

    if (isdefined(level.gb_helpers))
        level.gb_helpers.map_perk_cache = perks;

    return perks;
}

// Stubs (Step 1)
get_wonder_pool(map)
{
    pool = [];

    if (!isdefined(map) || map == "")
        map = get_current_mapname();

    if (!isdefined(level) || !isdefined(level.zombie_weapons))
        return pool;

    aliases = spawnstruct();
    aliases["scavenger_zm"] = "sniper_explosive_zm";
    aliases["human_gun_zm"] = "humangun_zm";

    candidates = [];
    candidates[candidates.size] = "ray_gun_zm";
    candidates[candidates.size] = "tesla_gun_zm";
    candidates[candidates.size] = "thundergun_zm";
    candidates[candidates.size] = "freezegun_zm";
    candidates[candidates.size] = "scavenger_zm";
    candidates[candidates.size] = "shrink_ray_zm";
    candidates[candidates.size] = "human_gun_zm";
    candidates[candidates.size] = "humangun_zm";
    candidates[candidates.size] = "microwavegundw_zm";

    for (i = 0; i < candidates.size; i++)
    {
        name = candidates[i];
        if (!isdefined(name) || name == "")
            continue;

        resolved = name;
        if (isdefined(aliases[name]))
            resolved = aliases[name];

        if (!isdefined(level.zombie_weapons[resolved]))
            continue;
        if (!isdefined(level.zombie_weapons[resolved].is_in_box) || !level.zombie_weapons[resolved].is_in_box)
            continue;
        already = false;
        for (j = 0; j < pool.size; j++)
        {
            if (pool[j] == resolved)
            {
                already = true;
                break;
            }
        }
        if (!already)
            pool[pool.size] = resolved;
    }

    if (GetDvarInt("gg_wonder_include_specials") != 0)
    {
        specials = [];
        specials[0] = "zombie_black_hole_bomb";
        specials[1] = "zombie_quantum_bomb";
        for (i = 0; i < specials.size; i++)
        {
            special = specials[i];
            if (!isdefined(special) || special == "")
                continue;
            if (!isdefined(level.zombie_weapons[special]))
                continue;
            if (!isdefined(level.zombie_weapons[special].is_in_box) || !level.zombie_weapons[special].is_in_box)
                continue;
            already = false;
            for (j = 0; j < pool.size; j++)
            {
                if (pool[j] == special)
                {
                    already = true;
                    break;
                }
            }
            if (!already)
                pool[pool.size] = special;
        }
    }

    return pool;
}

get_weapon_display_name(weapon)
{
    if (!isdefined(weapon) || weapon == "")
        return "";

    if (!isdefined(level) || !isdefined(level.zombie_weapons) || !isdefined(level.zombie_weapons[weapon]))
        return weapon;

    if (isdefined(level.zombie_weapons[weapon].hint) && level.zombie_weapons[weapon].hint != "")
        return level.zombie_weapons[weapon].hint;

    return weapon;
}

upgrade_weapon(player, base)
{
    if (!isdefined(player) || !isdefined(base) || base == "")
    {
        return false;
    }

    if (!isdefined(level.zombie_weapons) || !isdefined(level.zombie_weapons[base]))
    {
        return false;
    }

    if (!isdefined(level.zombie_weapons[base].upgrade_name))
    {
        // No upgrade path known for this weapon.
        return false;
    }

    upgrade = level.zombie_weapons[base].upgrade_name;
    if (!isdefined(upgrade) || upgrade == "")
    {
        return false;
    }

    if (player maps\_zombiemode_weapons::is_weapon_upgraded(base) || player HasWeapon(upgrade))
    {
        // Already upgraded; nothing to do.
        return true;
    }

    had_base = (player HasWeapon(base));
    success = false;

    if (isdefined(level.zombie_weapons[upgrade]))
    {
        options = player maps\_zombiemode_weapons::get_pack_a_punch_weapon_options(upgrade);

        if (isdefined(options))
        {
            player GiveWeapon(upgrade, 0, options);
        }
        else
        {
            helpers_upgrade_debug("Using basic GiveWeapon for " + upgrade);
            player GiveWeapon(upgrade);
        }

        success = player HasWeapon(upgrade);

        if (!success && had_base && !(player HasWeapon(base)))
        {
            player GiveWeapon(base);
            player GiveStartAmmo(base);
            maps\_zombiemode_weapons::acquire_weapon_toggle(base, player);
        }
    }

    if (!success)
    {
        return upgrade_weapon_fallback(player, base, upgrade);
    }

    if (had_base && player HasWeapon(base))
    {
        player TakeWeapon(base);
        maps\_zombiemode_weapons::unacquire_weapon_toggle(base);
    }

    player GiveStartAmmo(upgrade);
    maps\_zombiemode_weapons::acquire_weapon_toggle(upgrade, player);
    player SwitchToWeapon(upgrade);
    player maps\_zombiemode_weapons::play_weapon_vo(upgrade);
    player notify("pap_taken");
    player.pap_used = true;

    return true;
}

upgrade_weapon_fallback(player, base, upgrade)
{
    helpers_upgrade_debug("Fallback upgrade path for " + base);

    if (!isdefined(upgrade) || upgrade == "")
        return false;

    had_base = false;
    if (player HasWeapon(base))
    {
        had_base = true;
        player TakeWeapon(base);
        maps\_zombiemode_weapons::unacquire_weapon_toggle(base);
    }

    player GiveWeapon(upgrade);
    player GiveStartAmmo(upgrade);
    maps\_zombiemode_weapons::acquire_weapon_toggle(upgrade, player);
    player SwitchToWeapon(upgrade);
    player notify("pap_taken");
    player.pap_used = true;

    return had_base || (player HasWeapon(upgrade));
}

helpers_upgrade_debug(msg)
{
    if (!gg_debug_on())
        return;
    if (!isdefined(msg) || msg == "")
        msg = "upgrade debug";
    gg_log("upgrade: " + msg);
}

player_has_all_map_perks(player)
{
    if (!isdefined(player))
        return false;

    perks = get_map_perk_list();
    if (!isdefined(perks) || perks.size <= 0)
        return true;

    for (i = 0; i < perks.size; i++)
    {
        perk = perks[i];
        if (!isdefined(perk) || perk == "")
            continue;
        if (!(player HasPerk(perk)))
            return false;
    }

    return true;
}

trigger_perk_vo_if_cosmodrome(player, perk)
{
    if (!is_cosmodrome())
        return false;

    if (!isdefined(level))
        return false;

    invoked = false;
    if (isdefined(level.perk_bought_func) && isdefined(player) && isdefined(perk) && perk != "")
    {
        player [[ level.perk_bought_func ]](perk);
        invoked = true;
    }

    previously_set = false;
    if (isdefined(level.perk_bought) && level.perk_bought)
        previously_set = true;

    level.perk_bought = true;

    if (isdefined(level.flag_set))
    {
        [[ level.flag_set ]]("perk_bought");
    }
    else
    {
        flag_set("perk_bought");
    }

    if (gg_debug_on())
    {
        name = get_current_mapname();
        if (!isdefined(name) || name == "")
            name = "unknown_map";

        label = "perk_bought flag set";
        if (previously_set)
            label = "perk_bought flag reassert";

        if (invoked)
            label = label + ", perk_bought_func invoked";

        gg_log("cosmodrome perk vo: " + label + " (" + name + ")");
    }

    return true;
}

helpers_init()
{
    if (isdefined(level.gb_helpers))
    {
        return;
    }

    level.gb_helpers = spawnstruct();
    level.gb_helpers.map_allows = ::map_allows;
    level.gb_helpers.is_cosmodrome = ::is_cosmodrome;
    level.gb_helpers.normalize_mapname = ::normalize_mapname;
    level.gb_helpers.get_current_mapname = ::get_current_mapname;
    level.gb_helpers.get_map_perk_list = ::get_map_perk_list;
    level.gb_helpers.get_wonder_pool = ::get_wonder_pool;
    level.gb_helpers.get_weapon_display_name = ::get_weapon_display_name;
    level.gb_helpers.upgrade_weapon = ::upgrade_weapon;
    level.gb_helpers.player_has_all_map_perks = ::player_has_all_map_perks;
    level.gb_helpers.trigger_perk_vo_if_cosmodrome = ::trigger_perk_vo_if_cosmodrome;
    level.gb_helpers.gg_log = ::gg_log;
    level.gb_helpers.gg_debug_on = ::gg_debug_on;
    level.gb_helpers.gg_sync_debug_state = ::gg_sync_debug_state;

    level.gb_helpers.ACT_AUTO = ::ACT_AUTO;
    level.gb_helpers.ACT_USER = ::ACT_USER;
    level.gb_helpers.CONS_TIMED = ::CONS_TIMED;
    level.gb_helpers.CONS_ROUNDS = ::CONS_ROUNDS;
    level.gb_helpers.CONS_USES = ::CONS_USES;
    level.gb_helpers.GG_TC_AUTOHIDE_SECS = ::GG_TC_AUTOHIDE_SECS;
    level.gb_helpers.GG_HUD_FADE_SECS = ::GG_HUD_FADE_SECS;
    level.gb_helpers.GG_FADE_SECS = ::GG_FADE_SECS;
    level.gb_helpers.GG_BR_DELAYED_SHOW_SECS = ::GG_BR_DELAYED_SHOW_SECS;
    level.gb_helpers.GG_ARMED_GRACE_SECS = ::GG_ARMED_GRACE_SECS;
    level.gb_helpers.map_allows_death_machine = ::map_allows_death_machine;

    if (!isdefined(level.gg_debug_watch_started))
    {
        level.gg_debug_watch_started = true;
        gg_debug_apply_state(gg_debug_on());
        level thread gg_debug_watch_thread();
    }
}
