#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\_hud_util;

// GobbleGum Core (Step 2: round watcher + selection + dummy HUD)

gumballs_init()
{
    gg_init_dvars();

    if (!gg_is_enabled())
        return;

    gg_registry_init();
    gg_init_level_state();
    gg_init_tokens();

    if (level.gg_state.core_started)
        return;

    level.gg_state.core_started = true;

    level thread gg_player_connect_watcher();
    level thread gg_round_watcher();

    if (gg_debug_enabled())
    {
        iprintlnbold("Gumballs: init (registry ready, watcher live)");
    }
}

gg_registry_init()
{
    if (isdefined(level.gg_registry_built) && level.gg_registry_built)
        return;

    level.gg_registry = spawnstruct();
    level.gg_registry.gums = [];
    level.gg_registry.index = spawnstruct();

    level.gg_register_gum = ::gg_register_gum;
    level.gg_find_gum_by_id = ::gg_find_gum_by_id;

    gum = spawnstruct();
    gum.id = "perkaholic";
    gum.name = "Perkaholic";
    gum.shader = "specialty_perk";
    gum.desc = "All map perks";
    gum.activation = 1; // ACT_AUTO
    gum.consumption = 3; // CONS_USES
    gum.activate_key = "gg_fx_perkaholic";
    gum.tags = [];
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    gg_register_gum(gum.id, gum);

    gum = spawnstruct();
    gum.id = "wall_power";
    gum.name = "Wall Power";
    gum.shader = "specialty_ammo";
    gum.desc = "Next wall-buy is PaP";
    gum.activation = 2; // ACT_USER
    gum.consumption = 3; // CONS_USES
    gum.activate_key = "gg_fx_wall_power";
    gum.tags = [];
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    gg_register_gum(gum.id, gum);

    level.gg_registry_built = true;

    gg_log_registry_state("init");
}

gg_register_gum(id, data)
{
    if (!isdefined(id))
        return;

    idx = undefined;
    if (isdefined(level.gg_registry.index[id]))
    {
        idx = level.gg_registry.index[id];
        level.gg_registry.gums[idx] = data;
        return;
    }

    idx = level.gg_registry.gums.size;
    level.gg_registry.gums[idx] = data;
    level.gg_registry.index[id] = idx;
}

gg_find_gum_by_id(id)
{
    if (!isdefined(level.gg_registry) || !isdefined(level.gg_registry.gums))
        return undefined;

    if (isdefined(level.gg_registry.index) && isdefined(level.gg_registry.index[id]))
    {
        return level.gg_registry.gums[level.gg_registry.index[id]];
    }

    // Fallback linear search to handle malformed indexes
    for (i = 0; i < level.gg_registry.gums.size; i++)
    {
        gum = level.gg_registry.gums[i];
        if (!isdefined(gum) || !isdefined(gum.id))
            continue;
        if (gum.id == id)
        {
            return gum;
        }
    }

    return undefined;
}

build_player_state(player)
{
    if (!isdefined(player))
        return;

    if (!isdefined(player.gg))
    {
        player.gg = spawnstruct();
    }

    if (!isdefined(player.gg.selected_id))
        player.gg.selected_id = undefined;

    player.gg.uses_remaining = 0;
    player.gg.rounds_remaining = 0;
    player.gg.timer_endtime = 0;

    if (!isdefined(player.gg.armed_flags))
    {
        player.gg.armed_flags = spawnstruct();
    }
    player.gg.armed_flags.wall = false;
    player.gg.armed_flags.crate = false;
    player.gg.armed_flags.wonder = false;

    if (!isdefined(player.gg.pool_full))
        player.gg.pool_full = [];
    if (!isdefined(player.gg.pool_remaining))
        player.gg.pool_remaining = [];

    if (!isdefined(player.gg.round1_delay_applied))
        player.gg.round1_delay_applied = false;

    if (!isdefined(player.gg.last_selected_round))
        player.gg.last_selected_round = 0;

    if (!isdefined(player.gg.hud) && isdefined(level.gb_hud) && isdefined(level.gb_hud.init_player))
    {
        [[ level.gb_hud.init_player ]](player);
    }
}

gg_set_selected_gum_name(player, gum_id)
{
    if (!isdefined(player))
        return;

    if (!isdefined(player.gg))
    {
        build_player_state(player);
    }

    player.gg.selected_id = gum_id;

    gum = gg_find_gum_by_id(gum_id);
    if (isdefined(gum))
    {
        gg_show_gum_selection(player, gum, undefined);
    }
}

gg_apply_selected_gum(player)
{
    if (gg_debug_enabled())
    {
        iprintlnbold("Gumballs: apply selected gum (no-op, Step 2)");
    }
}

