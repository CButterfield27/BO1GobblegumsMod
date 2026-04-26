#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

register_fatal_contraption()
{
	gum = spawnstruct();
	gum.id = "fatal_contraption";
	gum.name = "Fatal Contraption";
	gum.shader = "t7_hud_zm_bgb_fatal_contraption";
	gum.desc = "Spawns a Death Machine Power-Up";
	gum.uses_description = "Press D-Pad Right to activate. (1 use)";
	gum.activation = 2;
	gum.consumption = 3;
	gum.base_uses = 1;
	gum.activate_func = ::gg_fx_fatal_contraption;
	gum.activate_key = gum.activate_func;
	gum.tags = [];
	gum.whitelist = [];
	gum.blacklist = [];
	gum.exclusion_groups = [];
	gum.rarity_weight = 1;
	maps\gobblegum\gumballs::gg_register_gum(gum.id, gum);
}

gg_fx_fatal_contraption(player, gum)
{
	if (!maps\gobblegum\gb_helpers::gg_can_spawn_death_machine())
	{
		if (maps\gobblegum\gumballs::gg_debug_enabled())
			[[ level.gb_helpers.gg_log ]]("fatal contraption blocked (map)");
		maps\gobblegum\gb_helpers::gg_mark_activation_skip(player);
		return;
	}

	maps\gobblegum\gb_helpers::gg_powerup_single_drop(player, gum);
}
