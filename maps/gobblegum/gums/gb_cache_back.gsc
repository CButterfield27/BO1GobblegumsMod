#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

gg_fx_cache_back(player, gum)
{
    maps\gobblegum\gb_helpers::gg_powerup_single_drop(player, gum);
}

register_cache_back()
{
    gum = spawnstruct();
    gum.id = "cache_back";
    gum.name = "Cache Back";
    gum.shader = "bo6_cache_back";
    gum.desc = "Spawns a Max Ammo Power-Up";
    gum.uses_description = "Press D-Pad Right to activate. (1 use)";
    gum.activation = 2; // USER
    gum.consumption = 3; // USES
    gum.base_uses = 1;
    gum.activate_func = ::gg_fx_cache_back;
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    maps\gobblegum\gumballs::gg_register_gum(gum.id, gum);
}
