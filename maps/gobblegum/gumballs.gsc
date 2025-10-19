#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\_hud_util;

gumballs_init()
{
    gg_init_dvars();
    gg_init_dispatcher();
    gg_init_powerup_tables();

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
    gum.shader = "bo6_perkaholic";
    gum.desc = "All map perks";
    gum.activation = 1; // ACT_AUTO
    gum.consumption = 3; // CONS_USES (uses-based)
    gum.base_uses = 1;
    gum.activate_func = "gg_fx_perkaholic";
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.tags[0] = "perk";
    gum.whitelist = [];
    gum.blacklist = [];
    gum.blacklist[gum.blacklist.size] = "zombie_theater";
    gum.blacklist[gum.blacklist.size] = "theater";
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    gg_register_gum(gum.id, gum);

    gum = spawnstruct();
    gum.id = "wall_power";
    gum.name = "Wall Power";
    gum.shader = "bo6_wall_power";
    gum.desc = "Next wall-buy is PaP";
    gum.activation = 2; // USER
    gum.consumption = 3; // USES
    gum.base_uses = 1;
    gum.activate_func = "gg_fx_wall_power";
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.tags[0] = "weapon";
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    gg_register_gum(gum.id, gum);
    
    // Cache Back (Max Ammo) - Uses
    gum = spawnstruct();
    gum.id = "cache_back";
    gum.name = "Cache Back";
    gum.shader = "bo6_cache_back";
    gum.desc = "Spawns a Max Ammo Power-Up";
    gum.activation = 2; // USER
    gum.consumption = 3; // USES
    gum.base_uses = 1;
    gum.activate_func = "gg_fx_cache_back";
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    gg_register_gum(gum.id, gum);

    // Crate Power - Uses (AUTO per prior list)
    gum = spawnstruct();
    gum.id = "crate_power";
    gum.name = "Crate Power";
    gum.shader = "bo6_crate_power";
    gum.desc = "Next Mystery Box gun is PaP";
    gum.activation = 1; // AUTO
    gum.consumption = 3; // USES
    gum.base_uses = 1;
    gum.activate_func = "gg_fx_crate_power";
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.tags[0] = "weapon";
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    gg_register_gum(gum.id, gum);

    // Dead of Nuclear Winter (Nuke) - Uses
    gum = spawnstruct();
    gum.id = "dead_of_nuclear_winter";
    gum.name = "Dead of Nuclear Winter";
    gum.shader = "t7_hud_zm_bgb_dead_of_nuclear_winter";
    gum.desc = "Spawns a Nuke Power-Up";
    gum.activation = 2; // USER
    gum.consumption = 3; // USES
    gum.base_uses = 2;
    gum.activate_func = "gg_fx_dead_of_nuclear_winter";
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    gg_register_gum(gum.id, gum);

    // Extra Credit (Bonus Points) - Uses
    gum = spawnstruct();
    gum.id = "extra_credit";
    gum.name = "Extra Credit";
    gum.shader = "t7_hud_zm_bgb_extra_credit";
    gum.desc = "Spawns a Bonus Points Power-Up";
    gum.activation = 2; // USER
    gum.consumption = 3; // USES
    gum.base_uses = 4;
    gum.activate_func = "gg_fx_extra_credit";
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    gg_register_gum(gum.id, gum);

    // Fatal Contraption (Death Machine) - Uses (map-allowed)
    gum = spawnstruct();
    gum.id = "fatal_contraption";
    gum.name = "Fatal Contraption";
    gum.shader = "t7_hud_zm_bgb_fatal_contraption";
    gum.desc = "Spawns a Death Machine Power-Up";
    gum.activation = 2; // USER
    gum.consumption = 3; // USES
    gum.base_uses = 2;
    gum.activate_func = "gg_fx_fatal_contraption";
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    gg_register_gum(gum.id, gum);

    // Hidden Power - Uses
    gum = spawnstruct();
    gum.id = "hidden_power";
    gum.name = "Hidden Power";
    gum.shader = "bo6_hidden_power";
    gum.desc = "PaP current weapon";
    gum.activation = 2; // USER
    gum.consumption = 3; // USES
    gum.base_uses = 1;
    gum.activate_func = "gg_fx_hidden_power";
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    // gg_register_gum(gum.id, gum);

    // Immolation Liquidation (Fire Sale) - Uses
    gum = spawnstruct();
    gum.id = "immolation";
    gum.name = "Immolation Liquidation";
    gum.shader = "bo6_immolation_liquidation";
    gum.desc = "Spawns a Fire Sale Power-Up";
    gum.activation = 2; // USER
    gum.consumption = 3; // USES
    gum.base_uses = 3;
    gum.activate_func = "gg_fx_immolation";
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    gg_register_gum(gum.id, gum);

    // Kill Joy (Insta Kill) - Uses
    gum = spawnstruct();
    gum.id = "kill_joy";
    gum.name = "Kill Joy";
    gum.shader = "bo6_kill_joy";
    gum.desc = "Spawns an Insta-Kill Power-Up";
    gum.activation = 2; // USER
    gum.consumption = 3; // USES
    gum.base_uses = 2;
    gum.activate_func = "gg_fx_kill_joy";
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    gg_register_gum(gum.id, gum);

    // Licensed Contractor (Carpenter) - Uses
    gum = spawnstruct();
    gum.id = "licensed_contractor";
    gum.name = "Licensed Contractor";
    gum.shader = "t7_hud_zm_bgb_licensed_contractor";
    gum.desc = "Spawns a Carpenter Power-Up";
    gum.activation = 2; // USER
    gum.consumption = 3; // USES
    gum.base_uses = 3;
    gum.activate_func = "gg_fx_licensed_contractor";
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    gg_register_gum(gum.id, gum);

    // On the House (Free Perk) - Uses
    gum = spawnstruct();
    gum.id = "on_the_house";
    gum.name = "On the House";
    gum.shader = "bo6_on_the_house";
    gum.desc = "Spawns a free perk Power-Up";
    gum.activation = 2; // USER
    gum.consumption = 3; // USES
    gum.base_uses = 1;
    gum.activate_func = "gg_fx_on_the_house";
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    gg_register_gum(gum.id, gum);

    // Reign Drops - Uses (Build 5 test: two activations)
    gum = spawnstruct();
    gum.id = "reign_drops";
    gum.name = "Reign Drops";
    gum.shader = "bo6_reign_drops";
    gum.desc = "Spawns all core Power-Ups at once";
    gum.activation = 2; // USER
    gum.consumption = 3; // USES
    gum.base_uses = 2;
    gum.activate_func = "gg_fx_reign_drops";
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    gg_register_gum(gum.id, gum);

    // Round Robbin - Uses (instant)
    gum = spawnstruct();
    gum.id = "round_robbin";
    gum.name = "Round Robbin";
    gum.shader = "t7_hud_zm_bgb_round_robbin";
    gum.desc = "Ends the current round. All players gain 1600 points";
    gum.activation = 2; // USER
    gum.consumption = 3; // USES
    gum.base_uses = 1;
    gum.activate_func = "gg_fx_round_robbin";
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.tags[0] = "economy";
    gum.tags[1] = "round";
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    gg_register_gum(gum.id, gum);

    // Shopping Free - Timed (TEST: timed-based)
    gum = spawnstruct();
    gum.id = "shopping_free";
    gum.name = "Shopping Free";
    gum.shader = "t7_hud_zm_bgb_shopping_free";
    gum.desc = "All purchases are free";
    gum.activation = 2; // USER
    gum.consumption = 1; // TIMED
    gum.base_duration_secs = gg_get_shopping_free_secs();
    gum.activate_func = "gg_fx_shopping_free";
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.tags[0] = "economy";
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    gg_register_gum(gum.id, gum);

    // Stock Option - Timed
    gum = spawnstruct();
    gum.id = "stock_option";
    gum.name = "Stock Option";
    gum.shader = "bo6_stock_option";
    gum.desc = "Ammo is taken from the player's stockpile";
    gum.activation = 2; // USER
    gum.consumption = 1; // TIMED
    gum.base_duration_secs = 60;
    gum.activate_func = "gg_fx_stock_option";
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    // gg_register_gum(gum.id, gum);

    // Who's Keeping Score (Double Points) - Uses
    gum = spawnstruct();
    gum.id = "whos_keeping_score";
    gum.name = "Who's Keeping Score";
    gum.shader = "bo6_who_keeping_score";
    gum.desc = "Spawns a Double Points Power-Up";
    gum.activation = 2; // USER
    gum.consumption = 3; // USES
    gum.base_uses = 2;
    gum.activate_func = "gg_fx_whos_keeping_score";
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    gg_register_gum(gum.id, gum);

    // Wonderbar - Uses (armed)
    gum = spawnstruct();
    gum.id = "wonderbar";
    gum.name = "Wonderbar";
    gum.shader = "bo6_wonderbar";
    gum.desc = "Next box gun is Wonder Weapon";
    gum.activation = 1; // AUTO
    gum.consumption = 3; // USES
    gum.base_uses = 1;
    gum.activate_func = "gg_fx_wonderbar";
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.tags[0] = "weapon";
    gum.tags[1] = "wonder";
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

    if (!isdefined(player.gg.selection_active))
        player.gg.selection_active = false;

    if (!isdefined(player.gg.effect_active))
        player.gg.effect_active = false;

    if (!isdefined(player.gg.effect_id))
        player.gg.effect_id = undefined;

    // Consumption model runtime state (Build 5)
    if (!isdefined(player.gg.consumption_type))
        player.gg.consumption_type = undefined;

    player.gg.uses_remaining = 0;
    player.gg.rounds_remaining = 0;
    player.gg.timer_endtime = 0;

    if (!isdefined(player.gg.active_token))
        player.gg.active_token = 0;

    if (!isdefined(player.gg.is_active))
        player.gg.is_active = false;

    if (!isdefined(player.gg.last_round_ticked))
        player.gg.last_round_ticked = 0;

    if (!isdefined(player.gg.used_this_round))
        player.gg.used_this_round = false;

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
    player.gg.armed_flags.crate_power_active = false;
    player.gg.armed_flags.wonder = false;
    player.gg.armed_flags.wonderbar_active = false;

    if (!isdefined(player.gg.wall_power_token))
        player.gg.wall_power_token = 0;
    if (!isdefined(player.gg.crate_power_token))
        player.gg.crate_power_token = 0;
    if (!isdefined(player.gg.armed_since))
        player.gg.armed_since = 0;
    if (!isdefined(player.gg.crate_power_armed_time))
        player.gg.crate_power_armed_time = 0;
    if (!isdefined(player.gg.wonderbar_armed_time))
        player.gg.wonderbar_armed_time = 0;
    if (!isdefined(player.gg.wonderbar_token))
        player.gg.wonderbar_token = 0;
    if (!isdefined(player.gg.reign_drops_token))
        player.gg.reign_drops_token = 0;
    if (!isdefined(player.gg.wonderbar_label_token))
        player.gg.wonderbar_label_token = 0;
    if (!isdefined(player.gg.wonderbar_choice))
        player.gg.wonderbar_choice = undefined;
    if (!isdefined(player.gg.wonderbar_label_text))
        player.gg.wonderbar_label_text = "";
    if (!isdefined(player.gg.wonderbar_suppress_until))
        player.gg.wonderbar_suppress_until = 0;

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
    player.gg.selection_active = true;
    player.gg.effect_active = false;
    player.gg.effect_id = undefined;
    player.gg.used_this_round = false;

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

    // Seed consumption state for the selected gum and configure BR bar
    gg_seed_consumption_state(player, gum);

    gg_on_selected(player, gum);
}

