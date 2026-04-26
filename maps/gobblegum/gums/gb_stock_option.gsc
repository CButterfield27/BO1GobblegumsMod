#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

register_stock_option()
{
	gum = spawnstruct();
	gum.id = "stock_option";
	gum.name = "Stock Option";
	gum.shader = "bo6_stock_option";
	gum.desc = "Ammo is taken from the player's stockpile";
	gum.uses_description = "Press D-Pad Right to activate. (1 use)";
	gum.activation = 2;
	gum.consumption = 1;
	gum.base_duration_secs = 60;
	gum.activate_func = ::gg_fx_stock_option;
	gum.activate_key = gum.activate_func;
	gum.tags = [];
	gum.whitelist = [];
	gum.blacklist = [];
	gum.exclusion_groups = [];
	gum.rarity_weight = 1;
	// maps\gobblegum\gumballs::gg_register_gum(gum.id, gum);
}

gg_fx_stock_option(player, gum)
{
	maps\gobblegum\gb_helpers::gg_effect_stub_common(player, gum, "Economy/Round");
}
