// GobbleGum HUD (Step 1: precache + API stubs)

ensure_api()
{
    if (isdefined(level.gb_hud))
    {
        return;
    }

    level.gb_hud = spawnstruct();
    level.gb_hud.init_player = ::init_player;
    level.gb_hud.show_tc = ::show_tc;
    level.gb_hud.hide_tc_after = ::hide_tc_after;
    level.gb_hud.update_tc = ::update_tc;
    level.gb_hud.show_br = ::show_br;
    level.gb_hud.hide_br = ::hide_br;
    level.gb_hud.show_br_after_delay = ::show_br_after_delay;
    level.gb_hud.set_hint = ::set_hint;
    level.gb_hud.clear_hint = ::clear_hint;
    level.gb_hud.br_set_mode = ::br_set_mode;
    level.gb_hud.br_set_total_uses = ::br_set_total_uses;
    level.gb_hud.br_consume_use = ::br_consume_use;
    level.gb_hud.br_set_total_rounds = ::br_set_total_rounds;
    level.gb_hud.br_consume_round = ::br_consume_round;
    level.gb_hud.br_start_timer = ::br_start_timer;
    level.gb_hud.br_stop_timer = ::br_stop_timer;
    level.gb_hud.precache = ::gg_hud_precache;
}

gg_hud_precache()
{
    ensure_api();
    PrecacheShader("white");
    PrecacheShader("specialty_perk");
    PrecacheShader("specialty_ammo");
}

init_player(player)
{
    ensure_api();
    if (!isdefined(player.gg))
    {
        player.gg = spawnstruct();
    }

    hud = spawnstruct();

    // Top-Center elements
    hud.tc_icon = NewHudElem();
    hud.tc_icon.hidewheninmenu = true;
    hud.tc_icon.alpha = 0;

    hud.tc_name = NewHudElem();
    hud.tc_name.hidewheninmenu = true;
    hud.tc_name.alpha = 0;

    hud.tc_uses = NewHudElem();
    hud.tc_uses.hidewheninmenu = true;
    hud.tc_uses.alpha = 0;

    hud.tc_desc = NewHudElem();
    hud.tc_desc.hidewheninmenu = true;
    hud.tc_desc.alpha = 0;

    // Bottom-Right elements
    hud.br_icon = NewHudElem();
    hud.br_icon.hidewheninmenu = true;
    hud.br_icon.alpha = 0;

    hud.br_bar = NewHudElem();
    hud.br_bar.hidewheninmenu = true;
    hud.br_bar.alpha = 0;
    hud.br_bar SetShader("white", 75, 5);

    hud.br_hint = NewHudElem();
    hud.br_hint.hidewheninmenu = true;
    hud.br_hint.alpha = 0;

    hud.br_label = NewHudElem();
    hud.br_label.hidewheninmenu = true;
    hud.br_label.alpha = 0;

    // Tokens
    hud.tokens = spawnstruct();
    hud.tokens.fade = 0;

    player.gg.hud = hud;
}

// Step-1 behavior: immediate show/hide, no fades or timers
show_tc(player, gum)
{
    if (!isdefined(player) || !isdefined(player.gg) || !isdefined(player.gg.hud))
        return;
    update_tc(player, gum);
    player.gg.hud.tc_icon.alpha = 1;
    player.gg.hud.tc_name.alpha = 1;
    player.gg.hud.tc_uses.alpha = 1;
    player.gg.hud.tc_desc.alpha = 1;
}

hide_tc_after(player, secs, expected_name)
{
    if (!isdefined(player))
        return;
    // Run a small per-player thread to delay-hide TC elements
    player thread __gg_tc_hide_after(secs);
}

__gg_tc_hide_after(secs)
{
    self endon("disconnect");
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return;
    if (!isdefined(secs))
        secs = 0;
    if (secs > 0)
        wait(secs);
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return;
    self.gg.hud.tc_icon.alpha = 0;
    self.gg.hud.tc_name.alpha = 0;
    self.gg.hud.tc_uses.alpha = 0;
    self.gg.hud.tc_desc.alpha = 0;
}

update_tc(player, gum)
{
    if (!isdefined(player) || !isdefined(player.gg) || !isdefined(player.gg.hud))
        return;
    if (!isdefined(gum))
        return;

    if (isdefined(gum.shader))
        player.gg.hud.tc_icon SetShader(gum.shader, 56, 56);
    if (isdefined(gum.name))
        player.gg.hud.tc_name SetText(gum.name);
    if (isdefined(gum.desc))
        player.gg.hud.tc_desc SetText(gum.desc);
    // uses line can be filled later
}

show_br(player, gum)
{
    if (!isdefined(player) || !isdefined(player.gg) || !isdefined(player.gg.hud))
        return;

    if (isdefined(gum) && isdefined(gum.shader))
        player.gg.hud.br_icon SetShader(gum.shader, 48, 48);
    if (isdefined(gum) && isdefined(gum.name))
        player.gg.hud.br_label SetText(gum.name);

    player.gg.hud.br_icon.alpha = 1;
    player.gg.hud.br_bar.alpha = 1;
    player.gg.hud.br_hint.alpha = 1;
    player.gg.hud.br_label.alpha = 1;
}

hide_br(player)
{
    if (!isdefined(player) || !isdefined(player.gg) || !isdefined(player.gg.hud))
        return;
    player.gg.hud.br_icon.alpha = 0;
    player.gg.hud.br_bar.alpha = 0;
    player.gg.hud.br_hint.alpha = 0;
    player.gg.hud.br_label.alpha = 0;
}

show_br_after_delay(player, secs, expected_name)
{
    // Step 1: show immediately (ignore delay)
    show_br(player, undefined);
}

set_hint(player, text)
{
    if (!isdefined(player) || !isdefined(player.gg) || !isdefined(player.gg.hud))
        return;
    if (!isdefined(text))
        text = "";
    player.gg.hud.br_hint SetText(text);
    player.gg.hud.br_hint.alpha = 1;
}

clear_hint(player)
{
    set_hint(player, "");
}

// No-ops for Step 1 progress/timer APIs
br_set_mode(player, mode)
{
}
br_set_total_uses(player, n)
{
}
br_consume_use(player)
{
}
br_set_total_rounds(player, n)
{
}
br_consume_round(player)
{
}
br_start_timer(player, secs)
{
}
br_stop_timer(player, secs)
{
}