gg_selection_is_active(player)
{
    if (!isdefined(player) || !isdefined(player.gg))
        return false;

    return (isdefined(player.gg.selection_active) && player.gg.selection_active);
}

gg_set_effect_state(player, gum, is_active)
{
    if (!isdefined(player) || !isdefined(player.gg))
        return;

    if (!isdefined(is_active) || !is_active)
    {
        player.gg.effect_active = false;
        player.gg.effect_id = undefined;
        return;
    }

    player.gg.effect_active = true;
    if (isdefined(gum) && isdefined(gum.id))
        player.gg.effect_id = gum.id;
}

gg_selection_close(player, reason, hide_ui, reset_state)
{
    if (!isdefined(player) || !isdefined(player.gg))
        return;

    if (!isdefined(player.gg.selection_active) || !player.gg.selection_active)
        return;

    if (!isdefined(hide_ui))
        hide_ui = true;

    if (!isdefined(reset_state))
        reset_state = false;

    player.gg.selection_active = false;
    player.gg.selected_id = undefined;
    if (isdefined(reason))
        player.gg.last_selection_close_reason = reason;

    if (hide_ui && isdefined(level.gb_hud))
    {
        if (isdefined(level.gb_hud.br_stop_timer))
            [[ level.gb_hud.br_stop_timer ]](player);
        if (isdefined(level.gb_hud.br_clear_label))
            [[ level.gb_hud.br_clear_label ]](player);
        if (isdefined(level.gb_hud.hide_br))
            [[ level.gb_hud.hide_br ]](player);
    }

    if (reset_state)
    {
        player.gg.consumption_type = undefined;
        player.gg.uses_remaining = 0;
        player.gg.rounds_remaining = 0;
        player.gg.timer_endtime = 0;
        player.gg.is_active = false;
        player.gg.used_this_round = false;
        player.gg.last_round_ticked = 0;
        player.gg.effect_active = false;
        player.gg.effect_id = undefined;
    }

    if (gg_debug_select_enabled() && isdefined(reason))
        gg_log_select("Gumballs: selection closed (" + reason + ")");
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

    // Build 5 consumption defaults
    gg_ensure_dvar_int("gg_default_uses", 3);
    gg_ensure_dvar_int("gg_default_rounds", 3);
    gg_ensure_dvar_float("gg_default_timer_secs", 60.0);
    gg_ensure_dvar_int("gg_timer_tick_ms", 100);
    gg_ensure_dvar_int("gg_consume_logs", 1);

    // Build 6 power-up knobs
    gg_ensure_dvar_float("gg_drop_forward_units", 70.0);
    gg_ensure_dvar_float("gg_reigndrops_forward_units", 145.0);
    gg_ensure_dvar_float("gg_reigndrops_radius", 70.0);
    gg_ensure_dvar_int("gg_reigndrops_spacing_ms", 150);
    gg_ensure_dvar_int("gg_reigndrops_include_firesale", 1);
    gg_ensure_dvar_int("gg_powerup_hints", 1);
    gg_ensure_dvar_float("gg_armed_grace_secs", 3.0);
    gg_ensure_dvar_int("gg_armed_poll_ms", 150);
    gg_ensure_dvar_int("gg_test_drop_firesale_on_arm", 1);
    gg_ensure_dvar_int("gg_wonder_label_reassert_ms", 250);
    gg_ensure_dvar_int("gg_wonder_include_specials", 0);

    // Build 8 round/economy knobs
    gg_ensure_dvar_int("gg_round_robbin_bonus", 1600);
    gg_ensure_dvar_int("gg_round_robbin_force_transition", 1);
    gg_ensure_dvar_float("gg_shopping_free_secs", 60.0);
    gg_ensure_dvar_int("gg_shopping_free_temp_points", 50000);
    gg_ensure_dvar_int("gg_perkaholic_grant_delay_ms", 250);

    // Cache commonly used defaults for quick access
    gg_cache_config();
}

gg_cache_config()
{
    if (!isdefined(level.gg_config))
    {
        level.gg_config = spawnstruct();
    }

    level.gg_config.default_uses = GetDvarInt("gg_default_uses");
    if (level.gg_config.default_uses <= 0)
        level.gg_config.default_uses = 1;

    level.gg_config.default_rounds = GetDvarInt("gg_default_rounds");
    if (level.gg_config.default_rounds <= 0)
        level.gg_config.default_rounds = 1;

    level.gg_config.default_timer_secs = GetDvarFloat("gg_default_timer_secs");
    if (level.gg_config.default_timer_secs <= 0)
        level.gg_config.default_timer_secs = 1.0;

    level.gg_config.timer_tick_ms = GetDvarInt("gg_timer_tick_ms");
    if (level.gg_config.timer_tick_ms < 10)
        level.gg_config.timer_tick_ms = 10;

    level.gg_config.consume_logs = (GetDvarInt("gg_consume_logs") != 0);

    level.gg_config.drop_forward_units = GetDvarFloat("gg_drop_forward_units");
    if (level.gg_config.drop_forward_units <= 0)
        level.gg_config.drop_forward_units = 70.0;

    level.gg_config.reigndrops_forward_units = GetDvarFloat("gg_reigndrops_forward_units");
    if (level.gg_config.reigndrops_forward_units <= 0)
        level.gg_config.reigndrops_forward_units = 145.0;

    level.gg_config.reigndrops_radius = GetDvarFloat("gg_reigndrops_radius");
    if (level.gg_config.reigndrops_radius <= 0)
        level.gg_config.reigndrops_radius = 70.0;

    level.gg_config.reigndrops_spacing_ms = GetDvarInt("gg_reigndrops_spacing_ms");
    if (level.gg_config.reigndrops_spacing_ms < 0)
        level.gg_config.reigndrops_spacing_ms = 0;

    level.gg_config.reigndrops_include_firesale = (GetDvarInt("gg_reigndrops_include_firesale") != 0);
    level.gg_config.powerup_hints = (GetDvarInt("gg_powerup_hints") != 0);
    level.gg_config.wonder_include_specials = (GetDvarInt("gg_wonder_include_specials") != 0);

    level.gg_config.armed_grace_secs = GetDvarFloat("gg_armed_grace_secs");
    if (level.gg_config.armed_grace_secs < 0)
        level.gg_config.armed_grace_secs = 0;

    level.gg_config.armed_poll_ms = GetDvarInt("gg_armed_poll_ms");
    if (level.gg_config.armed_poll_ms < 10)
        level.gg_config.armed_poll_ms = 10;

    level.gg_config.wonder_label_reassert_ms = GetDvarInt("gg_wonder_label_reassert_ms");
    if (level.gg_config.wonder_label_reassert_ms < 50)
        level.gg_config.wonder_label_reassert_ms = 50;

    level.gg_config.round_robbin_bonus = GetDvarInt("gg_round_robbin_bonus");
    if (level.gg_config.round_robbin_bonus < 0)
        level.gg_config.round_robbin_bonus = 0;

    level.gg_config.round_robbin_force_transition = (GetDvarInt("gg_round_robbin_force_transition") != 0);

    level.gg_config.shopping_free_secs = GetDvarFloat("gg_shopping_free_secs");
    if (level.gg_config.shopping_free_secs <= 0)
        level.gg_config.shopping_free_secs = 1.0;

    level.gg_config.shopping_free_temp_points = GetDvarInt("gg_shopping_free_temp_points");
    if (level.gg_config.shopping_free_temp_points < 0)
        level.gg_config.shopping_free_temp_points = 0;

    level.gg_config.perkaholic_grant_delay_ms = GetDvarInt("gg_perkaholic_grant_delay_ms");
    if (level.gg_config.perkaholic_grant_delay_ms < 0)
        level.gg_config.perkaholic_grant_delay_ms = 0;
}