gg_show_gum_selection(player, gum, round_number)
{
    if (!isdefined(player) || !isdefined(gum))
        return;

    if (!isdefined(player.gg))
    {
        build_player_state(player);
    }

    player.gg.selected_id = gum.id;

    msg = "Gumballs: selected " + gum.id;
    if (isdefined(round_number))
    {
        msg = msg + " (round " + round_number + ")";
    }
    gg_log_select(msg);

    if (!isdefined(level.gb_hud))
        return;

    if (isdefined(level.gb_hud.show_tc))
        [[ level.gb_hud.show_tc ]](player, gum);

    if (isdefined(level.gb_hud.hide_tc_after))
    {
        expected_name = "";
        if (isdefined(gum.name))
            expected_name = gum.name;
        tc_secs = gg_get_tc_autohide_secs();
        [[ level.gb_hud.hide_tc_after ]](player, tc_secs, expected_name);
    }

    if (isdefined(level.gb_hud.show_br))
        [[ level.gb_hud.show_br ]](player, gum);
}

gg_init_dvars()
{
    gg_ensure_dvar_int("gg_enable", 1);
    gg_ensure_dvar_int("gg_debug", 0);
    gg_ensure_dvar_float("gg_round1_delay", 10.0);
    gg_ensure_dvar_int("gg_select_cadence_ms", 250);
    gg_ensure_dvar_string("gg_force_gum", "");
    gg_ensure_dvar_int("gg_debug_select", 0);
}

gg_init_level_state()
{
    if (!isdefined(level.gg_state))
    {
        level.gg_state = spawnstruct();
    }

    if (!isdefined(level.gg_state.core_started))
    {
        level.gg_state.core_started = false;
    }
}

gg_init_tokens()
{
    if (!isdefined(level.gg_tokens))
    {
        level.gg_tokens = spawnstruct();
        level.gg_tokens.fade = 0;
    }
}

gg_is_enabled()
{
    return (GetDvarInt("gg_enable") != 0);
}

gg_debug_enabled()
{
    return (GetDvarInt("gg_debug") == 1);
}

gg_debug_select_enabled()
{
    return (GetDvarInt("gg_debug_select") == 1);
}

gg_get_tc_autohide_secs()
{
    if (isdefined(level.gb_helpers) && isdefined(level.gb_helpers.GG_TC_AUTOHIDE_SECS))
    {
        return [[ level.gb_helpers.GG_TC_AUTOHIDE_SECS ]]();
    }
    return 7.5;
}

gg_get_select_interval_secs()
{
    gg_ensure_dvar_int("gg_select_cadence_ms", 250);
    ms = GetDvarInt("gg_select_cadence_ms");
    if (ms < 50)
        ms = 50;
    return ms / 1000.0;
}

gg_get_round1_delay_secs()
{
    gg_ensure_dvar_float("gg_round1_delay", 10.0);
    delay = GetDvarFloat("gg_round1_delay");
    if (delay < 0)
        delay = 0;
    return delay;
}

gg_get_force_gum_id()
{
    gg_ensure_dvar_string("gg_force_gum", "");
    value = GetDvar("gg_force_gum");
    if (!isdefined(value))
        return "";
    return value;
}

gg_clear_force_gum()
{
    SetDvar("gg_force_gum", "");
}

gg_ensure_dvar_int(name, default_value)
{
    current = GetDvar(name);
    if (!isdefined(current) || current == "")
    {
        SetDvar(name, "" + default_value);
    }
}

gg_ensure_dvar_float(name, default_value)
{
    current = GetDvar(name);
    if (!isdefined(current) || current == "")
    {
        SetDvar(name, "" + default_value);
    }
}

gg_ensure_dvar_string(name, default_value)
{
    current = GetDvar(name);
    if (!isdefined(current))
    {
        SetDvar(name, default_value);
        return;
    }
}

gg_player_connect_watcher()
{
    while (true)
    {
        level waittill("connected", player);
        if (!isdefined(player))
            continue;

        gg_start_player_lifecycle(player);
    }
}

gg_start_player_lifecycle(player)
{
    if (!isdefined(player))
        return;

    player thread gg_player_lifecycle();
}

gg_player_lifecycle()
{
    self endon("disconnect");

    gg_initialize_player(self);

    while (true)
    {
        self waittill("spawned_player");
        gg_initialize_player(self);
    }
}

gg_initialize_player(player)
{
    if (!isdefined(player))
        return;

    player notify("gg_gum_cleared");
    gg_init_player_hud(player);
    build_player_state(player);

    // Ensure late joiners get a selection for the current round
    if (gg_is_enabled() && isdefined(level.round_number) && level.round_number > 0)
    {
        if (!isdefined(player.gg.last_selected_round) || player.gg.last_selected_round != level.round_number)
        {
            player thread gg_assign_gum_for_round_thread(level.round_number);
        }
    }
}

