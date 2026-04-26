#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

gg_fx_wonderbar(player, gum)
{
    if (!isdefined(player))
        return;

    maps\gobblegum\gb_helpers::gg_mark_activation_skip(player);
    gg_wonderbar_arm(player, gum);
}

gg_wonderbar_arm(player, gum)
{
    if (!isdefined(player))
        return;

    if (!isdefined(player.gg))
        maps\gobblegum\gumballs::build_player_state(player);

    player notify("gg_wonderbar_cancel");

    player.gg.br_pending_gum = gum;
    if (isdefined(gum) && isdefined(gum.id))
        player.gg.br_pending_gum_id = gum.id;
    else
        player.gg.br_pending_gum_id = undefined;

    if (!isdefined(player.gg.wonderbar_token))
        player.gg.wonderbar_token = 0;
    if (!isdefined(player.gg.wonderbar_label_token))
        player.gg.wonderbar_label_token = 0;

    player.gg.wonderbar_token += 1;
    token = player.gg.wonderbar_token;
    player.gg.wonderbar_label_token += 1;
    label_token = player.gg.wonderbar_label_token;

    choice = gg_wonderbar_select_choice(player);
    player.gg.wonderbar_choice = choice;

    label_text = gg_wonderbar_choice_label(choice);
    player.gg.wonderbar_label_text = label_text;

    armed_time = gettime();
    player.gg.armed_since = armed_time;
    player.gg.wonderbar_armed_time = armed_time;
    player.gg.wonderbar_suppress_until = 0;

    player.gg.armed_flags.wonder = true;
    player.gg.armed_flags.wonderbar_active = true;

    if (isdefined(level.gb_hud))
    {
        if (isdefined(level.gb_hud.show_br))
            [[ level.gb_hud.show_br ]](player, gum);
        if (isdefined(level.gb_hud.br_set_mode))
            [[ level.gb_hud.br_set_mode ]](player, "uses");
        if (isdefined(level.gb_hud.br_set_total_uses))
            [[ level.gb_hud.br_set_total_uses ]](player, 1);
        if (label_text != "" && isdefined(level.gb_hud.set_hint))
            [[ level.gb_hud.set_hint ]](player, label_text);
    }

    maps\gobblegum\gb_helpers::gg_show_hint_if_enabled(player, "Armed: Wonderbar");
    maps\gobblegum\gb_helpers::gg_spawn_firesale_test_drop(player);

    snapshot = maps\gobblegum\gb_helpers::gg_clone_array(maps\gobblegum\gb_helpers::gg_get_primary_weapons(player));
    player thread gg_wonderbar_monitor_thread(gum, token, armed_time, snapshot);
    player thread gg_wonderbar_label_thread(label_token);

    if (maps\gobblegum\gumballs::gg_debug_enabled())
    {
        msg = "wonderbar armed";
        if (isdefined(choice) && choice != "")
            msg = msg + " (" + choice + ")";
        [[ level.gb_helpers.gg_log ]](msg);
    }
}

gg_wonderbar_monitor_thread(gum, expected_token, armed_time, snapshot)
{
    self endon("disconnect");
    self endon("gg_gum_cleared");
    self endon("gg_wonderbar_cancel");

    known = maps\gobblegum\gb_helpers::gg_clone_array(snapshot);
    poll_secs = maps\gobblegum\gumballs::gg_get_armed_poll_secs();
    if (poll_secs <= 0)
        poll_secs = 0.1;

    while (true)
    {
        wait(poll_secs);

        if (!gg_wonderbar_token_active(expected_token))
            return;

        current = maps\gobblegum\gb_helpers::gg_clone_array(maps\gobblegum\gb_helpers::gg_get_primary_weapons(self));
        new_weapon = maps\gobblegum\gb_helpers::gg_detect_new_weapon(known, current);
        known = current;

        if (!isdefined(new_weapon))
            continue;

        if (!gg_wonderbar_should_replace(self, new_weapon, armed_time))
            continue;

        if (!gg_wonderbar_apply_choice(self, new_weapon))
            continue;

        gg_wonderbar_on_success(self, gum, new_weapon);
        return;
    }
}