gg_init_powerup_tables()
{
    if (!isdefined(level.gg_powerup_alias))
    {
        alias = spawnstruct();
        alias["dead_of_nuclear_winter"] = "nuke";
        alias["kill_joy"] = "insta_kill";
        alias["whos_keeping_score"] = "double_points";
        alias["licensed_contractor"] = "carpenter";
        alias["cache_back"] = "full_ammo";
        alias["immolation"] = "fire_sale";
        alias["on_the_house"] = "free_perk";
        alias["fatal_contraption"] = "minigun";
        alias["extra_credit"] = "bonus_points_player";
        level.gg_powerup_alias = alias;
    }

    if (!isdefined(level.gg_powerup_labels))
    {
        labels = spawnstruct();
        labels["nuke"] = "Nuke";
        labels["insta_kill"] = "Insta-Kill";
        labels["double_points"] = "Double Points";
        labels["carpenter"] = "Carpenter";
        labels["full_ammo"] = "Max Ammo";
        labels["fire_sale"] = "Fire Sale";
        labels["free_perk"] = "Free Perk";
        labels["minigun"] = "Death Machine";
        labels["bonus_points_player"] = "Bonus Points";
        level.gg_powerup_labels = labels;
    }
}

gg_powerup_code_for_gum(gum)
{
    id = undefined;
    if (isdefined(gum))
    {
        if (isstring(gum))
        {
            id = gum;
        }
        else if (isdefined(gum.id))
        {
            id = gum.id;
        }
    }
    return gg_powerup_code_for_id(id);
}

gg_powerup_code_for_id(id)
{
    gg_init_powerup_tables();
    if (!isdefined(id) || id == "")
        return undefined;

    // Try alias table first
    if (isdefined(level.gg_powerup_alias) && isdefined(level.gg_powerup_alias[id]))
        return level.gg_powerup_alias[id];

    // Fallback: known id -> code mapping, and populate alias for future calls
    code = undefined;
    switch (id)
    {
    case "dead_of_nuclear_winter": code = "nuke"; break;
    case "kill_joy": code = "insta_kill"; break;
    case "whos_keeping_score": code = "double_points"; break;
    case "licensed_contractor": code = "carpenter"; break;
    case "cache_back": code = "full_ammo"; break;
    case "immolation": code = "fire_sale"; break;
    case "on_the_house": code = "free_perk"; break;
    case "fatal_contraption": code = "minigun"; break;
    }

    if (isdefined(code) && code != "")
    {
        if (!isdefined(level.gg_powerup_alias))
            level.gg_powerup_alias = spawnstruct();
        level.gg_powerup_alias[id] = code;
        return code;
    }

    return undefined;
}
gg_powerup_label_for_code(code)
{
    gg_init_powerup_tables();
    if (!isdefined(code) || code == "")
        return "Power-Up";
    if (isdefined(level.gg_powerup_labels) && isdefined(level.gg_powerup_labels[code]))
        return level.gg_powerup_labels[code];
    return code;
}

gg_get_drop_forward_units()
{
    if (isdefined(level.gg_config) && isdefined(level.gg_config.drop_forward_units))
        return level.gg_config.drop_forward_units;
    return 70.0;
}

gg_get_reigndrops_forward_units()
{
    if (isdefined(level.gg_config) && isdefined(level.gg_config.reigndrops_forward_units))
        return level.gg_config.reigndrops_forward_units;
    return 145.0;
}

gg_get_reigndrops_radius()
{
    if (isdefined(level.gg_config) && isdefined(level.gg_config.reigndrops_radius))
        return level.gg_config.reigndrops_radius;
    return 70.0;
}

gg_get_reigndrops_spacing_secs()
{
    if (isdefined(level.gg_config) && isdefined(level.gg_config.reigndrops_spacing_ms))
        return level.gg_config.reigndrops_spacing_ms / 1000.0;
    return 0.15;
}

gg_reigndrops_include_firesale()
{
    if (isdefined(level.gg_config) && isdefined(level.gg_config.reigndrops_include_firesale))
        return level.gg_config.reigndrops_include_firesale;
    return true;
}

gg_powerup_hints_enabled()
{
    if (isdefined(level.gg_config) && isdefined(level.gg_config.powerup_hints))
        return level.gg_config.powerup_hints;
    return true;
}

gg_get_armed_grace_secs()
{
    if (isdefined(level.gg_config) && isdefined(level.gg_config.armed_grace_secs))
        return level.gg_config.armed_grace_secs;
    return 3.0;
}

gg_get_armed_grace_ms()
{
    return int(gg_get_armed_grace_secs() * 1000);
}

gg_get_armed_poll_ms()
{
    if (isdefined(level.gg_config) && isdefined(level.gg_config.armed_poll_ms))
        return level.gg_config.armed_poll_ms;
    return 150;
}

gg_get_armed_poll_secs()
{
    ms = gg_get_armed_poll_ms();
    if (ms < 10)
        ms = 10;
    return ms / 1000.0;
}

gg_show_hint_if_enabled(player, text)
{
    if (!gg_powerup_hints_enabled())
        return;
    if (!isdefined(player))
        return;
    if (!isdefined(level.gb_hud) || !isdefined(level.gb_hud.set_hint))
        return;
    if (!isdefined(text))
        text = "";
    [[ level.gb_hud.set_hint ]](player, text);
}

gg_get_wonder_label_reassert_ms()
{
    if (isdefined(level.gg_config) && isdefined(level.gg_config.wonder_label_reassert_ms))
        return level.gg_config.wonder_label_reassert_ms;
    return 250;
}

gg_get_wonder_label_reassert_secs()
{
    return gg_get_wonder_label_reassert_ms() / 1000.0;
}

gg_is_firesale_active()
{
    if (!isdefined(level))
        return false;
    if (!isdefined(level.zombie_vars))
        return false;
    if (!isdefined(level.zombie_vars["zombie_powerup_fire_sale_on"]))
        return false;
    return is_true(level.zombie_vars["zombie_powerup_fire_sale_on"]);
}

gg_test_drop_firesale_enabled()
{
    return (GetDvarInt("gg_test_drop_firesale_on_arm") != 0);
}

gg_spawn_firesale_test_drop(player)
{
    if (!isdefined(player))
        return;

    if (!isdefined(player.origin) || !isdefined(player.angles))
        return;

    if (!gg_test_drop_firesale_enabled())
        return;

    if (gg_spawn_powerup_drop(player, "fire_sale", 0))
    {
        if (gg_debug_enabled())
            iprintln("Gumballs: Test Fire Sale dropped");
    }
}

gg_show_powerup_hint(player, text, raw)
{
    if (!gg_powerup_hints_enabled())
        return;
    if (!isdefined(player))
        return;
    if (!isdefined(level.gb_hud) || !isdefined(level.gb_hud.set_hint))
        return;

    if (!isdefined(text) || text == "")
        text = "Power-Up";

    msg = text;
    if (!isdefined(raw) || !raw)
        msg = "Spawned: " + text;

    [[ level.gb_hud.set_hint ]](player, msg);
}

gg_log_powerup_spawn(gum_id, code)
{
    if (!gg_should_log_dispatch())
        return;

    id_label = gum_id;
    if (!isdefined(id_label) || id_label == "")
        id_label = "<unknown>";

    code_label = code;
    if (!isdefined(code_label) || code_label == "")
        code_label = "<none>";

    iprintln("Gumballs: power-up " + id_label + " -> " + code_label);
}

gg_can_spawn_death_machine()
{
    if (!isdefined(level.gb_helpers) || !isdefined(level.gb_helpers.map_allows))
        return true;
    return [[ level.gb_helpers.map_allows ]]("death_machine");
}

gg_wonderbar_suppress_label(player, duration)
{
    if (!isdefined(player))
        return;

    if (!isdefined(player.gg))
        build_player_state(player);

    if (!isdefined(duration) || duration < 0)
        duration = 0;

    if (!isdefined(player.gg.wonderbar_suppress_until))
        player.gg.wonderbar_suppress_until = 0;

    player.gg.wonderbar_suppress_until = gettime() + int(duration * 1000);

    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_clear_label))
        [[ level.gb_hud.br_clear_label ]](player);

    if (gg_debug_enabled())
        iprintln("Gumballs: Wonderbar label suppressed (" + duration + "s)");
}

gg_spawn_powerup_drop(player, code, fan_offset)
{
    if (!isdefined(player) || !isdefined(code) || code == "")
        return false;

    forward = AnglesToForward(player.angles);
    distance = gg_get_drop_forward_units();
    pos = player.origin + (forward * distance);

    if (isdefined(fan_offset) && fan_offset != 0)
    {
        right = AnglesToRight(player.angles);
        pos += (right * fan_offset);
    }

    level thread maps\_zombiemode_powerups::specific_powerup_drop(code, pos);
    return true;
}

gg_spawn_powerup_drop_at(player, code, pos)
{
    if (!isdefined(player) || !isdefined(code) || code == "")
        return false;

    if (!isdefined(pos))
        return gg_spawn_powerup_drop(player, code, 0);

    level thread maps\_zombiemode_powerups::specific_powerup_drop(code, pos);
    return true;
}

