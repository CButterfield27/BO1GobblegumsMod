#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

register_whos_keeping_score()
{
	gum = spawnstruct();
	gum.id = "whos_keeping_score";
	gum.name = "Who's Keeping Score";
	gum.shader = "bo6_who_keeping_score";
	gum.desc = "Spawns a Double Points Power-Up";
	gum.uses_description = "Press D-Pad Right to activate. (1 use)";
	gum.activation = 2;
	gum.consumption = 3;
	gum.base_uses = 2;
	gum.activate_func = ::gg_fx_whos_keeping_score;
	gum.activate_key = gum.activate_func;
	gum.tags = [];
	gum.whitelist = [];
	gum.blacklist = [];
	gum.exclusion_groups = [];
	gum.rarity_weight = 1;
	maps\gobblegum\gumballs::gg_register_gum(gum.id, gum);
}

gg_fx_whos_keeping_score(player, gum)
{
	maps\gobblegum\gb_helpers::gg_powerup_single_drop(player, gum);
}