gg_wonderbar_on_success(player, gum, weapon)
{
    if (!isdefined(player))
        return;

    maps\gobblegum\gb_helpers::gg_show_hint_if_enabled(player, "Applied: Wonderbar");

    player.gg.armed_flags.wonder = false;
    player.gg.armed_flags.wonderbar_active = false;

    if (maps\gobblegum\gumballs::gg_debug_enabled())
        [[ level.gb_helpers.gg_log ]]("wonderbar granted " + player.gg.wonderbar_choice);

    if (isdefined(player.gg))
        player.gg.uses_remaining = 0;
    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_consume_use))
        [[ level.gb_hud.br_consume_use ]](player);

    wait(0.25);
    if (isdefined(player.gg))
    {
        player.gg.wonderbar_choice = undefined;
        player.gg.wonderbar_label_text = "";
    }
    maps\gobblegum\gb_helpers::gg_end_current_gum(player, "wonderbar_applied");
}

gg_wonderbar_token_active(expected_token)
{
    if (!isdefined(self.gg) || !isdefined(self.gg.wonderbar_token))
        return false;
    return (self.gg.wonderbar_token == expected_token);
}


gg_wonderbar_label_token_active(expected_token)
{
    if (!isdefined(self.gg) || !isdefined(self.gg.wonderbar_label_token))
        return false;
    return (self.gg.wonderbar_label_token == expected_token);
}

gg_wonderbar_select_choice(player)
{
    if (!isdefined(level.gb_helpers) || !isdefined(level.gb_helpers.get_wonder_pool))
        return undefined;

    mapname = undefined;
    if (isdefined(level.gb_helpers.get_current_mapname))
        mapname = [[ level.gb_helpers.get_current_mapname ]]();
    else
        mapname = GetDvar("mapname");

    pool = [[ level.gb_helpers.get_wonder_pool ]](mapname);
    if (!isdefined(pool) || pool.size <= 0)
    {
        if (maps\gobblegum\gumballs::gg_debug_enabled())
            [[ level.gb_helpers.gg_log ]]("wonderbar has no wonder weapons available");
        return undefined;
    }

    idx = RandomInt(pool.size);
    return pool[idx];
}

gg_wonderbar_choice_label(choice)
{
    if (!isdefined(choice) || choice == "")
        return "";

    if (isdefined(level.gb_helpers) && isdefined(level.gb_helpers.get_weapon_display_name))
        return [[ level.gb_helpers.get_weapon_display_name ]](choice);

    return choice;
}

gg_wonderbar_should_replace(player, weapon, armed_time)
{
    if (!isdefined(weapon) || weapon == "" || weapon == "none")
        return false;

    grace_ms = maps\gobblegum\gumballs::gg_get_armed_grace_ms();
    if (isdefined(armed_time) && armed_time > 0 && (gettime() - armed_time) < grace_ms)
        return false;

    if (!maps\gobblegum\gb_helpers::gg_weapon_is_box_weapon(weapon))
        return false;

    if (maps\gobblegum\gb_helpers::gg_weapon_is_wall_buy(weapon))
        return false;

    if (maps\gobblegum\gb_helpers::gg_weapon_is_spawn_pistol(weapon))
        return false;

    return true;
}

