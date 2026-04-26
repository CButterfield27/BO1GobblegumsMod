#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

gg_fx_wall_power(player, gum)
{
    if (!isdefined(player))
        return;

    gg_mark_activation_skip(player);
    gg_wall_power_arm(player, gum);
}

gg_wall_power_arm(player, gum)
{
    if (!isdefined(player))
        return;

    if (!isdefined(player.gg))
        build_player_state(player);

    player notify("gg_wall_power_cancel");

    if (!isdefined(player.gg.wall_power_token))
        player.gg.wall_power_token = 0;
    player.gg.wall_power_token += 1;
    token = player.gg.wall_power_token;
    player.gg.wall_power_last_debug = undefined;

    snapshot = gg_clone_array(gg_get_primary_weapons(player));
    grace_end = gettime() + gg_get_armed_grace_ms();

    player.gg.armed_flags.wall = true;

    player thread gg_wall_power_monitor_thread(gum, token, grace_end, snapshot);

    if (gg_debug_enabled())
        [[ level.gb_helpers.gg_log ]]("wall power armed");
}

gg_wall_power_monitor_thread(gum, expected_token, grace_end, snapshot)
{
    self endon("disconnect");
    self endon("gg_gum_cleared");
    self endon("gg_wall_power_cancel");

    known = gg_clone_array(snapshot);
    poll_secs = gg_get_armed_poll_secs();
    if (poll_secs <= 0)
        poll_secs = 0.1;

    while (true)
    {
        wait(poll_secs);

        if (!gg_wall_power_token_active(expected_token))
            return;

        current = gg_clone_array(gg_get_primary_weapons(self));
        new_weapon = gg_detect_new_weapon(known, current);
        known = current;

        if (!isdefined(new_weapon))
            continue;

        if (!gg_wall_power_should_upgrade(self, new_weapon, grace_end))
            continue;

        if (!gg_apply_upgrade_for_weapon(self, new_weapon))
            continue;

        gg_wall_power_on_success(self, gum, new_weapon);
        return;
    }
}

gg_wall_power_debug(player, reason, weapon)
{
    if (!gg_debug_enabled())
        return;

    if (!isdefined(player))
        return;

    if (!isdefined(player.gg))
        build_player_state(player);

    key = reason;
    if (isdefined(weapon) && weapon != "")
        key = key + ":" + weapon;

    if (isdefined(player.gg.wall_power_last_debug) && player.gg.wall_power_last_debug == key)
        return;

    player.gg.wall_power_last_debug = key;

    msg = "wall power " + reason;
    if (isdefined(weapon) && weapon != "")
        msg = msg + " (" + weapon + ")";
    [[ level.gb_helpers.gg_log ]](msg);
}

gg_wall_power_should_upgrade(player, weapon, grace_end)
{
    if (!isdefined(weapon) || weapon == "" || weapon == "none")
    {
        gg_wall_power_debug(player, "skip: invalid weapon", weapon);
        return false;
    }

    if (isdefined(grace_end) && gettime() < grace_end)
    {
        gg_wall_power_debug(player, "skip: grace window", weapon);
        return false;
    }

    if (gg_weapon_is_spawn_pistol(weapon))
    {
        gg_wall_power_debug(player, "skip: spawn pistol", weapon);
        return false;
    }

    if (!gg_weapon_is_wall_buy(weapon))
    {
        gg_wall_power_debug(player, "skip: not a wall buy", weapon);
        return false;
    }

    if (gg_weapon_is_box_weapon(weapon))
    {
        gg_wall_power_debug(player, "skip: box weapon", weapon);
        return false;
    }

    if (!gg_weapon_has_upgrade(weapon))
    {
        gg_wall_power_debug(player, "skip: no upgrade", weapon);
        return false;
    }

    if (player maps\_zombiemode_weapons::is_weapon_upgraded(weapon))
    {
        gg_wall_power_debug(player, "skip: already upgraded", weapon);
        return false;
    }

    return true;
}

gg_wall_power_on_success(player, gum, weapon)
{
    if (!isdefined(player))
        return;

    gg_show_hint_if_enabled(player, "Applied: Wall Power");

    player.gg.armed_flags.wall = false;
    if (isdefined(player.gg))
        player.gg.wall_power_last_debug = undefined;

    if (gg_debug_enabled())
        [[ level.gb_helpers.gg_log ]]("wall power upgraded " + weapon);

    wait(0.25);
    if (isdefined(player.gg))
        player.gg.uses_remaining = 0;
    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_consume_use))
        [[ level.gb_hud.br_consume_use ]](player);
    gg_end_current_gum(player, "wall_power_applied");
}

gg_wall_power_token_active(expected_token)
{
    if (!isdefined(self.gg) || !isdefined(self.gg.wall_power_token))
        return false;
    return (self.gg.wall_power_token == expected_token);
}
