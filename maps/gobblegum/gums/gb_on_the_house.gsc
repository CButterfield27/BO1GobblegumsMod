#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

register_on_the_house()
{
	gum = spawnstruct();
	gum.id = "on_the_house";
	gum.name = "On the House";
	gum.shader = "bo6_on_the_house";
	gum.desc = "Spawns a free perk Power-Up";
	gum.uses_description = "Press D-Pad Right to activate. (1 use)";
	gum.activation = 2;
	gum.consumption = 3;
	gum.base_uses = 1;
	gum.activate_func = ::gg_fx_on_the_house;
	gum.activate_key = gum.activate_func;
	gum.tags = [];
	gum.whitelist = [];
	gum.blacklist = [];
	gum.exclusion_groups = [];
	gum.rarity_weight = 1;
	maps\gobblegum\gumballs::gg_register_gum(gum.id, gum);
}

gg_fx_on_the_house(player, gum)
{
	maps\gobblegum\gb_helpers::gg_powerup_single_drop(player, gum);
}