gg_init_player_hud(player)
{
    if (!isdefined(level.gb_hud) || !isdefined(level.gb_hud.init_player))
        return;

    [[ level.gb_hud.init_player ]](player);
}

gg_round_watcher()
{
    last_round = undefined;

    while (true)
    {
        if (!gg_is_enabled())
        {
            last_round = undefined;
            wait(0.5);
            continue;
        }

        if (!isdefined(level.round_number))
        {
            wait(gg_get_select_interval_secs());
            continue;
        }

        current_round = level.round_number;
        if (!isdefined(current_round) || current_round <= 0)
        {
            wait(gg_get_select_interval_secs());
            continue;
        }

        if (!isdefined(last_round))
        {
            last_round = current_round;
            gg_handle_round_start(current_round);
        }
        else if (current_round > last_round)
        {
            last_round = current_round;
            gg_handle_round_start(current_round);
        }

        wait(gg_get_select_interval_secs());
    }
}

gg_handle_round_start(round_number)
{
    level notify("gg_round_changed", round_number);

    players = get_players();
    for (i = 0; i < players.size; i++)
    {
        player = players[i];

        if (!gg_is_player_selectable(player))
            continue;

        player notify("gg_gum_cleared");

        if (isdefined(level.gb_hud) && isdefined(level.gb_hud.hide_br))
        {
            [[ level.gb_hud.hide_br ]](player);
        }

        if (isdefined(player.gg) && isdefined(player.gg.last_selected_round) && player.gg.last_selected_round == round_number)
            continue;

        player thread gg_assign_gum_for_round_thread(round_number);
    }
}

gg_assign_gum_for_round_thread(round_number)
{
    self endon("disconnect");
    self endon("gg_gum_cleared");

    gg_assign_gum_for_round(self, round_number);
}

gg_assign_gum_for_round(player, round_number)
{
    if (!gg_is_player_selectable(player))
        return;

    build_player_state(player);

    if (isdefined(player.gg.last_selected_round) && player.gg.last_selected_round == round_number)
        return;

    if (round_number == 1 && (!isdefined(player.gg.round1_delay_applied) || !player.gg.round1_delay_applied))
    {
        wait(gg_get_round1_delay_secs());
        player.gg.round1_delay_applied = true;
    }

    gum = gg_pull_next_gum(player);
    if (!isdefined(gum))
    {
        gg_log_select("Gumballs: no gum available for selection");
        return;
    }

    player.gg.last_selected_round = round_number;
    gg_show_gum_selection(player, gum, round_number);
}

gg_pull_next_gum(player)
{
    if (!isdefined(player))
        return undefined;

    gg_refresh_player_pools(player);

    gum = gg_try_force_gum(player);
    if (isdefined(gum))
        return gum;

    gum = gg_select_random_gum(player);
    if (isdefined(gum))
        return gum;

    gg_reset_player_remaining_pool(player);
    return gg_select_random_gum(player);
}

gg_refresh_player_pools(player)
{
    if (!isdefined(player.gg))
    {
        build_player_state(player);
    }

    // Defensive: ensure registry exists (in case init order got skipped)
    if (!isdefined(level.gg_registry_built) || !level.gg_registry_built)
    {
        gg_registry_init();
    }

    gg_build_player_full_pool(player);
    gg_log_select("Gumballs: pool_full size=" + player.gg.pool_full.size);

    if (!isdefined(player.gg.pool_remaining) || player.gg.pool_remaining.size == 0)
    {
        gg_reset_player_remaining_pool(player);
        gg_log_select("Gumballs: reset selection pool");
    }
}

gg_build_player_full_pool(player)
{
    if (!isdefined(level.gg_registry) || !isdefined(level.gg_registry.gums))
        return;

    if (!isdefined(player.gg.pool_full) || player.gg.pool_full.size == 0)
    {
        player.gg.pool_full = [];
        for (i = 0; i < level.gg_registry.gums.size; i++)
        {
            gum = level.gg_registry.gums[i];
            if (!isdefined(gum) || !isdefined(gum.id))
                continue;

            if (!gg_is_gum_allowed_on_map(gum))
                continue;

            player.gg.pool_full[player.gg.pool_full.size] = gum.id;
        }

        if (player.gg.pool_full.size == 0)
        {
            gg_log_select("Gumballs: pool_full empty after build");
            gg_log_registry_state("pool_build");
        }
    }
}

gg_reset_player_remaining_pool(player)
{
    if (!isdefined(player.gg.pool_full))
        player.gg.pool_full = [];

    player.gg.pool_remaining = [];
    for (i = 0; i < player.gg.pool_full.size; i++)
    {
        id = player.gg.pool_full[i];
        if (isdefined(id))
            player.gg.pool_remaining[player.gg.pool_remaining.size] = id;
    }
}

