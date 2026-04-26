#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

activate(player, gum)
{

	 maps\gobblegum\gb_helpers::gg_powerup_single_drop(player, gum);

	 the activation was successful and consumed a use/duration:
	// maps\gobblegum\gb_helpers::gg_end_current_gum(player, "applied_my_gum");
}

register()
{
	gum = spawnstruct();
	gum.id = "my_new_gum";
	gum.name = "My New Gum";
	gum.shader = "default_shader";
	gum.desc = "Description of what it does";
	gum.uses_description = "Press D-Pad Right to activate. (1 use)";

	gum.activation = maps\gobblegum\gb_helpers::ACT_USER();

	gum.consumption = maps\gobblegum\gb_helpers::CONS_USES();
	gum.base_uses = 1;

	gum.activate_func = ::activate;

	gum.tags = [];
	gum.whitelist = [];
	gum.blacklist = [];
	gum.exclusion_groups = [];
	gum.rarity_weight = 1;

	// maps\gobblegum\gumballs::gg_register_gum(gum.id, gum);
}
