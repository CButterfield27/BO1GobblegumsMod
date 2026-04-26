#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

gg_fx_shopping_free(player, gum)
{
    if (!isdefined(player))
        return;

    secs = gg_get_shopping_free_secs();
    temp_points = gg_get_shopping_free_temp_points();

    maps\gobblegum\gumballs::gg_set_effect_state(player, gum, true);

    token = gg_shopping_free_begin(player, gum, secs, temp_points);

    if (isdefined(player.gg))
        player.gg.timer_endtime = gettime() + int(secs * 1000);

    gg_shopping_free_refresh_hud(player, gum, secs);
    maps\gobblegum\gb_helpers::gg_show_hint_if_enabled(player, "Shopping Free: purchases are free");

    player thread gg_shopping_free_refund_thread(token);
    player thread gg_shopping_free_cleanup_thread(token);

    if (maps\gobblegum\gumballs::gg_debug_enabled())
        [[ level.gb_helpers.gg_log ]]("shopping free activated (token=" + token + ", secs=" + secs + ", credit=" + temp_points + ")");
}

gg_shopping_free_begin(player, gum, secs, temp_points)
{
    if (!isdefined(player))
        return 0;

    temp_points = int(temp_points);

    if (!isdefined(player.shopping_free))
        player.shopping_free = spawnstruct();

    if (!isdefined(player.shopping_free.__token_counter))
        player.shopping_free.__token_counter = 0;

    player.shopping_free.__token_counter += 1;
    token = player.shopping_free.__token_counter;

    player.shopping_free.token = token;
    player.shopping_free.active = true;
    player.shopping_free.cleaned = false;
    player.shopping_free.credit_used = 0;
    player.shopping_free.credit_remaining = temp_points;
    player.shopping_free.total_added = temp_points;
    player.shopping_free.original_score = player.score;
    player.shopping_free.start_time = gettime();
    player.shopping_free.duration_ms = int(secs * 1000);
    player.shopping_free.baseline = player.score;
    player.shopping_free.last_score = player.score;
    player.shopping_free.temp_points = temp_points;
    player.shopping_free.secs = secs;
    player.shopping_free.gum_id = "<unknown>";
    if (isdefined(gum) && isdefined(gum.id))
        player.shopping_free.gum_id = gum.id;

    if (temp_points > 0)
    {
        player maps\_zombiemode_score::add_to_player_score(temp_points, false);
        player.shopping_free.baseline = player.score;
        player.shopping_free.last_score = player.score;
    }

    return token;
}

gg_shopping_free_refresh_hud(player, gum, secs)
{
    if (!isdefined(player))
        return;
    if (!isdefined(level.gb_hud))
        return;

    if (isdefined(player.gg))
    {
        if (!isdefined(player.gg.br_delay_token))
            player.gg.br_delay_token = 0;
        player.gg.br_delay_token += 1;
        player.gg.br_pending_gum = gum;
        if (isdefined(gum) && isdefined(gum.id))
            player.gg.br_pending_gum_id = gum.id;
        else
            player.gg.br_pending_gum_id = undefined;
    }

    if (isdefined(level.gb_hud.show_br))
        [[ level.gb_hud.show_br ]](player, gum);

    if (isdefined(level.gb_hud.br_set_mode))
        [[ level.gb_hud.br_set_mode ]](player, "timer");

    if (isdefined(level.gb_hud.br_start_timer))
        [[ level.gb_hud.br_start_timer ]](player, secs);
}

gg_shopping_free_token_active(expected_token)
{
    if (!isdefined(self.shopping_free))
        return false;
    if (!isdefined(self.shopping_free.token))
        return false;
    if (self.shopping_free.token != expected_token)
        return false;
    if (isdefined(self.shopping_free.active))
        return self.shopping_free.active;
    return false;
}