gg_spawn_and_track_powerup(player, gum_id, code, fan_offset, show_hint, pos_override)
{
    success = undefined;
    if (isdefined(pos_override))
        success = gg_spawn_powerup_drop_at(player, code, pos_override);
    else
        success = gg_spawn_powerup_drop(player, code, fan_offset);

    if (!success)
        return false;

    gg_log_powerup_spawn(gum_id, code);

    if (isdefined(show_hint) && show_hint)
        gg_show_powerup_hint(player, gg_powerup_label_for_code(code));

    return true;
}

gg_spawn_powerup_for_gum(player, gum, code)
{
    if (!isdefined(code) || code == "")
        return false;

    gum_id = "<unknown>";
    if (isdefined(gum) && isdefined(gum.id))
        gum_id = gum.id;

    return gg_spawn_and_track_powerup(player, gum_id, code, 0, true);
}

gg_powerup_single_drop(player, gum)
{
    gum_id = "<unknown>";
    if (isdefined(gum) && isdefined(gum.id))
        gum_id = gum.id;

    code = gg_powerup_code_for_gum(gum);
    if (!isdefined(code) || code == "")
    {
        if (gg_should_log_dispatch())
            iprintln("Gumballs: missing power-up alias for " + gum_id);

        gg_mark_activation_skip(player);
        return false;
    }

    if (!gg_spawn_powerup_for_gum(player, gum, code))
    {
        if (gg_should_log_dispatch())
            iprintln("Gumballs: failed to spawn power-up for " + gum_id);

        gg_mark_activation_skip(player);
        return false;
    }

    return true;
}

gg_powerup_fan_offset(index, total)
{
    if (!isdefined(index) || !isdefined(total) || total <= 1)
        return 0;

    spread = 30.0;
    mid = (total - 1) * 0.5;
    return (index - mid) * spread;
}

gg_collect_reign_drop_codes()
{
    codes = [];
    ids = [];

    ids[ids.size] = "whos_keeping_score";     // Double Points
    ids[ids.size] = "kill_joy";               // Insta-Kill
    if (gg_reigndrops_include_firesale())
        ids[ids.size] = "immolation";        // Fire Sale (optional)
    ids[ids.size] = "dead_of_nuclear_winter"; // Nuke
    ids[ids.size] = "licensed_contractor";    // Carpenter
    ids[ids.size] = "cache_back";             // Max Ammo
    ids[ids.size] = "on_the_house";           // Free Perk
    ids[ids.size] = "extra_credit";           // Bonus Points
    if (gg_can_spawn_death_machine())
        ids[ids.size] = "fatal_contraption"; // Death Machine (map-gated)

    for (i = 0; i < ids.size; i++)
    {
        alias_id = ids[i];
        if (!isdefined(alias_id) || alias_id == "")
            continue;

        code = gg_powerup_code_for_id(alias_id);
        if (!isdefined(code) || code == "")
        {
            if (gg_should_log_dispatch())
                iprintln("Gumballs: missing Reign Drops alias for " + alias_id);
            continue;
        }

        if (!gg_array_contains(codes, code))
            codes[codes.size] = code;
    }

    return codes;
}

gg_spawn_reign_drop_sequence(player, gum, codes)
{
    if (!isdefined(player) || !isdefined(codes) || codes.size <= 0)
        return false;

    if (!isdefined(player.gg))
        build_player_state(player);

    gum_id = "<unknown>";
    if (isdefined(gum) && isdefined(gum.id))
        gum_id = gum.id;

    spacing = gg_get_reigndrops_spacing_secs();
    if (spacing < 0)
        spacing = 0;

    if (!isdefined(player.gg.reign_drops_token))
        player.gg.reign_drops_token = 0;
    player.gg.reign_drops_token += 1;
    token = player.gg.reign_drops_token;

    player thread gg_reign_drop_sequence_thread(gum_id, codes, spacing, token);
    return true;
}

gg_reign_drop_sequence_thread(gum_id, codes, spacing, expected_token)
{
    self endon("disconnect");
    self endon("gg_gum_cleared");

    if (!isdefined(codes) || codes.size <= 0)
        return;

    if (!gg_reign_drops_token_active(expected_token))
        return;

    base_angles = (0, self.angles[1], 0);
    forward = AnglesToForward(base_angles);
    if (!isdefined(forward))
        forward = (1, 0, 0);
    center_offset = gg_get_reigndrops_forward_units();
    if (!isdefined(center_offset) || center_offset <= 0)
        center_offset = gg_get_drop_forward_units();
    center = self.origin + (forward * center_offset);

    radius = gg_get_reigndrops_radius();
    if (!isdefined(radius) || radius <= 0)
        radius = 70.0;

    wait_secs = spacing;
    if (!isdefined(wait_secs))
        wait_secs = gg_get_reigndrops_spacing_secs();
    if (wait_secs < 0)
        wait_secs = 0;

    total = codes.size;
    if (total <= 0)
        return;

    step = 360.0 / total;
    spawned_any = false;

    for (i = 0; i < total; i++)
    {
        if (!gg_reign_drops_token_active(expected_token))
            break;

        code = codes[i];
        if (!isdefined(code) || code == "")
            continue;

        drop_code = code;
        if (drop_code == "instakill")
            drop_code = "insta_kill";
        else if (drop_code == "maxammo")
            drop_code = "full_ammo";
        else if (drop_code == "doublepoints")
            drop_code = "double_points";
        else if (drop_code == "firesale")
            drop_code = "fire_sale";

        yaw = base_angles[1] + (i * step);
        arc_angles = (0, yaw, 0);
        dir = AnglesToForward(arc_angles);
        if (!isdefined(dir))
            dir = forward;

        drop_pos = center + (dir * radius);

        level thread maps\_zombiemode_powerups::specific_powerup_drop(drop_code, drop_pos);
        gg_log_powerup_spawn(gum_id, drop_code);

        if (gg_debug_enabled())
            iprintln("Gumballs: Reign Drops [" + (i + 1) + "/" + total + "] " + drop_code + " @ " + gg_vector_to_string(drop_pos));

        spawned_any = true;

        if (wait_secs > 0 && i < total - 1)
        {
            wait(wait_secs);
        }
    }

    if (spawned_any)
    {
        gg_reign_drops_consume_activation(gum_id, expected_token);
    }
}

gg_reign_drops_consume_activation(gum_id, expected_token)
{
    if (!isdefined(self.gg))
        build_player_state(self);

    if (!isdefined(self.gg.uses_remaining))
        self.gg.uses_remaining = 0;

    if (self.gg.uses_remaining > 0)
    {
        self.gg.uses_remaining -= 1;
        self.gg.used_this_round = true;
        if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_consume_use))
            [[ level.gb_hud.br_consume_use ]](self);
    }

    if (gg_consume_logs_enabled())
        iprintln("Gumballs: Reign Drops consumed -> remaining=" + self.gg.uses_remaining);
    else if (gg_debug_enabled())
        iprintln("Gumballs: Reign Drops remaining=" + self.gg.uses_remaining);

    gg_set_effect_state(self, undefined, false);
    gg_on_gum_used();

    if (self.gg.uses_remaining <= 0)
    {
        gg_end_current_gum(self, "reign_drops_complete");
    }
}

