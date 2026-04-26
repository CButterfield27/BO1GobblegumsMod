#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

register_licensed_contractor()
{
	gum = spawnstruct();
	gum.id = "licensed_contractor";
	gum.name = "Licensed Contractor";
	gum.shader = "t7_hud_zm_bgb_licensed_contractor";
	gum.desc = "Spawns a Carpenter Power-Up";
	gum.uses_description = "Press D-Pad Right to activate. (1 use)";
	gum.activation = 2;
	gum.consumption = 3;
	gum.base_uses = 1;
	gum.activate_func = ::gg_fx_licensed_contractor;
	gum.activate_key = gum.activate_func;
	gum.tags = [];
	gum.whitelist = [];
	gum.blacklist = [];
	gum.exclusion_groups = [];
	gum.rarity_weight = 1;
	maps\gobblegum\gumballs::gg_register_gum(gum.id, gum);
}

gg_fx_licensed_contractor(player, gum)
{
	maps\gobblegum\gb_helpers::gg_powerup_single_drop(player, gum);
}
