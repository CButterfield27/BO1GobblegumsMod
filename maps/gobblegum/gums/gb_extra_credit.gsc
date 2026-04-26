#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

gg_fx_extra_credit(player, gum)
{
    maps\gobblegum\gb_helpers::gg_powerup_single_drop(player, gum);
}

register_extra_credit()
{
    gum = spawnstruct();
    gum.id = "extra_credit";
    gum.name = "Extra Credit";
    gum.shader = "t7_hud_zm_bgb_extra_credit";
    gum.desc = "Spawns a Bonus Points Power-Up";
    gum.uses_description = "Press D-Pad Right to activate. (2 uses)";
    gum.activation = 2; // USER
    gum.consumption = 3; // USES
    gum.base_uses = 2;
    gum.activate_func = ::gg_fx_extra_credit;
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    maps\gobblegum\gumballs::gg_register_gum(gum.id, gum);
}
