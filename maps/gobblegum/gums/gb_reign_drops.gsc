#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

gg_fx_reign_drops(player, gum)
{
    codes = gg_collect_reign_drop_codes();

    if (!isdefined(codes) || codes.size <= 0)
    {
        if (gg_should_log_dispatch())
            [[ level.gb_helpers.gg_log ]]("dispatch: reign drops missing power-ups");
        gg_mark_activation_skip(player);
        return;
    }

    gg_mark_activation_skip(player);

    if (!gg_spawn_reign_drop_sequence(player, gum, codes))
    {
        return;
    }

    gg_show_powerup_hint(player, "Reign Drops");
}
