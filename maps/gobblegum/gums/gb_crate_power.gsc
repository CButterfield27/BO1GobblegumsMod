#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

gg_fx_crate_power(player, gum)
{
    if (!isdefined(player))
        return;

    gg_mark_activation_skip(player);
    gg_crate_power_arm(player, gum);
}

gg_crate_power_arm(player, gum)
{
    if (!isdefined(player))
        return;

    if (!isdefined(player.gg))
        build_player_state(player);

    player notify("gg_crate_power_cancel");

    if (!isdefined(player.gg.br_delay_token))
        player.gg.br_delay_token = 0;
    player.gg.br_delay_token += 1;
    player.gg.br_pending_gum = gum;
    if (isdefined(gum) && isdefined(gum.id))
        player.gg.br_pending_gum_id = gum.id;
    else
        player.gg.br_pending_gum_id = undefined;

    if (!isdefined(player.gg.crate_power_token))
        player.gg.crate_power_token = 0;
    player.gg.crate_power_token += 1;
    token = player.gg.crate_power_token;

    armed_time = gettime();
    player.gg.crate_power_armed_time = armed_time;
    player.gg.armed_since = armed_time;

    player.gg.armed_flags.crate = true;
    player.gg.armed_flags.crate_power_active = true;

    if (isdefined(level.gb_hud))
    {
        if (isdefined(level.gb_hud.show_br))
            [[ level.gb_hud.show_br ]](player, gum);
        if (isdefined(level.gb_hud.br_set_mode))
            [[ level.gb_hud.br_set_mode ]](player, "uses");
        if (isdefined(level.gb_hud.br_set_total_uses))
            [[ level.gb_hud.br_set_total_uses ]](player, 1);
    }

    gg_show_hint_if_enabled(player, "Armed: Crate Power");
    gg_spawn_firesale_test_drop(player);

    snapshot = gg_clone_array(gg_get_primary_weapons(player));
    player thread gg_crate_power_monitor_thread(gum, token, armed_time, snapshot);

    if (gg_debug_enabled())
        [[ level.gb_helpers.gg_log ]]("crate power armed");
}

gg_crate_power_monitor_thread(gum, expected_token, armed_time, snapshot)
{
    self endon("disconnect");
    self endon("gg_gum_cleared");
    self endon("gg_crate_power_cancel");

    known = gg_clone_array(snapshot);
    poll_secs = gg_get_armed_poll_secs();
    if (poll_secs <= 0)
        poll_secs = 0.1;

    while (true)
    {
        wait(poll_secs);

        if (!gg_crate_power_token_active(expected_token))
            return;

        current = gg_clone_array(gg_get_primary_weapons(self));
        new_weapon = gg_detect_new_weapon(known, current);
        known = current;

        if (!isdefined(new_weapon))
            continue;

        if (!gg_crate_power_should_upgrade(self, new_weapon, armed_time))
            continue;

        if (!gg_apply_upgrade_for_weapon(self, new_weapon))
            continue;

        gg_crate_power_on_success(self, gum, new_weapon);
        return;
    }
}

gg_crate_power_should_upgrade(player, weapon, armed_time)
{
    if (!isdefined(weapon) || weapon == "" || weapon == "none")
        return false;

    grace_ms = gg_get_armed_grace_ms();
    if (isdefined(armed_time) && armed_time > 0 && (gettime() - armed_time) < grace_ms)
        return false;

    if (gg_weapon_is_spawn_pistol(weapon))
        return false;

    if (!gg_weapon_is_box_weapon(weapon))
        return false;

    if (gg_weapon_is_wall_buy(weapon))
        return false;

    if (!gg_weapon_has_upgrade(weapon))
        return false;

    if (player maps\_zombiemode_weapons::is_weapon_upgraded(weapon))
        return false;

    return true;
}

gg_crate_power_on_success(player, gum, weapon)
{
    if (!isdefined(player))
        return;

    gg_show_hint_if_enabled(player, "Applied: Crate Power");

    player.gg.armed_flags.crate = false;
    player.gg.armed_flags.crate_power_active = false;

    if (gg_debug_enabled())
        [[ level.gb_helpers.gg_log ]]("crate power upgraded " + weapon);

    wait(0.25);
    if (isdefined(player.gg))
        player.gg.uses_remaining = 0;
    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_consume_use))
        [[ level.gb_hud.br_consume_use ]](player);
    gg_end_current_gum(player, "crate_power_applied");
}

gg_crate_power_token_active(expected_token)
{
    if (!isdefined(self.gg) || !isdefined(self.gg.crate_power_token))
        return false;
    return (self.gg.crate_power_token == expected_token);
}
