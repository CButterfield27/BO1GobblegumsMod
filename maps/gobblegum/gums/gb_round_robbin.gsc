#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

gg_fx_round_robbin(player, gum)
{
    if (!isdefined(player))
        return;

    gg_round_robbin_kill_remaining();
    gg_round_robbin_award_points();
    gg_show_hint_if_enabled(player, "Applied: Round Robbin");
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

    if (gg_debug_enabled())
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

    if (gg_debug_enabled())
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
