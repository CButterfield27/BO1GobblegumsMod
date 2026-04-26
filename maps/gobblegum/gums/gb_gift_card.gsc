#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

gg_logic_gift_card_start(player, gum)
{
    if (!isdefined(player))
        return;

    amount = gg_get_gift_card_points();
    amount = int(amount);
    if (amount < 0)
        amount = 0;

    player maps\_zombiemode_score::add_to_player_score(amount);

    hint = "Gift Card: +" + amount + " points";
    gg_show_hint_if_enabled(player, hint);

    if (gg_debug_enabled())
        [[ level.gb_helpers.gg_log ]]("gift card activated (points=" + amount + ")");

    gg_on_gum_used();
}

gg_fx_gift_card(player, gum)
{
    gg_logic_gift_card_start(player, gum);
}

gg_get_gift_card_points()
{
    if (isdefined(level.gg_config) && isdefined(level.gg_config.gift_card_points))
        return level.gg_config.gift_card_points;
    return 30000;
}
