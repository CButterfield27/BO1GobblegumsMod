#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\_hud_util;

// GobbleGum Core (Step 1: skeleton + registry only)

gumballs_init()
{
    // Dev DVARs (read at init)
    enable_value = GetDvar("gg_enable");
    if (!isdefined(enable_value) || enable_value == "")
    {
        SetDvar("gg_enable", "1");
    }
    debug_value = GetDvar("gg_debug");
    if (!isdefined(debug_value) || debug_value == "")
    {
        SetDvar("gg_debug", "0");
    }

    if (GetDvarInt("gg_enable") == 0)
    {
        return; // disabled: skip core init
    }

    gg_registry_init();

    if (!isdefined(level.gg_tokens))
    {
        level.gg_tokens = spawnstruct();
        level.gg_tokens.fade = 0;
    }

    if (GetDvarInt("gg_debug") == 1)
    {
        iprintlnbold("Gumballs: init (registry ready)");
    }
}

// Registry (idempotent)
gg_registry_init()
{
    if (isdefined(level.gg_registry_built) && level.gg_registry_built)
        return;

    level.gg_registry = spawnstruct();
    level.gg_registry.gums = [];
    level.gg_registry.index = spawnstruct(); // was [] — use struct for string keys

    // helper to register a gum
    level.gg_register_gum = ::gg_register_gum;
    level.gg_find_gum_by_id = ::gg_find_gum_by_id;

    // Data-only gums for Step 1
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
    gg_register_gum("perkaholic", gum);

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
    gg_register_gum("wall_power", gum);

    level.gg_registry_built = true;
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
    if (!isdefined(level.gg_registry) || !isdefined(level.gg_registry.index[id]))
        return;
    return level.gg_registry.gums[level.gg_registry.index[id]];
}

// Per-player state
build_player_state(player)
{
    if (!isdefined(player.gg))
    {
        player.gg = spawnstruct();
    }

    player.gg.selected_id = undefined;
    player.gg.uses_remaining = 0;
    player.gg.rounds_remaining = 0;
    player.gg.timer_endtime = 0;

    player.gg.armed_flags = spawnstruct();
    player.gg.armed_flags.wall = false;
    player.gg.armed_flags.crate = false;
    player.gg.armed_flags.wonder = false;

    // Call into HUD module if present (function-pointer call syntax)
    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.init_player))
    {
        [[ level.gb_hud.init_player ]](player);
    }
}

// HUD-only selection placeholder
gg_set_selected_gum_name(player, gum_id)
{
    if (!isdefined(player))
        return;

    player.gg.selected_id = gum_id;
    gum = gg_find_gum_by_id(gum_id);

    if (isdefined(level.gb_hud))
    {
        if (isdefined(level.gb_hud.show_tc))
            [[ level.gb_hud.show_tc ]](player, gum);

        if (isdefined(level.gb_hud.hide_tc_after))
        {
            expected_name = "";
            if (isdefined(gum) && isdefined(gum.name))
            {
                expected_name = gum.name;
            }
            [[ level.gb_hud.hide_tc_after ]](player, 7.5, expected_name);
        }

        if (isdefined(level.gb_hud.show_br))
            [[ level.gb_hud.show_br ]](player, gum);
    }
}

gg_apply_selected_gum(player)
{
    if (GetDvarInt("gg_debug") == 1)
    {
        iprintlnbold("Gumballs: apply selected gum (no-op, Step 1)");
    }
}

// Compatibility stubs (empty bodies for Step 1)
gg_on_gum_used() {}
gg_round_monitor() {}
gg_assign_gum_for_new_round() {}
gg_on_round_flow() {}
gg_on_match_end() {}