gg_mark_activation_skip(player)
{
    if (!isdefined(player))
        return;

    if (!isdefined(player.gg))
        build_player_state(player);

    player.gg.skip_activation_consume_once = true;
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
        value = "";
    if (value == "")
    {
        // Fallback aliases for convenience
        alt = GetDvar("gg_force");
        if (isdefined(alt) && alt != "")
            value = alt;
        else
        {
            alt2 = GetDvar("force_gum");
            if (isdefined(alt2) && alt2 != "")
                value = alt2;
        }
    }
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

        selection_active = gg_selection_is_active(player);
        consumed_last_round = false;
        if (isdefined(player.gg) && isdefined(player.gg.used_this_round) && player.gg.used_this_round)
            consumed_last_round = true;

        if (isdefined(player.gg) && isdefined(player.gg.consumption_type) && player.gg.consumption_type == gg_cons_uses())
        {
            if (consumed_last_round)
            {
                gg_end_current_gum(player, "round_change_after_use");
            }
            else if (selection_active)
            {
                gg_selection_close(player, "round_change_unused", true, true);
                if (gg_debug_select_enabled())
                    gg_log_select("Gumballs: unused gum discarded on round change");
            }
        }
        else if (selection_active)
        {
            gg_selection_close(player, "round_change", true, false);
        }

        // ROUNDS model: decrement exactly once per new round while active
        gg_round_tick(player, round_number);

        if (isdefined(player.gg))
            player.gg.used_this_round = false;

        // Assign a new gum only if none is currently selected
        needs_selection = !gg_selection_is_active(player);
        if (needs_selection)
        {
            if (isdefined(player.gg) && isdefined(player.gg.last_selected_round) && player.gg.last_selected_round == round_number)
                continue;
            player thread gg_assign_gum_for_round_thread(round_number);
        }
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

    allowed_on_map = gg_is_gum_allowed_on_map(gum);
    if (!allowed_on_map)
    {
        if (isdefined(gum.id) && gum.id == "perkaholic")
        {
            if (isdefined(level.gb_helpers) && isdefined(level.gb_helpers.player_has_all_map_perks))
            {
                if ([[ level.gb_helpers.player_has_all_map_perks ]](player))
                {
                    gg_log_select("Gumballs: forced gum '" + forced_id + "' blocked (perks)");
                    return undefined;
                }
            }
        }

        if (gg_debug_enabled())
            iprintln("Gumballs: forced gum '" + forced_id + "' bypassing map gating");
    }
    else if (!gg_is_gum_selectable_for_player(player, gum))
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

    if (!gg_selection_is_active(player))
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

    // Model-aware activation guard
    if (!gg_model_can_activate(player, gum))
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

    // After successful dispatch, apply consumption model hooks
    gg_on_activation(player, gum);
    gg_set_effect_state(player, gum, true);
    gg_handle_post_activation(player, gum);

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
    gg_register_dispatcher_entry("gg_fx_whos_keeping_score", ::gg_fx_whos_keeping_score);
    gg_register_dispatcher_entry("gg_fx_licensed_contractor", ::gg_fx_licensed_contractor);
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
    if (func_name == "gg_fx_whos_keeping_score")
        return ::gg_fx_whos_keeping_score;
    if (func_name == "gg_fx_licensed_contractor")
        return ::gg_fx_licensed_contractor;
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

// Armed gum shared helpers
gg_get_primary_weapons(player)
{
    if (!isdefined(player))
        return [];

    weapons = player GetWeaponsListPrimaries();
    if (!isdefined(weapons))
        weapons = [];
    return weapons;
}

gg_clone_array(arr)
{
    clone = [];
    if (!isdefined(arr))
        return clone;
    for (i = 0; i < arr.size; i++)
    {
        clone[i] = arr[i];
    }
    return clone;
}

gg_array_contains(arr, value)
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

gg_vector_to_string(vec)
{
    if (!isdefined(vec))
        return "(?, ?, ?)";

    x = 0;
    y = 0;
    z = 0;
    if (isdefined(vec[0]))
        x = vec[0];
    if (isdefined(vec[1]))
        y = vec[1];
    if (isdefined(vec[2]))
        z = vec[2];

    return "(" + x + ", " + y + ", " + z + ")";
}

gg_detect_new_weapon(prev, curr)
{
    if (!isdefined(curr))
        return undefined;

    for (i = 0; i < curr.size; i++)
    {
        weapon = curr[i];
        if (!isdefined(weapon) || weapon == "" || weapon == "none")
            continue;
        if (!gg_array_contains(prev, weapon))
            return weapon;
    }

    return undefined;
}

gg_weapon_has_upgrade(weapon)
{
    if (!isdefined(weapon) || weapon == "" || !isdefined(level.zombie_weapons))
        return false;

    if (!isdefined(level.zombie_weapons[weapon]))
        return false;

    if (!isdefined(level.zombie_weapons[weapon].upgrade_name))
        return false;

    upgrade = level.zombie_weapons[weapon].upgrade_name;
    return (isdefined(upgrade) && upgrade != "");
}

gg_weapon_is_box_weapon(weapon)
{
    if (!isdefined(weapon) || weapon == "" || !isdefined(level.zombie_weapons))
        return false;

    if (!isdefined(level.zombie_weapons[weapon]))
        return false;

    return maps\_zombiemode_weapons::get_is_in_box(weapon);
}

gg_weapon_is_wall_buy(weapon)
{
    if (!isdefined(weapon) || weapon == "" || !isdefined(level.zombie_weapons))
        return false;

    if (!isdefined(level.zombie_weapons[weapon]))
        return false;

    info = level.zombie_weapons[weapon];

    is_box_weapon = false;
    if (isdefined(info.is_in_box))
        is_box_weapon = info.is_in_box;
    else if (isdefined(maps\_zombiemode_weapons::get_is_in_box))
        is_box_weapon = maps\_zombiemode_weapons::get_is_in_box(weapon);

    if (is_box_weapon)
        return false;

    if (isdefined(info.cost) && info.cost > 0)
        return true;

    if (isdefined(info.ammo_cost) && info.ammo_cost > 0)
        return true;

    if (isdefined(maps\_zombiemode_weapons::get_weapon_toggle))
    {
        toggle = maps\_zombiemode_weapons::get_weapon_toggle(weapon);
        if (isdefined(toggle))
            return true;
    }

    if (isdefined(info.hint) && info.hint != "")
        return true;

    return false;
}

gg_weapon_is_spawn_pistol(weapon)
{
    return (weapon == "m1911_zm");
}

gg_apply_upgrade_for_weapon(player, weapon)
{
    if (!isdefined(level.gb_helpers) || !isdefined(level.gb_helpers.upgrade_weapon))
        return false;
    return [[ level.gb_helpers.upgrade_weapon ]](player, weapon);
}

gg_wall_power_token_active(expected_token)
{
    if (!isdefined(self.gg) || !isdefined(self.gg.wall_power_token))
        return false;
    return (self.gg.wall_power_token == expected_token);
}

gg_crate_power_token_active(expected_token)
{
    if (!isdefined(self.gg) || !isdefined(self.gg.crate_power_token))
        return false;
    return (self.gg.crate_power_token == expected_token);
}

gg_wonderbar_token_active(expected_token)
{
    if (!isdefined(self.gg) || !isdefined(self.gg.wonderbar_token))
        return false;
    return (self.gg.wonderbar_token == expected_token);
}

gg_reign_drops_token_active(expected_token)
{
    if (!isdefined(self.gg) || !isdefined(self.gg.reign_drops_token))
        return false;
    return (self.gg.reign_drops_token == expected_token);
}

gg_wonderbar_label_token_active(expected_token)
{
    if (!isdefined(self.gg) || !isdefined(self.gg.wonderbar_label_token))
        return false;
    return (self.gg.wonderbar_label_token == expected_token);
}

// Build 5: Consumption seeding and helpers
gg_seed_consumption_state(player, gum)
{
    if (!isdefined(player) || !isdefined(gum))
        return;

    if (!isdefined(player.gg))
    {
        build_player_state(player);
    }

    type = gg_get_consumption_type(gum);
    player.gg.consumption_type = type;
    player.gg.is_active = false;
    player.gg.timer_endtime = 0;

    if (type == gg_cons_uses())
    {
        total = gg_get_base_uses(gum);
        player.gg.uses_remaining = total;
        player.gg.rounds_remaining = 0;
        if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_set_mode))
            [[ level.gb_hud.br_set_mode ]](player, "uses");
        if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_set_total_uses))
            [[ level.gb_hud.br_set_total_uses ]](player, total);
    }
    else if (type == gg_cons_rounds())
    {
        total = gg_get_base_rounds(gum);
        player.gg.rounds_remaining = total;
        player.gg.uses_remaining = 0;
        if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_set_mode))
            [[ level.gb_hud.br_set_mode ]](player, "rounds");
        if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_set_total_rounds))
            [[ level.gb_hud.br_set_total_rounds ]](player, total);
    }
    else
    {
        player.gg.uses_remaining = 0;
        player.gg.rounds_remaining = 0;
        player.gg.timer_endtime = 0;
        if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_set_mode))
            [[ level.gb_hud.br_set_mode ]](player, "timer");
    }
}

gg_cons_timed()
{
    if (isdefined(level.gb_helpers) && isdefined(level.gb_helpers.CONS_TIMED))
        return [[ level.gb_helpers.CONS_TIMED ]]();
    return 1;
}

gg_cons_rounds()
{
    if (isdefined(level.gb_helpers) && isdefined(level.gb_helpers.CONS_ROUNDS))
        return [[ level.gb_helpers.CONS_ROUNDS ]]();
    return 2;
}

gg_cons_uses()
{
    if (isdefined(level.gb_helpers) && isdefined(level.gb_helpers.CONS_USES))
        return [[ level.gb_helpers.CONS_USES ]]();
    return 3;
}

gg_get_consumption_type(gum)
{
    if (isdefined(gum) && isdefined(gum.consumption))
        return gum.consumption;
    return gg_cons_uses();
}

gg_get_base_uses(gum)
{
    if (isdefined(gum) && isdefined(gum.base_uses))
        return int(gum.base_uses);
    if (isdefined(level.gg_config) && isdefined(level.gg_config.default_uses))
        return level.gg_config.default_uses;
    return 3;
}

gg_get_base_rounds(gum)
{
    if (isdefined(gum) && isdefined(gum.base_rounds))
        return int(gum.base_rounds);
    if (isdefined(level.gg_config) && isdefined(level.gg_config.default_rounds))
        return level.gg_config.default_rounds;
    return 3;
}

gg_get_base_timer_secs(gum)
{
    if (isdefined(gum) && isdefined(gum.base_duration_secs))
        return float(gum.base_duration_secs);
    if (isdefined(level.gg_config) && isdefined(level.gg_config.default_timer_secs))
        return level.gg_config.default_timer_secs;
    return 60.0;
}

gg_get_timer_tick_ms()
{
    if (isdefined(level.gg_config) && isdefined(level.gg_config.timer_tick_ms))
        return level.gg_config.timer_tick_ms;
    return 100;
}

gg_consume_logs_enabled()
{
    if (isdefined(level.gg_config) && isdefined(level.gg_config.consume_logs))
        return level.gg_config.consume_logs;
    return true;
}

// Determine if activation is allowed for the current model/state
gg_model_can_activate(player, gum)
{
    if (!isdefined(player) || !isdefined(player.gg))
        return false;

    type = gg_get_consumption_type(gum);
    if (type == gg_cons_uses())
    {
        if (isdefined(player.gg.uses_remaining) && player.gg.uses_remaining <= 0)
        {
            if (gg_debug_enabled())
                iprintln("Gumballs: cannot activate, no uses left");
            return false;
        }
    }
    else if (type == gg_cons_rounds())
    {
        if (isdefined(player.gg.rounds_remaining) && player.gg.rounds_remaining <= 0)
        {
            if (gg_debug_enabled())
                iprintln("Gumballs: cannot activate, no rounds left");
            return false;
        }
    }
    else // TIMED
    {
        if (isdefined(player.gg.is_active) && player.gg.is_active && isdefined(player.gg.timer_endtime) && player.gg.timer_endtime > gettime())
        {
            if (gg_debug_enabled())
                iprintln("Gumballs: timer already active; activation ignored");
            return false;
        }
    }
    return true;
}

