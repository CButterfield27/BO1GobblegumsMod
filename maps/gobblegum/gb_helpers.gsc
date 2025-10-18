// Literal-return helpers (constants)
ACT_AUTO() { return 1; }
ACT_USER() { return 2; }
CONS_TIMED() { return 1; }
CONS_ROUNDS() { return 2; }
CONS_USES() { return 3; }
GG_TC_AUTOHIDE_SECS() { return 7.5; }
GG_FADE_SECS() { return 0.25; }
GG_BR_DELAYED_SHOW_SECS() { return 1.5; }
GG_ARMED_GRACE_SECS() { return 3.0; }

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
    return name;
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
        if (name == "zombie_cosmodrome" || name == "cosmodrome"
            || name == "zombie_coast" || name == "coast"
            || name == "zombie_moon" || name == "moon")
        {
            return true;
        }
        return false;
    }

    // Default allow for other features in Step 1
    return true;
}

is_cosmodrome()
{
    name = get_current_mapname();
    if (!isdefined(name))
        return false;
    return (name == "zombie_cosmodrome" || name == "cosmodrome");
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

    if (player maps\_zombiemode_weapons::is_weapon_upgraded(base))
    {
        // Already upgraded; nothing to do.
        return false;
    }

    upgrade = level.zombie_weapons[base].upgrade_name;
    if (!isdefined(upgrade) || upgrade == "")
    {
        return false;
    }

    // Ensure the upgrade weapon exists in the table so Pack-a-Punch options resolve.
    if (!isdefined(level.zombie_weapons[upgrade]))
    {
        return upgrade_weapon_fallback(player, base, upgrade);
    }

    options = player maps\_zombiemode_weapons::get_pack_a_punch_weapon_options(upgrade);

    had_base = (player HasWeapon(base));
    if (had_base)
    {
        player TakeWeapon(base);
        maps\_zombiemode_weapons::unacquire_weapon_toggle(base);
    }

    if (isdefined(options))
    {
        player GiveWeapon(upgrade, 0, options);
    }
    else
    {
        helpers_upgrade_debug("Using basic GiveWeapon for " + upgrade);
        player GiveWeapon(upgrade);
    }

    if (!player HasWeapon(upgrade))
    {
        // Re-equip the original weapon if the replacement failed outright.
        if (had_base)
        {
            player GiveWeapon(base);
            player GiveStartAmmo(base);
            maps\_zombiemode_weapons::acquire_weapon_toggle(base, player);
            player SwitchToWeapon(base);
        }
        return false;
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
    if (GetDvarInt("gg_debug") != 1)
        return;
    if (!isdefined(msg))
        msg = "upgrade debug";
    iprintln("Gumballs: " + msg);
}

drop_powerup(player, code, pos_or_dist)
{
    // no-op in Step 1
}

player_has_all_map_perks(player)
{
    return false;
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
    level.gb_helpers.get_current_mapname = ::get_current_mapname;
    level.gb_helpers.get_wonder_pool = ::get_wonder_pool;
    level.gb_helpers.get_weapon_display_name = ::get_weapon_display_name;
    level.gb_helpers.upgrade_weapon = ::upgrade_weapon;
    level.gb_helpers.drop_powerup = ::drop_powerup;
    level.gb_helpers.player_has_all_map_perks = ::player_has_all_map_perks;

    level.gb_helpers.ACT_AUTO = ::ACT_AUTO;
    level.gb_helpers.ACT_USER = ::ACT_USER;
    level.gb_helpers.CONS_TIMED = ::CONS_TIMED;
    level.gb_helpers.CONS_ROUNDS = ::CONS_ROUNDS;
    level.gb_helpers.CONS_USES = ::CONS_USES;
    level.gb_helpers.GG_TC_AUTOHIDE_SECS = ::GG_TC_AUTOHIDE_SECS;
    level.gb_helpers.GG_FADE_SECS = ::GG_FADE_SECS;
    level.gb_helpers.GG_BR_DELAYED_SHOW_SECS = ::GG_BR_DELAYED_SHOW_SECS;
    level.gb_helpers.GG_ARMED_GRACE_SECS = ::GG_ARMED_GRACE_SECS;
}