gg_wonderbar_apply_choice(player, acquired_weapon)
{
    if (!isdefined(player) || !isdefined(player.gg))
        return false;

    wonder = player.gg.wonderbar_choice;
    if (!isdefined(wonder) || wonder == "")
    {
        if (maps\gobblegum\gumballs::gg_debug_enabled())
            [[ level.gb_helpers.gg_log ]]("wonderbar has no cached choice");
        return false;
    }

    if (!isdefined(level.zombie_weapons) || !isdefined(level.zombie_weapons[wonder]))
    {
        if (maps\gobblegum\gumballs::gg_debug_enabled())
            [[ level.gb_helpers.gg_log ]]("wonderbar choice invalid (" + wonder + ")");
        return false;
    }

    wait(0.25);

    if (isdefined(acquired_weapon) && acquired_weapon != "" && acquired_weapon != "none" && acquired_weapon != wonder)
    {
        if (player HasWeapon(acquired_weapon))
            player TakeWeapon(acquired_weapon);
    }

    player maps\_zombiemode_weapons::weapon_give(wonder);

    if (!player HasWeapon(wonder))
        return false;

    player GiveStartAmmo(wonder);
    player SwitchToWeapon(wonder);

    label_text = gg_wonderbar_choice_label(wonder);
    player.gg.wonderbar_label_text = label_text;
    if (label_text != "" && isdefined(level.gb_hud) && isdefined(level.gb_hud.set_hint))
        [[ level.gb_hud.set_hint ]](player, label_text);

    return true;
}

gg_wonderbar_label_thread(expected_token)
{
    self endon("disconnect");
    self endon("gg_gum_cleared");
    self endon("gg_wonderbar_cancel");

    last_applied_label = "";
    was_suppressed = false;

    while (true)
    {
        if (!gg_wonderbar_label_token_active(expected_token))
            return;

        suppress = false;
        if (isdefined(self.gg) && isdefined(self.gg.wonderbar_suppress_until) && self.gg.wonderbar_suppress_until > gettime())
            suppress = true;

        if (suppress)
        {
            remaining = self.gg.wonderbar_suppress_until - gettime();
            if (remaining < 0)
                remaining = 0;
            if (remaining > 0 && isdefined(level.gb_hud) && isdefined(level.gb_hud.suppress_hint))
                [[ level.gb_hud.suppress_hint ]](self, int(remaining));
            was_suppressed = true;
        }
        else
        {
            if (was_suppressed)
            {
                if (isdefined(level.gb_hud) && isdefined(level.gb_hud.end_suppress_hint))
                    [[ level.gb_hud.end_suppress_hint ]](self);
                was_suppressed = false;
            }

            label_text = "";
            if (isdefined(self.gg) && isdefined(self.gg.wonderbar_label_text))
                label_text = self.gg.wonderbar_label_text;

            cached = "";
            if (isdefined(self.gg) && isdefined(self.gg.hint_last_text))
                cached = self.gg.hint_last_text;

            if (label_text == "")
            {
                if (last_applied_label != "" && cached == last_applied_label)
                {
                    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.clear_hint))
                        [[ level.gb_hud.clear_hint ]](self);
                    last_applied_label = "";
                }
            }
            else
            {
                if (cached == label_text)
                {
                    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.update_hint))
                        [[ level.gb_hud.update_hint ]](self);
                    last_applied_label = label_text;
                }
                else if (cached == "" || cached == last_applied_label)
                {
                    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.set_hint))
                        [[ level.gb_hud.set_hint ]](self, label_text);
                    last_applied_label = label_text;
                }
            }
        }

        wait(maps\gobblegum\gumballs::gg_get_wonder_label_reassert_secs());
    }
}

register_wonderbar()
{
    gum = spawnstruct();
    gum.id = "wonderbar";
    gum.name = "Wonderbar";
    gum.shader = "bo6_wonderbar";
    gum.desc = "Next box gun is Wonder Weapon";
    gum.uses_description = "Active";
    gum.activation = 1; // AUTO
    gum.consumption = 3; // USES
    gum.base_uses = 1;
    gum.activate_func = ::gg_fx_wonderbar;
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.tags[0] = "weapon";
    gum.tags[1] = "wonder";
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    maps\gobblegum\gumballs::gg_register_gum(gum.id, gum);
}