// Apply consumption effects for this activation
gg_on_activation(player, gum)
{
    if (!isdefined(player) || !isdefined(player.gg))
        return;

    if (isdefined(player.gg.skip_activation_consume_once) && player.gg.skip_activation_consume_once)
    {
        player.gg.skip_activation_consume_once = false;
        if (gg_consume_logs_enabled())
            iprintln("Gumballs: activation consumption skipped");
        return;
    }

    type = gg_get_consumption_type(gum);
    if (type == gg_cons_uses())
    {
        if (!isdefined(player.gg.uses_remaining))
            player.gg.uses_remaining = gg_get_base_uses(gum);
        if (player.gg.uses_remaining > 0)
        {
            player.gg.uses_remaining -= 1;
            player.gg.used_this_round = true;
            if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_consume_use))
                [[ level.gb_hud.br_consume_use ]](player);
            if (gg_consume_logs_enabled())
                iprintln("Gumballs: use consumed -> remaining=" + player.gg.uses_remaining);
        }
        if (player.gg.uses_remaining <= 0)
        {
            gg_end_current_gum(player, "uses_empty");
        }
    }
    else if (type == gg_cons_rounds())
    {
        if (!isdefined(player.gg.is_active) || !player.gg.is_active)
        {
            player.gg.is_active = true;
            player.gg.active_token += 1;
            if (gg_consume_logs_enabled())
                iprintln("Gumballs: rounds model activated");
        }
    }
    else // TIMED
    {
        dur = gg_get_base_timer_secs(gum);
        player.gg.timer_endtime = gettime() + int(dur * 1000);
        player.gg.is_active = true;
        player.gg.active_token += 1;

        token = player.gg.active_token;

        if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_start_timer))
            [[ level.gb_hud.br_start_timer ]](player, dur);

        player thread gg_timer_monitor_thread(token);
        if (gg_consume_logs_enabled())
            iprintln("Gumballs: timer started for " + dur + "s");
    }
}

gg_handle_post_activation(player, gum)
{
    if (!isdefined(player) || !isdefined(player.gg))
        return;

    type = gg_get_consumption_type(gum);

    if (gg_is_auto_activation(gum))
    {
        gg_selection_close(player, "auto_activation", false, false);
        return;
    }

    if (type == gg_cons_timed())
    {
        gg_selection_close(player, "timed_activation", true, false);
    }
    else if (type == gg_cons_rounds())
    {
        gg_selection_close(player, "rounds_activation", true, false);
    }
}

gg_timer_monitor_thread(expected_token)
{
    self endon("disconnect");
    self endon("gg_gum_cleared");

    if (!isdefined(self.gg) || !isdefined(self.gg.timer_endtime))
        return;

    while (isdefined(self.gg) && isdefined(self.gg.timer_endtime))
    {
        if (!isdefined(self.gg.active_token) || self.gg.active_token != expected_token)
            return;

        now = gettime();
        if (now >= self.gg.timer_endtime)
            break;

        wait(gg_get_timer_tick_ms() / 1000.0);
    }

    if (isdefined(self.gg) && isdefined(self.gg.active_token) && self.gg.active_token == expected_token)
    {
        if (gg_consume_logs_enabled())
            iprintln("Gumballs: timer expired");
        gg_end_current_gum(self, "timer_expired");
    }
}

// Called on round start to decrement rounds model
gg_round_tick(player, round_number)
{
    if (!isdefined(player) || !isdefined(player.gg))
        return;

    if (isdefined(player.gg.last_round_ticked) && player.gg.last_round_ticked == round_number)
        return;

    player.gg.last_round_ticked = round_number;

    if (!isdefined(player.gg.consumption_type) || player.gg.consumption_type != gg_cons_rounds())
        return;
    if (!isdefined(player.gg.is_active) || !player.gg.is_active)
        return;
    if (!isdefined(player.gg.rounds_remaining) || player.gg.rounds_remaining <= 0)
        return;

    player.gg.rounds_remaining -= 1;
    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_consume_round))
        [[ level.gb_hud.br_consume_round ]](player);
    if (gg_consume_logs_enabled())
        iprintln("Gumballs: round consumed -> remaining=" + player.gg.rounds_remaining);

    if (player.gg.rounds_remaining <= 0)
    {
        gg_end_current_gum(player, "rounds_empty");
    }
}

// Centralized gum termination
gg_end_current_gum(player, reason)
{
    if (!isdefined(player) || !isdefined(player.gg))
        return;

    if (gg_consume_logs_enabled() && isdefined(reason))
        iprintln("Gumballs: ending gum (" + reason + ")");

    gg_selection_close(player, reason, true, true);
    gg_set_effect_state(player, undefined, false);

    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_stop_timer))
        [[ level.gb_hud.br_stop_timer ]](player);

    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_clear_label))
        [[ level.gb_hud.br_clear_label ]](player);

    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.hide_br))
        [[ level.gb_hud.hide_br ]](player);

    player.gg.is_active = false;
    player.gg.uses_remaining = 0;
    player.gg.rounds_remaining = 0;
    player.gg.timer_endtime = 0;
    player.gg.used_this_round = false;
    player.gg.active_token += 1;

    if (isdefined(player.gg) && isdefined(player.gg.armed_flags))
    {
        player.gg.armed_flags.wall = false;
        player.gg.armed_flags.crate = false;
        player.gg.armed_flags.crate_power_active = false;
        player.gg.armed_flags.wonder = false;
        player.gg.armed_flags.wonderbar_active = false;
    }

    if (isdefined(player.gg))
    {
        player.gg.crate_power_armed_time = 0;
        player.gg.armed_since = 0;
        player.gg.wonderbar_armed_time = 0;
        player.gg.wonderbar_choice = undefined;
        player.gg.wonderbar_label_text = "";
        player.gg.wonderbar_suppress_until = 0;
    }

    player notify("gg_wall_power_cancel");
    player notify("gg_crate_power_cancel");
    player notify("gg_wonderbar_cancel");

    player notify("gg_gum_cleared");
    player notify("gg_wonderbar_end");

    player.gg.selected_id = undefined;
    player.gg.selection_active = false;
}

// Power-Ups

gg_fx_cache_back(player, gum)
{
    gg_powerup_single_drop(player, gum);
}

gg_fx_kill_joy(player, gum)
{
    gg_powerup_single_drop(player, gum);
}

gg_fx_dead_of_nuclear_winter(player, gum)
{
    gg_powerup_single_drop(player, gum);
}

gg_fx_whos_keeping_score(player, gum)
{
    gg_powerup_single_drop(player, gum);
}

gg_fx_licensed_contractor(player, gum)
{
    gg_powerup_single_drop(player, gum);
}

gg_fx_immolation(player, gum)
{
    if (gg_powerup_single_drop(player, gum))
    {
        gg_wonderbar_suppress_label(player, 35);
    }
}

gg_fx_fatal_contraption(player, gum)
{
    if (!gg_can_spawn_death_machine())
    {
        if (gg_debug_enabled())
            iprintln("Gumballs: Fatal Contraption blocked (map)");
        gg_mark_activation_skip(player);
        return;
    }

    gg_powerup_single_drop(player, gum);
}

gg_fx_reign_drops(player, gum)
{
    codes = gg_collect_reign_drop_codes();

    if (!isdefined(codes) || codes.size <= 0)
    {
        if (gg_should_log_dispatch())
            iprintln("Gumballs: Reign Drops has no valid power-ups");
        gg_mark_activation_skip(player);
        return;
    }

    gg_mark_activation_skip(player);

    if (!gg_spawn_reign_drop_sequence(player, gum, codes))
    {
        return;
    }

    gg_show_powerup_hint(player, "Reign Drops");
}

// Weapons & Perks

gg_perkaholic_get_perks()
{
    if (isdefined(level.gb_helpers) && isdefined(level.gb_helpers.get_map_perk_list))
        return [[ level.gb_helpers.get_map_perk_list ]]();
    return [];
}

gg_perkaholic_missing_perks(player, perks)
{
    missing = [];
    if (!isdefined(perks))
        perks = [];

    for (i = 0; i < perks.size; i++)
    {
        perk = perks[i];
        if (!isdefined(perk) || perk == "")
            continue;
        if (!isdefined(player) || !(player HasPerk(perk)))
            missing[missing.size] = perk;
    }

    return missing;
}

gg_perkaholic_should_trigger_vo()
{
    if (!isdefined(level.gb_helpers) || !isdefined(level.gb_helpers.is_cosmodrome))
        return false;
    return [[ level.gb_helpers.is_cosmodrome ]]();
}

