#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

// Activate function called by the system when the user activates this gumball (or automatically)
activate(player, gum)
{
	// Implementation logic here
	// Example: maps\gobblegum\gb_helpers::gg_powerup_single_drop(player, gum);
	
	// Always call this if the activation was successful and consumed a use/duration:
	// maps\gobblegum\gb_helpers::gg_end_current_gum(player, "applied_my_gum");
}

// Self-registration hook called from gumballs.gsc
register()
{
	gum = spawnstruct();
	gum.id = "my_new_gum";
	gum.name = "My New Gum";
	gum.shader = "default_shader";
	gum.desc = "Description of what it does";
	gum.uses_description = "Press D-Pad Right to activate. (1 use)";
	
	// 1 for ACT_AUTO, 2 for ACT_USER
	gum.activation = maps\gobblegum\gb_helpers::ACT_USER(); 
	
	// 1 for CONS_TIMED, 2 for CONS_ROUNDS, 3 for CONS_USES
	gum.consumption = maps\gobblegum\gb_helpers::CONS_USES(); 
	gum.base_uses = 1;
	
	// Direct function pointer to activation logic
	gum.activate_func = ::activate;
	
	// Arrays for tagging and map restrictions
	gum.tags = [];
	gum.whitelist = [];
	gum.blacklist = [];
	gum.exclusion_groups = [];
	gum.rarity_weight = 1;

	// maps\gobblegum\gumballs::gg_register_gum(gum.id, gum);
}
