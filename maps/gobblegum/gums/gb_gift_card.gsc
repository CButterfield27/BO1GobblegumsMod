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
    maps\gobblegum\gb_helpers::gg_show_hint_if_enabled(player, hint);

    if (maps\gobblegum\gumballs::gg_debug_enabled())
        [[ level.gb_helpers.gg_log ]]("gift card activated (points=" + amount + ")");

    maps\gobblegum\gb_helpers::gg_on_gum_used();
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

register_gift_card()
{
    gum = spawnstruct();
    gum.id = "gift_card";
    gum.name = "Gift Card";
    gum.shader = "bo7_gift_card";
    gum.desc = "Adds 15,000 points to your score.";
    gum.uses_description = "Press D-Pad Right to activate. (1 use)";
    gum.activation = 2; // USER
    gum.consumption = 3; // USES
    gum.base_uses = 1;
    gum.activate_func = ::gg_logic_gift_card_start;
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.tags[0] = "economy";
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    maps\gobblegum\gumballs::gg_register_gum(gum.id, gum);
}
