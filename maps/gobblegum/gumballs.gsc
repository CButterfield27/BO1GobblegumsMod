#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\_hud_util;

// GobbleGum Core (Step 3: dispatcher + input + dummy effects)

gumballs_init()
{
    gg_init_dvars();
    gg_init_dispatcher();

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
    gum.activate_func = "gg_fx_perkaholic";
    gum.activate_key = gum.activate_func;
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
    gum.activate_func = "gg_fx_wall_power";
    gum.activate_key = gum.activate_func;
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

    if (!isdefined(player.gg.input_block_until))
        player.gg.input_block_until = 0;

    if (!isdefined(player.gg.input_listener_bound))
        player.gg.input_listener_bound = false;

    if (!isdefined(player.gg.input_thread_started))
        player.gg.input_thread_started = false;

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

    gg_on_selected(player, gum);
}

gg_init_dvars()
{
    gg_ensure_dvar_int("gg_enable", 1);
    gg_ensure_dvar_int("gg_debug", 0);
    gg_ensure_dvar_float("gg_round1_delay", 10.0);
    gg_ensure_dvar_int("gg_select_cadence_ms", 250);
    gg_ensure_dvar_string("gg_force_gum", "");
    gg_ensure_dvar_int("gg_debug_select", 0);
    gg_ensure_dvar_int("gg_input_enable", 1);
    gg_ensure_dvar_int("gg_debounce_ms", 200);
    gg_ensure_dvar_int("gg_log_dispatch", 1);
    gg_ensure_dvar_int("gg_auto_on_select", 1);
    gg_ensure_dvar_int("gg_simulate_effects", 0);
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
    gg_bind_input_listener(player);
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


gg_input_enabled()
{
    gg_ensure_dvar_int("gg_input_enable", 1);
    return (GetDvarInt("gg_input_enable") != 0);
}

gg_get_debounce_ms()
{
    gg_ensure_dvar_int("gg_debounce_ms", 200);
    ms = GetDvarInt("gg_debounce_ms");
    if (ms < 0)
        ms = 0;
    return ms;
}

gg_log_dispatch_enabled()
{
    gg_ensure_dvar_int("gg_log_dispatch", 1);
    return (GetDvarInt("gg_log_dispatch") == 1);
}

gg_auto_on_select_enabled()
{
    gg_ensure_dvar_int("gg_auto_on_select", 1);
    return (GetDvarInt("gg_auto_on_select") != 0);
}

gg_simulate_effects_enabled()
{
    gg_ensure_dvar_int("gg_simulate_effects", 0);
    return (GetDvarInt("gg_simulate_effects") == 1);
}

gg_should_log_dispatch()
{
    return (gg_debug_enabled() || gg_log_dispatch_enabled());
}

gg_act_auto()
{
    if (isdefined(level.gb_helpers) && isdefined(level.gb_helpers.ACT_AUTO))
        return [[ level.gb_helpers.ACT_AUTO ]]();
    return 1;
}

gg_act_user()
{
    if (isdefined(level.gb_helpers) && isdefined(level.gb_helpers.ACT_USER))
        return [[ level.gb_helpers.ACT_USER ]]();
    return 2;
}

gg_is_auto_activation(gum)
{
    return (isdefined(gum) && isdefined(gum.activation) && gum.activation == gg_act_auto());
}

gg_is_user_activation(gum)
{
    return (isdefined(gum) && isdefined(gum.activation) && gum.activation == gg_act_user());
}

gg_get_selected_gum(player)
{
    if (!isdefined(player) || !isdefined(player.gg) || !isdefined(player.gg.selected_id))
        return undefined;

    return gg_find_gum_by_id(player.gg.selected_id);
}

gg_get_gum_activate_func(gum)
{
    if (!isdefined(gum))
        return "";

    if (isdefined(gum.activate_func) && gum.activate_func != "")
        return gum.activate_func;

    if (isdefined(gum.activate_key) && gum.activate_key != "")
        return gum.activate_key;

    return "";
}

gg_clear_activation_debounce(player)
{
    if (!isdefined(player) || !isdefined(player.gg))
        return;

    player.gg.input_block_until = 0;
}

gg_apply_activation_debounce(player)
{
    if (!isdefined(player) || !isdefined(player.gg))
        return;

    ms = gg_get_debounce_ms();
    player.gg.input_block_until = gettime() + ms;
}

gg_bind_input_listener(player)
{
    if (!isdefined(player))
        return;

    if (!isdefined(player.gg))
    {
        build_player_state(player);
    }

    if (!isdefined(player.gg.input_listener_bound) || !player.gg.input_listener_bound)
    {
        player notifyOnPlayerCommand("gg_activate_gum", "+actionslot 4");
        player.gg.input_listener_bound = true;
    }

    if (!isdefined(player.gg.input_thread_started) || !player.gg.input_thread_started)
    {
        player.gg.input_thread_started = true;
        player thread gg_input_command_watcher();
    }
}

gg_input_command_watcher()
{
    self endon("disconnect");

    while (true)
    {
        self waittill("gg_activate_gum");

        if (!gg_input_enabled())
            continue;

        gum = gg_get_selected_gum(self);
        if (!isdefined(gum))
            continue;

        if (gg_is_user_activation(gum))
        {
            gg_try_activate(self, "USER");
        }
    }
}

gg_on_selected(player, gum)
{
    if (!isdefined(player))
        return;

    if (!isdefined(player.gg))
    {
        build_player_state(player);
    }

    gg_clear_activation_debounce(player);

    if (!isdefined(gum))
        return;

    if (gg_is_auto_activation(gum))
    {
        if (!gg_auto_on_select_enabled())
            return;

        gg_try_activate(player, "AUTO");
    }
}

gg_can_activate_now(player)
{
    if (!gg_is_enabled())
        return false;

    if (!isdefined(player) || !isdefined(player.gg))
        return false;

    if (!isdefined(player.gg.selected_id) || player.gg.selected_id == undefined || player.gg.selected_id == "")
        return false;

    gum = gg_get_selected_gum(player);
    if (!isdefined(gum))
        return false;

    if (isdefined(player.gg.input_block_until) && player.gg.input_block_until > gettime())
        return false;

    return true;
}

gg_try_activate(player, source)
{
    if (!isdefined(source))
        source = "USER";

    if (!gg_can_activate_now(player))
        return false;

    gum = gg_get_selected_gum(player);
    if (!isdefined(gum))
        return false;

    if (source == "USER" && gg_is_auto_activation(gum))
        return false;
    if (source == "AUTO" && !gg_is_auto_activation(gum))
        return false;

    func_name = gg_get_gum_activate_func(gum);
    if (func_name == "")
        return false;

    path = gg_dispatch_effect(player, gum, func_name);
    if (path == "")
    {
        if (gg_should_log_dispatch())
        {
            iprintln("Gumballs: dispatch failed for " + func_name);
        }
        return false;
    }

    if (gg_should_log_dispatch())
    {
        msg = "Gumballs: activated " + gum.id + " via " + gg_dispatch_source_label(source) + " (" + path + ")";
        iprintln(msg);
    }

    gg_apply_activation_debounce(player);
    return true;
}

gg_dispatch_source_label(source)
{
    if (!isdefined(source) || source == "")
        return "USER";

    return source;
}

gg_init_dispatcher()
{
    if (!isdefined(level.gg_dispatcher))
    {
        level.gg_dispatcher = spawnstruct();
        level.gg_dispatcher.map = spawnstruct();
        level.gg_dispatcher.handlers = [];
        level.gg_dispatcher.names = [];
    }

    gg_register_dispatcher_entry("gg_fx_perkaholic", ::gg_fx_perkaholic);
    gg_register_dispatcher_entry("gg_fx_wall_power", ::gg_fx_wall_power);
    gg_register_dispatcher_entry("gg_fx_cache_back", ::gg_fx_cache_back);
    gg_register_dispatcher_entry("gg_fx_kill_joy", ::gg_fx_kill_joy);
    gg_register_dispatcher_entry("gg_fx_dead_of_nuclear_winter", ::gg_fx_dead_of_nuclear_winter);
    gg_register_dispatcher_entry("gg_fx_immolation", ::gg_fx_immolation);
    gg_register_dispatcher_entry("gg_fx_on_the_house", ::gg_fx_on_the_house);
    gg_register_dispatcher_entry("gg_fx_fatal_contraption", ::gg_fx_fatal_contraption);
    gg_register_dispatcher_entry("gg_fx_extra_credit", ::gg_fx_extra_credit);
    gg_register_dispatcher_entry("gg_fx_reign_drops", ::gg_fx_reign_drops);
    gg_register_dispatcher_entry("gg_fx_hidden_power", ::gg_fx_hidden_power);
    gg_register_dispatcher_entry("gg_fx_crate_power", ::gg_fx_crate_power);
    gg_register_dispatcher_entry("gg_fx_wonderbar", ::gg_fx_wonderbar);
    gg_register_dispatcher_entry("gg_fx_round_robbin", ::gg_fx_round_robbin);
    gg_register_dispatcher_entry("gg_fx_shopping_free", ::gg_fx_shopping_free);
    gg_register_dispatcher_entry("gg_fx_stock_option", ::gg_fx_stock_option);
    gg_register_dispatcher_entry("gg_fx_near_death", ::gg_fx_near_death);
    gg_register_dispatcher_entry("gg_fx_respin_cycle", ::gg_fx_respin_cycle);
    if (gg_should_log_dispatch())
    {
        size = 0;
        if (isdefined(level.gg_dispatcher.handlers))
            size = level.gg_dispatcher.handlers.size;
        iprintln("Gumballs: dispatcher ready (size=" + size + ")");
    }
}


gg_register_dispatcher_entry(name, func)
{
    if (!isdefined(level.gg_dispatcher))
        return;

    if (!isdefined(name) || name == "")
        return;

    if (!isdefined(level.gg_dispatcher.map))
        level.gg_dispatcher.map = spawnstruct();
    if (!isdefined(level.gg_dispatcher.handlers))
        level.gg_dispatcher.handlers = [];
    if (!isdefined(level.gg_dispatcher.names))
        level.gg_dispatcher.names = [];

    if (isdefined(level.gg_dispatcher.map[name]))
    {
        code = level.gg_dispatcher.map[name];
        level.gg_dispatcher.handlers[code] = func;
        return;
    }

    code = level.gg_dispatcher.handlers.size;
    level.gg_dispatcher.map[name] = code;
    level.gg_dispatcher.handlers[code] = func;
    level.gg_dispatcher.names[code] = name;
}

gg_lookup_dispatch_code(name)
{
    if (!isdefined(level.gg_dispatcher) || !isdefined(level.gg_dispatcher.map))
        return -1;

    if (!isdefined(name) || name == "")
        return -1;

    if (isdefined(level.gg_dispatcher.map[name]))
        return level.gg_dispatcher.map[name];

    return -1;
}

gg_get_dispatch_handler(code)
{
    if (!isdefined(level.gg_dispatcher) || !isdefined(level.gg_dispatcher.handlers))
        return undefined;

    if (!isdefined(code))
        return undefined;

    if (code < 0 || code >= level.gg_dispatcher.handlers.size)
        return undefined;

    return level.gg_dispatcher.handlers[code];
}

gg_is_callable(handler)
{
    return (isdefined(handler) || handler != undefined);
}

gg_dispatch_effect(player, gum, func_name)
{
    if (!isdefined(func_name) || func_name == "")
        return "";

    code = gg_lookup_dispatch_code(func_name);
    if (code != -1)
    {
        handler = gg_get_dispatch_handler(code);
        if (gg_is_callable(handler))
        {
            if (gg_should_log_dispatch())
            {
                iprintln("Gumballs: dispatch -> " + func_name + " (map)");
            }
            [[ handler ]](player, gum);
            return "map";
        }

        if (gg_debug_enabled())
        {
            iprintln("Gumballs: dispatch map entry missing handler for '" + func_name + "'");
        }
    }
    else
    {
        // Try a linear search over registered names as a robustness fallback
        if (isdefined(level.gg_dispatcher) && isdefined(level.gg_dispatcher.names))
        {
            for (i = 0; i < level.gg_dispatcher.names.size; i++)
            {
                if (level.gg_dispatcher.names[i] == func_name)
                {
                    handler = gg_get_dispatch_handler(i);
                    if (gg_is_callable(handler))
                    {
                        if (gg_should_log_dispatch())
                        {
                            iprintln("Gumballs: dispatch -> " + func_name + " (map)");
                        }
                        [[ handler ]](player, gum);
                        return "map";
                    }
                }
            }
        }

        if (gg_should_log_dispatch())
        {
            size = 0;
            if (isdefined(level.gg_dispatcher.handlers))
                size = level.gg_dispatcher.handlers.size;
            iprintln("Gumballs: dispatcher lookup miss for " + func_name + ", registered=" + size);
        }
    }

    handler = gg_dispatch_string_fallback(func_name);
    if (gg_is_callable(handler))
    {
        if (gg_should_log_dispatch())
        {
            iprintln("Gumballs: dispatch -> " + func_name + " (fallback)");
        }
        [[ handler ]](player, gum);
        return "fallback";
    }

    if (gg_should_log_dispatch())
    {
        iprintln("Gumballs: missing dispatch handler for '" + func_name + "'");
    }

    return "";
}

gg_dispatch_string_fallback(func_name)
{
    if (!isdefined(func_name) || func_name == "")
        return undefined;

    if (func_name == "gg_fx_perkaholic")
        return ::gg_fx_perkaholic;
    if (func_name == "gg_fx_wall_power")
        return ::gg_fx_wall_power;
    if (func_name == "gg_fx_cache_back")
        return ::gg_fx_cache_back;
    if (func_name == "gg_fx_kill_joy")
        return ::gg_fx_kill_joy;
    if (func_name == "gg_fx_dead_of_nuclear_winter")
        return ::gg_fx_dead_of_nuclear_winter;
    if (func_name == "gg_fx_immolation")
        return ::gg_fx_immolation;
    if (func_name == "gg_fx_on_the_house")
        return ::gg_fx_on_the_house;
    if (func_name == "gg_fx_fatal_contraption")
        return ::gg_fx_fatal_contraption;
    if (func_name == "gg_fx_extra_credit")
        return ::gg_fx_extra_credit;
    if (func_name == "gg_fx_reign_drops")
        return ::gg_fx_reign_drops;
    if (func_name == "gg_fx_hidden_power")
        return ::gg_fx_hidden_power;
    if (func_name == "gg_fx_crate_power")
        return ::gg_fx_crate_power;
    if (func_name == "gg_fx_wonderbar")
        return ::gg_fx_wonderbar;
    if (func_name == "gg_fx_round_robbin")
        return ::gg_fx_round_robbin;
    if (func_name == "gg_fx_shopping_free")
        return ::gg_fx_shopping_free;
    if (func_name == "gg_fx_stock_option")
        return ::gg_fx_stock_option;
    if (func_name == "gg_fx_near_death")
        return ::gg_fx_near_death;
    if (func_name == "gg_fx_respin_cycle")
        return ::gg_fx_respin_cycle;

    return undefined;
}

gg_effect_stub_common(player, gum, category)
{
    if (!isdefined(player) || !isdefined(gum))
        return;

    gum_id = "<unknown>";
    if (isdefined(gum.id))
        gum_id = gum.id;

    gum_name = gum_id;
    if (isdefined(gum.name) && gum.name != "")
        gum_name = gum.name;

    if (gg_log_dispatch_enabled())
    {
        iprintln("Gumballs: effect stub [" + category + "] -> " + gum_id);
    }

    if (!gg_simulate_effects_enabled())
        return;

    if (!isdefined(level.gb_hud) || !isdefined(level.gb_hud.set_hint))
        return;

    [[ level.gb_hud.set_hint ]](player, "Activated: " + gum_name);
}

// Power-Ups

gg_fx_cache_back(player, gum)
{
    gg_effect_stub_common(player, gum, "Power-Up");
}

gg_fx_kill_joy(player, gum)
{
    gg_effect_stub_common(player, gum, "Power-Up");
}

gg_fx_dead_of_nuclear_winter(player, gum)
{
    gg_effect_stub_common(player, gum, "Power-Up");
}

gg_fx_immolation(player, gum)
{
    gg_effect_stub_common(player, gum, "Power-Up");
}

gg_fx_fatal_contraption(player, gum)
{
    gg_effect_stub_common(player, gum, "Power-Up");
}

gg_fx_reign_drops(player, gum)
{
    gg_effect_stub_common(player, gum, "Power-Up");
}

// Weapons & Perks

gg_fx_perkaholic(player, gum)
{
    gg_effect_stub_common(player, gum, "Weapons/Perks");
}

gg_fx_wall_power(player, gum)
{
    gg_effect_stub_common(player, gum, "Weapons/Perks");
}

gg_fx_on_the_house(player, gum)
{
    gg_effect_stub_common(player, gum, "Weapons/Perks");
}

gg_fx_hidden_power(player, gum)
{
    gg_effect_stub_common(player, gum, "Weapons/Perks");
}

gg_fx_crate_power(player, gum)
{
    gg_effect_stub_common(player, gum, "Weapons/Perks");
}

gg_fx_wonderbar(player, gum)
{
    gg_effect_stub_common(player, gum, "Weapons/Perks");
}

// Economy & Round

gg_fx_extra_credit(player, gum)
{
    gg_effect_stub_common(player, gum, "Economy/Round");
}

gg_fx_round_robbin(player, gum)
{
    gg_effect_stub_common(player, gum, "Economy/Round");
}

gg_fx_shopping_free(player, gum)
{
    gg_effect_stub_common(player, gum, "Economy/Round");
}

gg_fx_stock_option(player, gum)
{
    gg_effect_stub_common(player, gum, "Economy/Round");
}

// Placeholders

gg_fx_near_death(player, gum)
{
    gg_effect_stub_common(player, gum, "Placeholder");
}

gg_fx_respin_cycle(player, gum)
{
    gg_effect_stub_common(player, gum, "Placeholder");
}
// Compatibility stubs (no-op placeholders)

gg_on_gum_used() {}
gg_round_monitor() {}
gg_assign_gum_for_new_round() {}
gg_on_round_flow() {}
gg_on_match_end() {}


