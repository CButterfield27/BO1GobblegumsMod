#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

gg_fx_kill_joy(player, gum)
{
    maps\gobblegum\gb_helpers::gg_powerup_single_drop(player, gum);
}

register_kill_joy()
{
    gum = spawnstruct();
    gum.id = "kill_joy";
    gum.name = "Kill Joy";
    gum.shader = "bo6_kill_joy";
    gum.desc = "Spawns an Insta-Kill Power-Up";
    gum.uses_description = "Press D-Pad Right to activate. (2 uses)";
    gum.activation = 2; // USER
    gum.consumption = 3; // USES
    gum.base_uses = 2;
    gum.activate_func = ::gg_fx_kill_joy;
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    maps\gobblegum\gumballs::gg_register_gum(gum.id, gum);
}
