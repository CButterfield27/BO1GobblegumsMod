// GobbleGum Helpers (Step 1: safe, idempotent)

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
get_wonder_pool()
{
    return [];
}

upgrade_weapon(player, base)
{
    // no-op in Step 1
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
    level.gb_helpers.get_wonder_pool = ::get_wonder_pool;
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