gg_try_force_gum(player)
{
    forced_id = gg_get_force_gum_id();
    if (forced_id == "")
        return undefined;

    gum = gg_find_gum_by_id(forced_id);
    if (!isdefined(gum))
    {
        gg_log_select("Gumballs: forced gum '" + forced_id + "' not found");
        gg_log_registry_state("force_missing");
        return undefined;
    }

    if (!gg_is_gum_selectable_for_player(player, gum))
    {
        gg_log_select("Gumballs: forced gum '" + forced_id + "' not allowed");
        return undefined;
    }

    gg_remove_gum_from_remaining(player, forced_id);
    gg_clear_force_gum();
    gg_log_select("Gumballs: forced selection -> " + forced_id);
    return gum;
}

gg_select_random_gum(player)
{
    if (!isdefined(player.gg.pool_remaining) || player.gg.pool_remaining.size == 0)
        return undefined;

    attempts = player.gg.pool_remaining.size;
    while (attempts > 0 && player.gg.pool_remaining.size > 0)
    {
        idx = randomint(player.gg.pool_remaining.size);
        gum_id = player.gg.pool_remaining[idx];
        gg_remove_gum_from_remaining(player, gum_id);

        gum = gg_find_gum_by_id(gum_id);
        if (!isdefined(gum))
        {
            attempts--;
            continue;
        }

        if (!gg_is_gum_selectable_for_player(player, gum))
        {
            attempts--;
            continue;
        }

        return gum;
    }

    return undefined;
}

gg_remove_gum_from_remaining(player, gum_id)
{
    if (!isdefined(player.gg.pool_remaining))
        return;

    new_pool = [];
    removed = false;
    for (i = 0; i < player.gg.pool_remaining.size; i++)
    {
        id = player.gg.pool_remaining[i];
        if (!isdefined(id))
            continue;

        if (!removed && id == gum_id)
        {
            removed = true;
            continue;
        }

        new_pool[new_pool.size] = id;
    }
    player.gg.pool_remaining = new_pool;
}

gg_is_gum_allowed_on_map(gum)
{
    if (!isdefined(gum))
        return false;

    mapname = GetDvar("mapname");

    if (isdefined(gum.whitelist) && gum.whitelist.size > 0)
    {
        allowed = false;
        for (i = 0; i < gum.whitelist.size; i++)
        {
            if (gum.whitelist[i] == mapname)
            {
                allowed = true;
                break;
            }
        }
        if (!allowed)
            return false;
    }

    if (isdefined(gum.blacklist) && gum.blacklist.size > 0)
    {
        for (i = 0; i < gum.blacklist.size; i++)
        {
            if (gum.blacklist[i] == mapname)
            {
                return false;
            }
        }
    }

    return true;
}

gg_is_gum_selectable_for_player(player, gum)
{
    if (!isdefined(player) || !isdefined(gum))
        return false;

    if (!gg_is_gum_allowed_on_map(gum))
        return false;

    if (isdefined(gum.id) && gum.id == "perkaholic")
    {
        if (isdefined(level.gb_helpers) && isdefined(level.gb_helpers.player_has_all_map_perks))
        {
            if ([[ level.gb_helpers.player_has_all_map_perks ]](player))
                return false;
        }
    }

    return true;
}

gg_is_player_selectable(player)
{
    if (!isdefined(player))
        return false;

    if (!isalive(player))
        return false;

    return true;
}

gg_log_select(message)
{
    if (!gg_debug_select_enabled())
        return;

    if (!isdefined(message))
        return;

    iprintln(message);
}

gg_log_registry_state(tag)
{
    if (!gg_debug_select_enabled())
        return;

    prefix = "Gumballs: registry";
    if (isdefined(tag))
        prefix = prefix + " (" + tag + ")";

    if (!isdefined(level.gg_registry))
    {
        iprintln(prefix + " missing");
        return;
    }

    size = 0;
    if (isdefined(level.gg_registry.gums))
        size = level.gg_registry.gums.size;
    iprintln(prefix + " size=" + size);

    if (!isdefined(level.gg_registry.gums))
        return;

    for (i = 0; i < level.gg_registry.gums.size; i++)
    {
        gum = level.gg_registry.gums[i];
        id = "<undefined>";
        if (isdefined(gum) && isdefined(gum.id))
            id = gum.id;
        iprintln("Gumballs:   [" + i + "] " + id);
    }
}

// Compatibility stubs (no-op placeholders)

gg_on_gum_used() {}
gg_round_monitor() {}
gg_assign_gum_for_new_round() {}
gg_on_round_flow() {}
gg_on_match_end() {}
