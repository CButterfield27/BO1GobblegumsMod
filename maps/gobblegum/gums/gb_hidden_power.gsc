#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

gg_fx_hidden_power(player, gum)
{
    gg_logic_hidden_power_start(player, gum);
}

gg_logic_hidden_power_start(player, gum)
{
    if (!isdefined(player))
        return;

    maps\gobblegum\gb_helpers::gg_mark_activation_skip(player);

    if (!isdefined(player.gg))
        maps\gobblegum\gumballs::build_player_state(player);

    weapon = player GetCurrentWeapon();

    if (!isdefined(weapon) || weapon == "" || weapon == "none")
    {
        gg_hidden_power_fail(player, gum, "skip: invalid weapon", weapon, "Hidden Power: weapon unavailable");
        return;
    }

    if (!player HasWeapon(weapon))
    {
        gg_hidden_power_fail(player, gum, "skip: weapon mismatch", weapon, "Hidden Power: weapon unavailable");
        return;
    }

    if (!maps\gobblegum\gb_helpers::gg_weapon_has_upgrade(weapon))
    {
        gg_hidden_power_fail(player, gum, "skip: no upgrade", weapon, "Hidden Power: no upgrade available");
        return;
    }

    if (player maps\_zombiemode_weapons::is_weapon_upgraded(weapon))
    {
        gg_hidden_power_fail(player, gum, "skip: already upgraded", weapon, "Hidden Power: already upgraded");
        return;
    }

    if (!gg_hidden_power_packapunch_ready())
    {
        gg_hidden_power_fail(player, gum, "skip: pack-a-punch offline", weapon, "Hidden Power: Pack-a-Punch unavailable");
        return;
    }

    if (!maps\gobblegum\gb_helpers::gg_apply_upgrade_for_weapon(player, weapon))
    {
        gg_hidden_power_fail(player, gum, "skip: upgrade helper failed", weapon, "Hidden Power: upgrade failed");
        return;
    }

    gg_hidden_power_on_success(player, gum, weapon);
}

gg_hidden_power_on_success(player, gum, weapon)
{
    if (!isdefined(player))
        return;

    if (maps\gobblegum\gumballs::gg_debug_enabled())
        [[ level.gb_helpers.gg_log ]]("hidden power upgraded " + weapon);

    maps\gobblegum\gb_helpers::gg_show_hint_if_enabled(player, "Applied: Hidden Power");

    wait(0.05);

    if (isdefined(player.gg))
    {
        player.gg.hidden_power_last_debug = undefined;
        player.gg.uses_remaining = 0;
        player.gg.used_this_round = true;
    }

    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_consume_use))
        [[ level.gb_hud.br_consume_use ]](player);

    maps\gobblegum\gb_helpers::gg_on_gum_used();
    maps\gobblegum\gb_helpers::gg_end_current_gum(player, "hidden_power_applied");
}

gg_hidden_power_fail(player, gum, reason, weapon, hint)
{
    gg_hidden_power_debug(player, reason, weapon);

    if (isdefined(hint) && hint != "")
        maps\gobblegum\gb_helpers::gg_show_hint_if_enabled(player, hint);

    gg_hidden_power_refresh_hud(player, gum);
}

gg_hidden_power_refresh_hud(player, gum)
{
    if (!isdefined(player))
        return;
    if (!isdefined(level.gb_hud))
        return;

    if (isdefined(level.gb_hud.show_tc))
        [[ level.gb_hud.show_tc ]](player, gum);
    else if (isdefined(level.gb_hud.update_tc))
        [[ level.gb_hud.update_tc ]](player, gum);

    if (isdefined(level.gb_hud.show_br))
        [[ level.gb_hud.show_br ]](player, gum);
}

gg_hidden_power_debug(player, reason, weapon)
{
    if (!maps\gobblegum\gumballs::gg_debug_enabled())
        return;
    if (!isdefined(player))
        return;

    if (!isdefined(player.gg))
        maps\gobblegum\gumballs::build_player_state(player);

    key = reason;
    if (isdefined(weapon) && weapon != "")
        key = key + ":" + weapon;

    if (isdefined(player.gg.hidden_power_last_debug) && player.gg.hidden_power_last_debug == key)
        return;

    player.gg.hidden_power_last_debug = key;

    msg = "hidden power " + reason;
    if (isdefined(weapon) && weapon != "")
        msg = msg + " (" + weapon + ")";
    [[ level.gb_helpers.gg_log ]](msg);
}

gg_hidden_power_packapunch_ready()
{
    if (isdefined(level.has_pack_a_punch) && !level.has_pack_a_punch)
        return false;

    if (isdefined(level.packapunch_active) && !level.packapunch_active)
        return false;

    return true;
}

register_hidden_power()
{
    gum = spawnstruct();
    gum.id = "hidden_power";
    gum.name = "Hidden Power";
    gum.shader = "bo6_hidden_power";
    gum.desc = "Pack-a-Punch your current weapon instantly.";
    gum.uses_description = "Press D-Pad Right to activate. (1 use)";
    gum.activation = 2; // USER
    gum.consumption = 3; // USES
    gum.base_uses = 1;
    gum.activate_func = ::gg_fx_hidden_power;
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.tags[0] = "weapon";
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    maps\gobblegum\gumballs::gg_register_gum(gum.id, gum);
}
