#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

gg_fx_fatal_contraption(player, gum)
{
    if (!gg_can_spawn_death_machine())
    {
        if (gg_debug_enabled())
            [[ level.gb_helpers.gg_log ]]("fatal contraption blocked (map)");
        gg_mark_activation_skip(player);
        return;
    }

    gg_powerup_single_drop(player, gum);
}
