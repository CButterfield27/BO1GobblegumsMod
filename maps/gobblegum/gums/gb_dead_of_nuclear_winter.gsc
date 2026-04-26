#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

register_dead_of_nuclear_winter()
{
	gum = spawnstruct();
	gum.id = "dead_of_nuclear_winter";
	gum.name = "Dead of Nuclear Winter";
	gum.shader = "t7_hud_zm_bgb_dead_of_nuclear_winter";
	gum.desc = "Spawns a Nuke Power-Up";
	gum.uses_description = "Press D-Pad Right to activate. (1 use)";
	gum.activation = 2;
	gum.consumption = 3;
	gum.base_uses = 1;
	gum.activate_func = ::gg_fx_dead_of_nuclear_winter;
	gum.activate_key = gum.activate_func;
	gum.tags = [];
	gum.whitelist = [];
	gum.blacklist = [];
	gum.exclusion_groups = [];
	gum.rarity_weight = 1;
	maps\gobblegum\gumballs::gg_register_gum(gum.id, gum);
}

gg_fx_dead_of_nuclear_winter(player, gum)
{
	maps\gobblegum\gb_helpers::gg_powerup_single_drop(player, gum);
}