gg_fx_perkaholic(player, gum)
{
    if (!isdefined(player))
        return;

    perks = gg_perkaholic_get_perks();
    missing = gg_perkaholic_missing_perks(player, perks);

    if (!isdefined(missing) || missing.size <= 0)
    {
        gg_mark_activation_skip(player);
        if (gg_debug_enabled())
            iprintln("Gumballs: Perkaholic skipped (no missing perks)");
        gg_show_hint_if_enabled(player, "Perkaholic: all perks acquired");
        return;
    }

    delay = gg_get_perkaholic_grant_delay_secs();
    trigger_vo = gg_perkaholic_should_trigger_vo() && isdefined(level.perk_bought_func);

    for (i = 0; i < missing.size; i++)
    {
        perk = missing[i];
        if (!isdefined(perk) || perk == "")
            continue;

        if (trigger_vo)
            player [[ level.perk_bought_func ]](perk);

        player maps\_zombiemode_perks::give_perk(perk);

        if (gg_debug_enabled())
            iprintln("Gumballs: Perkaholic granted " + perk);

        if (delay > 0 && i < missing.size - 1)
            wait(delay);
    }

    gg_show_hint_if_enabled(player, "Applied: Perkaholic");
}

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
        iprintln("Gumballs: Wall Power armed");
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

    msg = "Gumballs: Wall Power " + reason;
    if (isdefined(weapon) && weapon != "")
        msg = msg + " (" + weapon + ")";
    iprintln(msg);
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
        iprintln("Gumballs: Wall Power upgraded " + weapon);

    wait(0.25);
    if (isdefined(player.gg))
        player.gg.uses_remaining = 0;
    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_consume_use))
        [[ level.gb_hud.br_consume_use ]](player);
    gg_end_current_gum(player, "wall_power_applied");
}

gg_fx_on_the_house(player, gum)
{
    gg_powerup_single_drop(player, gum);
}

gg_fx_hidden_power(player, gum)
{
    gg_effect_stub_common(player, gum, "Weapons/Perks");
}

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
        iprintln("Gumballs: Crate Power armed");
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
        iprintln("Gumballs: Crate Power upgraded " + weapon);

    wait(0.25);
    if (isdefined(player.gg))
        player.gg.uses_remaining = 0;
    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_consume_use))
        [[ level.gb_hud.br_consume_use ]](player);
    gg_end_current_gum(player, "crate_power_applied");
}

gg_wonderbar_arm(player, gum)
{
    if (!isdefined(player))
        return;

    if (!isdefined(player.gg))
        build_player_state(player);

    player notify("gg_wonderbar_cancel");

    if (!isdefined(player.gg.wonderbar_token))
        player.gg.wonderbar_token = 0;
    if (!isdefined(player.gg.wonderbar_label_token))
        player.gg.wonderbar_label_token = 0;

    player.gg.wonderbar_token += 1;
    token = player.gg.wonderbar_token;
    player.gg.wonderbar_label_token += 1;
    label_token = player.gg.wonderbar_label_token;

    choice = gg_wonderbar_select_choice(player);
    player.gg.wonderbar_choice = choice;

    label_text = gg_wonderbar_choice_label(choice);
    player.gg.wonderbar_label_text = label_text;

    armed_time = gettime();
    player.gg.armed_since = armed_time;
    player.gg.wonderbar_armed_time = armed_time;
    player.gg.wonderbar_suppress_until = 0;

    player.gg.armed_flags.wonder = true;
    player.gg.armed_flags.wonderbar_active = true;

    if (isdefined(level.gb_hud))
    {
        if (isdefined(level.gb_hud.show_br))
            [[ level.gb_hud.show_br ]](player, gum);
        if (isdefined(level.gb_hud.br_set_mode))
            [[ level.gb_hud.br_set_mode ]](player, "uses");
        if (isdefined(level.gb_hud.br_set_total_uses))
            [[ level.gb_hud.br_set_total_uses ]](player, 1);
        if (isdefined(level.gb_hud.br_set_label))
            [[ level.gb_hud.br_set_label ]](player, label_text);
    }

    gg_show_hint_if_enabled(player, "Armed: Wonderbar");
    gg_spawn_firesale_test_drop(player);

    snapshot = gg_clone_array(gg_get_primary_weapons(player));
    player thread gg_wonderbar_monitor_thread(gum, token, armed_time, snapshot);
    player thread gg_wonderbar_label_thread(label_token);

    if (gg_debug_enabled())
    {
        msg = "Gumballs: Wonderbar armed";
        if (isdefined(choice) && choice != "")
            msg = msg + " (" + choice + ")";
        iprintln(msg);
    }
}

gg_wonderbar_select_choice(player)
{
    if (!isdefined(level.gb_helpers) || !isdefined(level.gb_helpers.get_wonder_pool))
        return undefined;

    mapname = undefined;
    if (isdefined(level.gb_helpers.get_current_mapname))
        mapname = [[ level.gb_helpers.get_current_mapname ]]();
    else
        mapname = GetDvar("mapname");

    pool = [[ level.gb_helpers.get_wonder_pool ]](mapname);
    if (!isdefined(pool) || pool.size <= 0)
    {
        if (gg_debug_enabled())
            iprintln("Gumballs: Wonderbar has no wonder weapons available");
        return undefined;
    }

    idx = RandomInt(pool.size);
    return pool[idx];
}

gg_wonderbar_choice_label(choice)
{
    if (!isdefined(choice) || choice == "")
        return "";

    if (isdefined(level.gb_helpers) && isdefined(level.gb_helpers.get_weapon_display_name))
        return [[ level.gb_helpers.get_weapon_display_name ]](choice);

    return choice;
}

gg_wonderbar_monitor_thread(gum, expected_token, armed_time, snapshot)
{
    self endon("disconnect");
    self endon("gg_gum_cleared");
    self endon("gg_wonderbar_cancel");

    known = gg_clone_array(snapshot);
    poll_secs = gg_get_armed_poll_secs();
    if (poll_secs <= 0)
        poll_secs = 0.1;

    while (true)
    {
        wait(poll_secs);

        if (!gg_wonderbar_token_active(expected_token))
            return;

        current = gg_clone_array(gg_get_primary_weapons(self));
        new_weapon = gg_detect_new_weapon(known, current);
        known = current;

        if (!isdefined(new_weapon))
            continue;

        if (!gg_wonderbar_should_replace(self, new_weapon, armed_time))
            continue;

        if (!gg_wonderbar_apply_choice(self, new_weapon))
            continue;

        gg_wonderbar_on_success(self, gum, new_weapon);
        return;
    }
}

gg_wonderbar_should_replace(player, weapon, armed_time)
{
    if (!isdefined(weapon) || weapon == "" || weapon == "none")
        return false;

    grace_ms = gg_get_armed_grace_ms();
    if (isdefined(armed_time) && armed_time > 0 && (gettime() - armed_time) < grace_ms)
        return false;

    if (!gg_weapon_is_box_weapon(weapon))
        return false;

    if (gg_weapon_is_wall_buy(weapon))
        return false;

    if (gg_weapon_is_spawn_pistol(weapon))
        return false;

    return true;
}

gg_wonderbar_apply_choice(player, acquired_weapon)
{
    if (!isdefined(player) || !isdefined(player.gg))
        return false;

    wonder = player.gg.wonderbar_choice;
    if (!isdefined(wonder) || wonder == "")
    {
        if (gg_debug_enabled())
            iprintln("Gumballs: Wonderbar has no cached choice");
        return false;
    }

    if (!isdefined(level.zombie_weapons) || !isdefined(level.zombie_weapons[wonder]))
    {
        if (gg_debug_enabled())
            iprintln("Gumballs: Wonderbar choice invalid (" + wonder + ")");
        return false;
    }

    wait(0.25);

    if (isdefined(acquired_weapon) && acquired_weapon != "" && acquired_weapon != "none" && acquired_weapon != wonder)
    {
        if (player HasWeapon(acquired_weapon))
            player TakeWeapon(acquired_weapon);
    }

    player maps\_zombiemode_weapons::weapon_give(wonder);

    if (!player HasWeapon(wonder))
        return false;

    player GiveStartAmmo(wonder);
    player SwitchToWeapon(wonder);

    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_set_label))
    {
        label_text = gg_wonderbar_choice_label(wonder);
        [[ level.gb_hud.br_set_label ]](player, label_text);
        player.gg.wonderbar_label_text = label_text;
    }

    return true;
}

gg_wonderbar_on_success(player, gum, weapon)
{
    if (!isdefined(player))
        return;

    gg_show_hint_if_enabled(player, "Applied: Wonderbar");

    player.gg.armed_flags.wonder = false;
    player.gg.armed_flags.wonderbar_active = false;

    if (gg_debug_enabled())
        iprintln("Gumballs: Wonderbar granted " + player.gg.wonderbar_choice);

    if (isdefined(player.gg))
        player.gg.uses_remaining = 0;
    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_consume_use))
        [[ level.gb_hud.br_consume_use ]](player);

    wait(0.25);
    if (isdefined(player.gg))
    {
        player.gg.wonderbar_choice = undefined;
        player.gg.wonderbar_label_text = "";
    }
    if (isdefined(level.gb_hud))
    {
        if (isdefined(level.gb_hud.br_clear_label))
            [[ level.gb_hud.br_clear_label ]](player);
    }
    gg_end_current_gum(player, "wonderbar_applied");
}

gg_wonderbar_label_thread(expected_token)
{
    self endon("disconnect");
    self endon("gg_gum_cleared");
    self endon("gg_wonderbar_cancel");

    while (true)
    {
        if (!gg_wonderbar_label_token_active(expected_token))
            return;

        suppress = false;
        if (isdefined(self.gg) && isdefined(self.gg.wonderbar_suppress_until) && self.gg.wonderbar_suppress_until > gettime())
            suppress = true;

        if (suppress)
        {
            if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_clear_label))
                [[ level.gb_hud.br_clear_label ]](self);
        }
        else
        {
            label_text = "";
            if (isdefined(self.gg) && isdefined(self.gg.wonderbar_label_text))
                label_text = self.gg.wonderbar_label_text;
            if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_set_label))
                [[ level.gb_hud.br_set_label ]](self, label_text);
        }

        wait(gg_get_wonder_label_reassert_secs());
    }
}

