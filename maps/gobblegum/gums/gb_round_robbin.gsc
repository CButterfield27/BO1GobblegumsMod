#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

register_round_robbin()
{
	gum = spawnstruct();
	gum.id = "round_robbin";
	gum.name = "Round Robbin";
	gum.shader = "t7_hud_zm_bgb_round_robbin";
	gum.desc = "Ends the current round. All players gain 1600 points";
	gum.uses_description = "Press D-Pad Right to activate. (1 use)";
	gum.activation = 2;
	gum.consumption = 3;
	gum.base_uses = 1;
	gum.activate_func = ::gg_fx_round_robbin;
	gum.activate_key = gum.activate_func;
	gum.tags = [];
	gum.tags[0] = "economy";
	gum.tags[1] = "round";
	gum.whitelist = [];
	gum.blacklist = [];
	gum.exclusion_groups = [];
	gum.rarity_weight = 1;
	maps\gobblegum\gumballs::gg_register_gum(gum.id, gum);
}

gg_fx_round_robbin(player, gum)
{
	if (!isdefined(player))
		return;

	gg_round_robbin_kill_remaining();
	gg_round_robbin_award_points();
	maps\gobblegum\gb_helpers::gg_show_hint_if_enabled(player, "Applied: Round Robbin");
}

gg_round_robbin_kill_remaining()
{
	zombies = getaispeciesarray("axis");
	if (!isdefined(zombies))
		zombies = [];

	killed = 0;
	for (i = 0; i < zombies.size; i++)
	{
		zombie = zombies[i];
		if (!isdefined(zombie))
			continue;
		if (isdefined(zombie.health) && zombie.health <= 0)
			continue;

		health = 666;
		if (isdefined(zombie.health))
			health = zombie.health + 666;

		zombie.marked_for_death = true;
		zombie.nuked = true;

		origin = zombie.origin;
		if (!isdefined(origin))
			origin = (0, 0, 0);

		zombie dodamage(health, origin);
		killed += 1;
	}

	if (gg_round_robbin_force_transition_enabled())
	{
		if (isdefined(level) && isdefined(level.zombie_total))
			level.zombie_total = 0;
	}

	if (maps\gobblegum\gumballs::gg_debug_enabled())
		[[ level.gb_helpers.gg_log ]]("round robbin cleared zombies=" + killed);
}

gg_round_robbin_award_points()
{
	bonus = gg_get_round_robbin_bonus();
	if (bonus <= 0)
		return 0;

	bonus = int(bonus);

	players = get_players();
	if (!isdefined(players))
		players = [];

	awarded = 0;
	for (i = 0; i < players.size; i++)
	{
		target = players[i];
		if (!isdefined(target))
			continue;
		target maps\_zombiemode_score::add_to_player_score(bonus);
		awarded += 1;
	}

	if (maps\gobblegum\gumballs::gg_debug_enabled())
		[[ level.gb_helpers.gg_log ]]("round robbin bonus +" + bonus + " to " + awarded + " players");

	return awarded;
}

gg_get_round_robbin_bonus()
{
	if (isdefined(level.gg_config) && isdefined(level.gg_config.round_robbin_bonus))
		return level.gg_config.round_robbin_bonus;
	return 1600;
}

gg_round_robbin_force_transition_enabled()
{
	if (isdefined(level.gg_config) && isdefined(level.gg_config.round_robbin_force_transition))
		return level.gg_config.round_robbin_force_transition;
	return true;
}
