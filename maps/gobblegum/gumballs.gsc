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
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    gg_register_gum(gum.id, gum);

    gum = spawnstruct();
    gum.id = "wall_power";
    gum.name = "Wall Power";
    gum.shader = "bo6_wall_power";
    gum.desc = "Next wall-buy is PaP";
    gum.activation = 2; // ACT_USER (armed gum in future builds)
    gum.consumption = 2; // CONS_ROUNDS (placeholder; armed logic later)
    gum.base_rounds = 3;
    gum.activate_func = "gg_fx_wall_power";
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    // gg_register_gum(gum.id, gum);
    
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
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    // gg_register_gum(gum.id, gum);

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
    // gg_register_gum(gum.id, gum);

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
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    // gg_register_gum(gum.id, gum);

    // Shopping Free - Timed (TEST: timed-based)
    gum = spawnstruct();
    gum.id = "shopping_free";
    gum.name = "Shopping Free";
    gum.shader = "t7_hud_zm_bgb_shopping_free";
    gum.desc = "All purchases are free";
    gum.activation = 1; // AUTO
    gum.consumption = 1; // TIMED
    gum.base_duration_secs = 60;
    gum.activate_func = "gg_fx_shopping_free";
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    // gg_register_gum(gum.id, gum);

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
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    // gg_register_gum(gum.id, gum);

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

    // Seed consumption state for the selected gum and configure BR bar
    gg_seed_consumption_state(player, gum);

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

    // Build 5 consumption defaults
    gg_ensure_dvar_int("gg_default_uses", 3);
    gg_ensure_dvar_int("gg_default_rounds", 3);
    gg_ensure_dvar_float("gg_default_timer_secs", 60.0);
    gg_ensure_dvar_int("gg_timer_tick_ms", 100);
    gg_ensure_dvar_int("gg_consume_logs", 1);

    // Build 6 power-up knobs
    gg_ensure_dvar_float("gg_drop_forward_units", 70.0);
    gg_ensure_dvar_int("gg_reigndrops_spacing_ms", 150);
    gg_ensure_dvar_int("gg_reigndrops_include_firesale", 1);
    gg_ensure_dvar_int("gg_powerup_hints", 1);

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

    level.gg_config.reigndrops_spacing_ms = GetDvarInt("gg_reigndrops_spacing_ms");
    if (level.gg_config.reigndrops_spacing_ms < 0)
        level.gg_config.reigndrops_spacing_ms = 0;

    level.gg_config.reigndrops_include_firesale = (GetDvarInt("gg_reigndrops_include_firesale") != 0);
    level.gg_config.powerup_hints = (GetDvarInt("gg_powerup_hints") != 0);
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

    // Placeholder stub for Build 6; suppression wiring arrives with Wonderbar implementation.
    if (gg_debug_enabled())
    {
        // Keep the log succinct to avoid spam.
        iprintln("Gumballs: wonderbar suppress stub (" + duration + "s)");
    }
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

gg_reign_drop_circle_positions(player, codes)
{
    positions = [];

    if (!isdefined(player) || !isdefined(codes) || codes.size <= 0)
        return positions;

    base_angles = (0, player.angles[1], 0);
    forward = AnglesToForward(base_angles);
    right = AnglesToRight(base_angles);

    center_offset = gg_get_drop_forward_units() + 75.0;
    center = player.origin + (forward * center_offset);

    radius = 70.0;
    if (radius < 1.0)
        radius = 70.0;

    step = 360.0 / codes.size;

    for (i = 0; i < codes.size; i++)
    {
        angle = i * step;
        forward_component = cos(angle) * radius;
        right_component = sin(angle) * radius;
        pos = center + (forward * forward_component) + (right * right_component);
        positions[positions.size] = pos;
    }

    return positions;
}

gg_collect_reign_drop_codes()
{
    codes = [];

    codes[codes.size] = "nuke";
    codes[codes.size] = "insta_kill";
    codes[codes.size] = "double_points";
    codes[codes.size] = "carpenter";
    codes[codes.size] = "full_ammo";
    codes[codes.size] = "free_perk";

    if (gg_reigndrops_include_firesale())
        codes[codes.size] = "fire_sale";

    if (gg_can_spawn_death_machine())
        codes[codes.size] = "minigun";

    return codes;
}

gg_spawn_reign_drop_sequence(player, gum, codes)
{
    if (!isdefined(player) || !isdefined(codes) || codes.size <= 0)
        return false;

    gum_id = "<unknown>";
    if (isdefined(gum) && isdefined(gum.id))
        gum_id = gum.id;

    spacing = gg_get_reigndrops_spacing_secs();
    positions = gg_reign_drop_circle_positions(player, codes);
    player thread gg_reign_drop_sequence_thread(gum_id, codes, spacing, positions);
    return true;
}

gg_reign_drop_sequence_thread(gum_id, codes, spacing, positions)
{
    self endon("disconnect");
    self endon("gg_gum_cleared");

    if (!isdefined(codes))
        return;

    total = codes.size;
    for (i = 0; i < total; i++)
    {
        code = codes[i];
        fan = gg_powerup_fan_offset(i, total);
        pos_override = undefined;
        if (isdefined(positions) && positions.size > i)
            pos_override = positions[i];

        gg_spawn_and_track_powerup(self, gum_id, code, fan, false, pos_override);

        if (spacing > 0 && i < total - 1)
        {
            wait(spacing);
        }
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

        // USes model: if used at least once in the last round, cycle to a new gum
        if (isdefined(player.gg) && isdefined(player.gg.consumption_type) && player.gg.consumption_type == gg_cons_uses())
        {
            if (isdefined(player.gg.used_this_round) && player.gg.used_this_round)
            {
                gg_end_current_gum(player, "round_change_after_use");
            }
        }

        // ROUNDS model: decrement exactly once per new round while active
        gg_round_tick(player, round_number);

        // Assign a new gum only if none is currently selected
        needs_selection = true;
        if (isdefined(player.gg))
        {
            if (isdefined(player.gg.selected_id) && player.gg.selected_id != undefined && player.gg.selected_id != "")
            {
                needs_selection = false;
            }
        }

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

    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_stop_timer))
        [[ level.gb_hud.br_stop_timer ]](player);

    player.gg.is_active = false;
    player.gg.uses_remaining = 0;
    player.gg.rounds_remaining = 0;
    player.gg.timer_endtime = 0;
    player.gg.used_this_round = false;
    player.gg.active_token += 1;

    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.hide_br))
        [[ level.gb_hud.hide_br ]](player);

    player notify("gg_gum_cleared");
    player notify("gg_wonderbar_end");

    player.gg.selected_id = undefined;
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

    if (!gg_spawn_reign_drop_sequence(player, gum, codes))
    {
        gg_mark_activation_skip(player);
        return;
    }

    gg_show_powerup_hint(player, "Reign Drops");
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
    gg_powerup_single_drop(player, gum);
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