gg_fx_wonderbar(player, gum)
{
    if (!isdefined(player))
        return;

    gg_mark_activation_skip(player);
    gg_wonderbar_arm(player, gum);
}

// Economy & Round

gg_get_round_robbin_bonus()
{
    if (isdefined(level.gg_config) && isdefined(level.gg_config.round_robbin_bonus))
        return level.gg_config.round_robbin_bonus;
    return 1600;
}

gg_round_robbin_force_transition_enabled()
{
    if (isdefined(level.gg_config) && isdefined(level.gg_config.round_robbin_force_transition))
        return level.gg_config.round_robbin_force_transition;
    return true;
}

gg_get_shopping_free_secs()
{
    if (isdefined(level.gg_config) && isdefined(level.gg_config.shopping_free_secs))
        return level.gg_config.shopping_free_secs;
    return 60.0;
}

gg_get_shopping_free_temp_points()
{
    if (isdefined(level.gg_config) && isdefined(level.gg_config.shopping_free_temp_points))
        return level.gg_config.shopping_free_temp_points;
    return 50000;
}

gg_get_perkaholic_grant_delay_secs()
{
    if (isdefined(level.gg_config) && isdefined(level.gg_config.perkaholic_grant_delay_ms))
        return level.gg_config.perkaholic_grant_delay_ms / 1000.0;
    return 0.25;
}

gg_round_robbin_award_points()
{
    bonus = gg_get_round_robbin_bonus();
    if (bonus <= 0)
        return 0;

    bonus = int(bonus);

    players = get_players();
    if (!isdefined(players))
        players = [];

    awarded = 0;
    for (i = 0; i < players.size; i++)
    {
        target = players[i];
        if (!isdefined(target))
            continue;
        target maps\_zombiemode_score::add_to_player_score(bonus);
        awarded += 1;
    }

    if (gg_debug_enabled())
        iprintln("Gumballs: Round Robbin +" + bonus + " -> players=" + awarded);

    return awarded;
}

gg_round_robbin_kill_remaining()
{
    zombies = getaispeciesarray("axis");
    if (!isdefined(zombies))
        zombies = [];

    killed = 0;
    for (i = 0; i < zombies.size; i++)
    {
        zombie = zombies[i];
        if (!isdefined(zombie))
            continue;
        if (isdefined(zombie.health) && zombie.health <= 0)
            continue;

        health = 666;
        if (isdefined(zombie.health))
            health = zombie.health + 666;

        zombie.marked_for_death = true;
        zombie.nuked = true;

        origin = zombie.origin;
        if (!isdefined(origin))
            origin = (0, 0, 0);

        zombie dodamage(health, origin);
        killed += 1;
    }

    if (gg_round_robbin_force_transition_enabled())
    {
        if (isdefined(level) && isdefined(level.zombie_total))
            level.zombie_total = 0;
    }

    if (gg_debug_enabled())
        iprintln("Gumballs: Round Robbin cleared zombies=" + killed);
}

gg_fx_extra_credit(player, gum)
{
    gg_effect_stub_common(player, gum, "Economy/Round");
}

gg_fx_round_robbin(player, gum)
{
    if (!isdefined(player))
        return;

    gg_round_robbin_kill_remaining();
    gg_round_robbin_award_points();
    gg_show_hint_if_enabled(player, "Applied: Round Robbin");
}

gg_shopping_free_begin(player, gum, secs, temp_points)
{
    if (!isdefined(player))
        return 0;

    temp_points = int(temp_points);

    if (!isdefined(player.shopping_free))
        player.shopping_free = spawnstruct();

    if (!isdefined(player.shopping_free.__token_counter))
        player.shopping_free.__token_counter = 0;

    player.shopping_free.__token_counter += 1;
    token = player.shopping_free.__token_counter;

    player.shopping_free.token = token;
    player.shopping_free.active = true;
    player.shopping_free.cleaned = false;
    player.shopping_free.credit_used = 0;
    player.shopping_free.credit_remaining = temp_points;
    player.shopping_free.total_added = temp_points;
    player.shopping_free.original_score = player.score;
    player.shopping_free.start_time = gettime();
    player.shopping_free.duration_ms = int(secs * 1000);
    player.shopping_free.baseline = player.score;
    player.shopping_free.last_score = player.score;
    player.shopping_free.temp_points = temp_points;
    player.shopping_free.secs = secs;
    player.shopping_free.gum_id = "<unknown>";
    if (isdefined(gum) && isdefined(gum.id))
        player.shopping_free.gum_id = gum.id;

    if (temp_points > 0)
    {
        player maps\_zombiemode_score::add_to_player_score(temp_points, false);
        player.shopping_free.baseline = player.score;
        player.shopping_free.last_score = player.score;
    }

    return token;
}

gg_shopping_free_refresh_hud(player, gum, secs)
{
    if (!isdefined(level.gb_hud))
        return;

    if (isdefined(level.gb_hud.show_br))
        [[ level.gb_hud.show_br ]](player, gum);

    if (isdefined(level.gb_hud.br_set_mode))
        [[ level.gb_hud.br_set_mode ]](player, "timer");

    if (isdefined(level.gb_hud.br_start_timer))
        [[ level.gb_hud.br_start_timer ]](player, secs);
}

gg_shopping_free_token_active(expected_token)
{
    if (!isdefined(self.shopping_free))
        return false;
    if (!isdefined(self.shopping_free.token))
        return false;
    if (self.shopping_free.token != expected_token)
        return false;
    if (isdefined(self.shopping_free.active))
        return self.shopping_free.active;
    return false;
}

gg_shopping_free_refund_thread(expected_token)
{
    self endon("disconnect");

    while (true)
    {
        if (!gg_shopping_free_token_active(expected_token))
            return;

        if (!isdefined(self.shopping_free))
            return;

        baseline = self.shopping_free.baseline;
        if (!isdefined(baseline))
            baseline = self.score;

        current = self.score;

        if (current < baseline)
        {
            diff = baseline - current;
            credit_remaining = 0;
            if (isdefined(self.shopping_free.credit_remaining))
                credit_remaining = self.shopping_free.credit_remaining;

            refund = diff;
            if (credit_remaining <= 0)
            {
                refund = 0;
            }
            else if (refund > credit_remaining)
            {
                refund = credit_remaining;
            }

            if (refund > 0)
            {
                self maps\_zombiemode_score::add_to_player_score(refund, false);
                self.shopping_free.credit_remaining = credit_remaining - refund;
                if (self.shopping_free.credit_remaining < 0)
                    self.shopping_free.credit_remaining = 0;
                if (!isdefined(self.shopping_free.credit_used))
                    self.shopping_free.credit_used = 0;
                self.shopping_free.credit_used += refund;
                current = self.score;
            }

            leftover = diff - refund;
            if (leftover > 0)
            {
                self.shopping_free.baseline = current;
            }
            else
            {
                self.shopping_free.baseline = current;
            }
        }
        else
        {
            self.shopping_free.baseline = current;
        }

        self.shopping_free.last_score = current;

        tick = gg_get_timer_tick_ms();
        if (tick < 10)
            tick = 10;
        wait(tick / 1000.0);
    }
}

gg_shopping_free_finalize_credit()
{
    if (!isdefined(self.shopping_free))
        return;
    if (isdefined(self.shopping_free.cleaned) && self.shopping_free.cleaned)
        return;

    total = 0;
    if (isdefined(self.shopping_free.total_added))
        total = self.shopping_free.total_added;

    remove = total;
    if (!isdefined(self.score))
        remove = 0;
    else if (remove > self.score)
        remove = self.score;

    if (remove > 0)
        self maps\_zombiemode_score::minus_to_player_score(remove);

    self.shopping_free.credit_remaining = 0;
    self.shopping_free.active = false;
    self.shopping_free.cleaned = true;
    self.shopping_free.baseline = self.score;
    self.shopping_free.last_score = self.score;

    gg_show_hint_if_enabled(self, "");

    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.clear_hint))
        [[ level.gb_hud.clear_hint ]](self);

    if (gg_debug_enabled())
    {
        used = 0;
        if (isdefined(self.shopping_free.credit_used))
            used = self.shopping_free.credit_used;
        iprintln("Gumballs: Shopping Free cleanup (used=" + used + ", removed=" + remove + ")");
    }
}

gg_shopping_free_cleanup_thread(expected_token)
{
    self endon("disconnect");

    self waittill("gg_gum_cleared");

    if (!gg_shopping_free_token_active(expected_token))
        return;

    gg_shopping_free_finalize_credit();
}

gg_fx_shopping_free(player, gum)
{
    if (!isdefined(player))
        return;

    secs = gg_get_shopping_free_secs();
    temp_points = gg_get_shopping_free_temp_points();

    gg_set_effect_state(player, gum, true);

    token = gg_shopping_free_begin(player, gum, secs, temp_points);

    if (isdefined(player.gg))
        player.gg.timer_endtime = gettime() + int(secs * 1000);

    gg_shopping_free_refresh_hud(player, gum, secs);
    gg_show_hint_if_enabled(player, "Shopping Free: purchases are free");

    player thread gg_shopping_free_refund_thread(token);
    player thread gg_shopping_free_cleanup_thread(token);

    if (gg_debug_enabled())
        iprintln("Gumballs: Shopping Free activated (token=" + token + ", secs=" + secs + ", credit=" + temp_points + ")");
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

