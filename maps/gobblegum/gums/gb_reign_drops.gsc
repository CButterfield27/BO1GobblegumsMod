#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

register_reign_drops()
{
	gum = spawnstruct();
	gum.id = "reign_drops";
	gum.name = "Reign Drops";
	gum.shader = "bo6_reign_drops";
	gum.desc = "Spawns all core Power-Ups at once";
	gum.uses_description = "Press D-Pad Right to activate. (1 use)";
	gum.activation = 2;
	gum.consumption = 3;
	gum.base_uses = 1;
	gum.activate_func = ::gg_fx_reign_drops;
	gum.activate_key = gum.activate_func;
	gum.tags = [];
	gum.whitelist = [];
	gum.blacklist = [];
	gum.exclusion_groups = [];
	gum.rarity_weight = 1;
	maps\gobblegum\gumballs::gg_register_gum(gum.id, gum);
}

gg_fx_reign_drops(player, gum)
{
	codes = maps\gobblegum\gb_helpers::gg_collect_reign_drop_codes();

	if (!isdefined(codes) || codes.size <= 0)
	{
		if (maps\gobblegum\gumballs::gg_should_log_dispatch())
			[[ level.gb_helpers.gg_log ]]("dispatch: reign drops missing power-ups");
		maps\gobblegum\gb_helpers::gg_mark_activation_skip(player);
		return;
	}

	maps\gobblegum\gb_helpers::gg_mark_activation_skip(player);

	if (!maps\gobblegum\gb_helpers::gg_spawn_reign_drop_sequence(player, gum, codes))
	{
		return;
	}

	maps\gobblegum\gb_helpers::gg_show_powerup_hint(player, "Reign Drops");
}