gg_shopping_free_refund_thread(expected_token)
{
    self endon("disconnect");

    while (true)
    {
        if (!gg_shopping_free_token_active(expected_token))
            return;

        if (!isdefined(self.shopping_free))
            return;

        baseline = self.shopping_free.baseline;
        if (!isdefined(baseline))
            baseline = self.score;

        current = self.score;

        if (current < baseline)
        {
            diff = baseline - current;
            credit_remaining = 0;
            if (isdefined(self.shopping_free.credit_remaining))
                credit_remaining = self.shopping_free.credit_remaining;

            refund = diff;
            if (credit_remaining <= 0)
            {
                refund = 0;
            }
            else if (refund > credit_remaining)
            {
                refund = credit_remaining;
            }

            if (refund > 0)
            {
                self maps\_zombiemode_score::add_to_player_score(refund, false);
                self.shopping_free.credit_remaining = credit_remaining - refund;
                if (self.shopping_free.credit_remaining < 0)
                    self.shopping_free.credit_remaining = 0;
                if (!isdefined(self.shopping_free.credit_used))
                    self.shopping_free.credit_used = 0;
                self.shopping_free.credit_used += refund;
                current = self.score;
            }

            leftover = diff - refund;
            if (leftover > 0)
            {
                self.shopping_free.baseline = current;
            }
            else
            {
                self.shopping_free.baseline = current;
            }
        }
        else
        {
            self.shopping_free.baseline = current;
        }

        self.shopping_free.last_score = current;

        tick = maps\gobblegum\gumballs::gg_get_timer_tick_ms();
        if (tick < 10)
            tick = 10;
        wait(tick / 1000.0);
    }
}

gg_shopping_free_finalize_credit()
{
    if (!isdefined(self.shopping_free))
        return;
    if (isdefined(self.shopping_free.cleaned) && self.shopping_free.cleaned)
        return;

    total = 0;
    if (isdefined(self.shopping_free.total_added))
        total = self.shopping_free.total_added;

    remove = total;
    if (!isdefined(self.score))
        remove = 0;
    else if (remove > self.score)
        remove = self.score;

    if (remove > 0)
        self maps\_zombiemode_score::minus_to_player_score(remove);

    self.shopping_free.credit_remaining = 0;
    self.shopping_free.active = false;
    self.shopping_free.cleaned = true;
    self.shopping_free.baseline = self.score;
    self.shopping_free.last_score = self.score;

    maps\gobblegum\gb_helpers::gg_show_hint_if_enabled(self, "");

    if (isdefined(level.gb_hud) && isdefined(level.gb_hud.clear_hint))
        [[ level.gb_hud.clear_hint ]](self);

    if (maps\gobblegum\gumballs::gg_debug_enabled())
    {
        used = 0;
        if (isdefined(self.shopping_free.credit_used))
            used = self.shopping_free.credit_used;
        [[ level.gb_helpers.gg_log ]]("shopping free cleanup (used=" + used + ", removed=" + remove + ")");
    }
}

gg_shopping_free_cleanup_thread(expected_token)
{
    self endon("disconnect");

    self waittill("gg_gum_cleared");

    if (!gg_shopping_free_token_active(expected_token))
        return;

    gg_shopping_free_finalize_credit();
}

gg_get_shopping_free_secs()
{
    if (isdefined(level.gg_config) && isdefined(level.gg_config.shopping_free_secs))
        return level.gg_config.shopping_free_secs;
    return 60.0;
}

gg_get_shopping_free_temp_points()
{
    if (isdefined(level.gg_config) && isdefined(level.gg_config.shopping_free_temp_points))
        return level.gg_config.shopping_free_temp_points;
    return 50000;
}

register_shopping_free()
{
    gum = spawnstruct();
    gum.id = "shopping_free";
    gum.name = "Shopping Free";
    gum.shader = "t7_hud_zm_bgb_shopping_free";
    gum.desc = "All purchases are free";
    gum.uses_description = "Lasts 1 minute";
    gum.activation = 1; // AUTO
    gum.consumption = 1; // TIMED
    gum.base_duration_secs = gg_get_shopping_free_secs();
    gum.activate_func = ::gg_fx_shopping_free;
    gum.activate_key = gum.activate_func;
    gum.tags = [];
    gum.tags[0] = "economy";
    gum.whitelist = [];
    gum.blacklist = [];
    gum.exclusion_groups = [];
    gum.rarity_weight = 1;
    // maps\gobblegum\gumballs::gg_register_gum(gum.id, gum);
}
