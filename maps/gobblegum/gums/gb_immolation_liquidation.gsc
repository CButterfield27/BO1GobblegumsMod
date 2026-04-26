#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

gg_fx_immolation(player, gum)
{
    if (gg_powerup_single_drop(player, gum))
    {
        gg_wonderbar_suppress_label(player, 0);
    }
}
