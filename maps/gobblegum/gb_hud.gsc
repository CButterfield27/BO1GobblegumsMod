#include maps\_hud_util;

// Tiny, centralized layout config to avoid magic numbers
__gg_get_layout()
{
    if (!isdefined(level.gg_hud_layout))
    {
        l = spawnstruct();

        // Top-Center (TC) block tunables (spec reference values)
        l.tc_base_y = 56;        // icon anchor y
        l.tc_icon_w = 56;        // icon size
        l.tc_icon_h = 56;
        l.tc_icon_gap = -15;     // gap icon->name
        l.tc_gap_name_to_uses = 17.5;  // name->uses
        l.tc_gap_uses_to_desc = 17.5;  // uses->desc
        l.tc_name_scale = 1.5;
        l.tc_meta_scale = 1.15; // uses/desc

        // Bottom-Right (BR) block
        l.br_icon_size = 48;
        l.br_bar_w = 75;  l.br_bar_h = 5;

        // Safe-area anchored offsets (relative to bottom-right corner)
        l.br_icon_x = -20;  l.br_icon_y = -150;
        l.br_bar_x  = -10;  l.br_bar_y  = -120;
        l.br_hint_x = -10;  l.br_hint_y = -135; // near bar
        l.br_label_x = -30; l.br_label_y = -185; // reserved for future label

        level.gg_hud_layout = l;
    }

    return level.gg_hud_layout;
}

// Cached set helpers to avoid redundant work
__gg_cache_get(player, key)
{
    if (!isdefined(player.gg) || !isdefined(player.gg.hud) || !isdefined(player.gg.hud.__cache))
        return undefined;
    return player.gg.hud.__cache[key];
}

__gg_cache_set(player, key, val)
{
    if (!isdefined(player.gg) || !isdefined(player.gg.hud))
        return;
    if (!isdefined(player.gg.hud.__cache))
        player.gg.hud.__cache = spawnstruct();
    player.gg.hud.__cache[key] = val;
}

__gg_set_text_if_changed(player, elem, cache_key, text)
{
    last = __gg_cache_get(player, cache_key);
    if (!isdefined(text))
        text = "";
    if (!isdefined(last) || last != text)
    {
        elem SetText(text);
        __gg_cache_set(player, cache_key, text);
    }
}

__gg_set_shader_if_changed(player, elem, cache_key, shader, w, h)
{
    last = __gg_cache_get(player, cache_key);
    // Compose a simple cache signature
    sig = shader + "|" + w + "x" + h;
    if (!isdefined(last) || last != sig)
    {
        if (isdefined(shader))
        {
            elem SetShader(shader, w, h);
        }
        __gg_cache_set(player, cache_key, sig);
    }
}

__gg_apply_layout(hud)
{
    l = __gg_get_layout();

    // Top-Center via setPoint using gap-based layout
    block_top = l.tc_base_y + l.tc_icon_h + l.tc_icon_gap;
    hud.tc_icon setPoint("CENTER", "TOP", 0, l.tc_base_y);

    hud.tc_name.fontScale = l.tc_name_scale;
    hud.tc_name setPoint("CENTER", "TOP", 0, block_top);

    hud.tc_uses.fontScale = l.tc_meta_scale;
    hud.tc_uses setPoint("CENTER", "TOP", 0, block_top + l.tc_gap_name_to_uses);

    hud.tc_desc.fontScale = l.tc_meta_scale;
    hud.tc_desc setPoint("CENTER", "TOP", 0, block_top + l.tc_gap_name_to_uses + l.tc_gap_uses_to_desc);

    // Bottom-Right via setPoint (relative to BOTTOMRIGHT safe area point)
    hud.br_icon setPoint("RIGHT", "BOTTOMRIGHT", l.br_icon_x, l.br_icon_y);

    // Usage bar: background (light gray) + foreground (yellow)
    if (isdefined(hud.br_bar_bg))
        hud.br_bar_bg setPoint("RIGHT", "BOTTOMRIGHT", l.br_bar_x, l.br_bar_y);
    if (isdefined(hud.br_bar_fg))
        hud.br_bar_fg setPoint("RIGHT", "BOTTOMRIGHT", l.br_bar_x, l.br_bar_y);

    hud.br_hint.fontScale = 1.15;
    hud.br_hint setPoint("RIGHT", "BOTTOMRIGHT", l.br_hint_x, l.br_hint_y);

    if (isdefined(hud.br_label))
    {
        hud.br_label.fontScale = 1.05;
        hud.br_label setPoint("RIGHT", "BOTTOMRIGHT", l.br_label_x, l.br_label_y);
    }
}

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
    level.gb_hud.br_set_label = ::br_set_label;
    level.gb_hud.br_clear_label = ::br_clear_label;
    level.gb_hud.precache = ::gg_hud_precache;
}

gg_hud_precache()
{
    ensure_api();
    // Core materials (kept tiny per constraints)
    PrecacheShader("white");
    PrecacheShader("specialty_perk");
    PrecacheShader("specialty_ammo");
    PrecacheShader("bo6_cache_back");
    PrecacheShader("bo6_crate_power");
    PrecacheShader("t7_hud_zm_bgb_dead_of_nuclear_winter");
    PrecacheShader("t7_hud_zm_bgb_extra_credit");
    PrecacheShader("t7_hud_zm_bgb_fatal_contraption");
    PrecacheShader("bo6_hidden_power");
    PrecacheShader("bo6_immolation_liquidation");
    PrecacheShader("bo6_kill_joy");
    PrecacheShader("t7_hud_zm_bgb_licensed_contractor");
    PrecacheShader("bo6_near_death_experience");
    PrecacheShader("bo6_on_the_house");
    PrecacheShader("bo6_perkaholic");
    PrecacheShader("bo6_reign_drops");
    PrecacheShader("bo6_respin_cycle");
    PrecacheShader("t7_hud_zm_bgb_round_robbin");
    PrecacheShader("t7_hud_zm_bgb_shopping_free");
    PrecacheShader("bo6_stock_option");
    PrecacheShader("bo6_wall_power");
    PrecacheShader("bo6_who_keeping_score");
    PrecacheShader("bo6_wonderbar");
}

init_player(player)
{
    ensure_api();
    if (!isdefined(player.gg))
    {
        player.gg = spawnstruct();
    }
    // Run in player context so self.* is consistent
    player thread __gg_init_player_impl();
}

__gg_init_player_impl()
{
    self endon("disconnect");

    // Idempotent: reuse if already built
    if (isdefined(self.gg) && isdefined(self.gg.hud) && isdefined(self.gg.hud.tc_icon))
    {
        self.gg.hud thread __gg_apply_layout_thread();
        return;
    }

    if (!isdefined(self.gg))
    {
        self.gg = spawnstruct();
    }

    hud = spawnstruct();
    self.gg.hud = hud;

    // Top-Center elements (createIcon/createFontString so setPoint works)
    l = __gg_get_layout();
    self.gg.hud.tc_icon = createIcon("white", l.tc_icon_w, l.tc_icon_h);
    self.gg.hud.tc_icon.foreground = true;
    self.gg.hud.tc_icon.hidewheninmenu = true;
    self.gg.hud.tc_icon.alpha = 0;
    self.gg.hud.tc_icon.sort = 20;

    self.gg.hud.tc_name = createFontString("objective", 1.0);
    self.gg.hud.tc_name.foreground = true;
    self.gg.hud.tc_name.hidewheninmenu = true;
    self.gg.hud.tc_name.alpha = 0;
    self.gg.hud.tc_name.color = (1, 1, 1);
    self.gg.hud.tc_name.sort = 21;

    self.gg.hud.tc_uses = createFontString("objective", 1.0);
    self.gg.hud.tc_uses.foreground = true;
    self.gg.hud.tc_uses.hidewheninmenu = true;
    self.gg.hud.tc_uses.alpha = 0;
    self.gg.hud.tc_uses.color = (1, 1, 0.4);
    self.gg.hud.tc_uses.sort = 21;

    self.gg.hud.tc_desc = createFontString("objective", 1.0);
    self.gg.hud.tc_desc.foreground = true;
    self.gg.hud.tc_desc.hidewheninmenu = true;
    self.gg.hud.tc_desc.alpha = 0;
    self.gg.hud.tc_desc.color = (1, 1, 1);
    self.gg.hud.tc_desc.sort = 21;

    // Bottom-Right elements
    self.gg.hud.br_icon = createIcon("white", l.br_icon_size, l.br_icon_size);
    self.gg.hud.br_icon.foreground = true;
    self.gg.hud.br_icon.hidewheninmenu = true;
    self.gg.hud.br_icon.alpha = 0;
    self.gg.hud.br_icon.sort = 20;

    // Usage bar: background and foreground layers
    self.gg.hud.br_bar_bg = createIcon("white", l.br_bar_w, l.br_bar_h);
    self.gg.hud.br_bar_bg.foreground = true;
    self.gg.hud.br_bar_bg.hidewheninmenu = true;
    self.gg.hud.br_bar_bg.alpha = 0;
    self.gg.hud.br_bar_bg.color = (0.85, 0.85, 0.85);
    self.gg.hud.br_bar_bg.sort = 20;

    self.gg.hud.br_bar_fg = createIcon("white", l.br_bar_w, l.br_bar_h);
    self.gg.hud.br_bar_fg.foreground = true;
    self.gg.hud.br_bar_fg.hidewheninmenu = true;
    self.gg.hud.br_bar_fg.alpha = 0;
    self.gg.hud.br_bar_fg.color = (1, 1, 0.2);
    self.gg.hud.br_bar_fg.sort = 21;

    self.gg.hud.br_hint = createFontString("objective", 1.0);
    self.gg.hud.br_hint.foreground = true;
    self.gg.hud.br_hint.hidewheninmenu = true;
    self.gg.hud.br_hint.alpha = 0;
    self.gg.hud.br_hint.color = (1, 1, 0);
    self.gg.hud.br_hint.sort = 22;

    self.gg.hud.br_label = createFontString("objective", 1.0);
    self.gg.hud.br_label.foreground = true;
    self.gg.hud.br_label.hidewheninmenu = true;
    self.gg.hud.br_label.alpha = 0;
    self.gg.hud.br_label.color = (1, 0.85, 0.3);
    self.gg.hud.br_label.sort = 22;

    // Tokens
    self.gg.hud.tokens = spawnstruct();
    self.gg.hud.tokens.fade = 0;

    // Apply initial layout and defaults
    self thread __gg_apply_layout_thread();

    // Bars are already initialized to full width by createIcon
}

// Apply layout using self.gg.hud consistently
__gg_apply_layout_thread()
{
    self endon("disconnect");
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return;
    __gg_apply_layout(self.gg.hud);
}

// Step-1 behavior: immediate show/hide, no fades or timers
show_tc(player, gum)
{
    if (!isdefined(player))
        return;
    player thread __gg_show_tc_impl(gum);
}

__gg_show_tc_impl(gum)
{
    self endon("disconnect");
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return;
    __gg_update_tc_impl(gum);
    self.gg.hud.tc_icon.alpha = 1;
    self.gg.hud.tc_name.alpha = 1;
    self.gg.hud.tc_uses.alpha = 1;
    self.gg.hud.tc_desc.alpha = 1;
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
    if (!isdefined(player))
        return;
    player thread __gg_update_tc_impl(gum);
}

__gg_update_tc_impl(gum)
{
    self endon("disconnect");
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return;
    if (!isdefined(gum))
        return;

    l = __gg_get_layout();

    if (isdefined(gum.shader))
        __gg_set_shader_if_changed(self, self.gg.hud.tc_icon, "tc_icon", gum.shader, l.tc_icon_w, l.tc_icon_h);
    if (isdefined(gum.name))
        __gg_set_text_if_changed(self, self.gg.hud.tc_name, "tc_name", gum.name);
    if (isdefined(gum.desc))
        __gg_set_text_if_changed(self, self.gg.hud.tc_desc, "tc_desc", gum.desc);
    // uses line can be filled later
}

 show_br(player, gum)
 {
     if (!isdefined(player))
         return;
     player thread __gg_show_br_impl(gum);
 }

 __gg_show_br_impl(gum)
 {
     self endon("disconnect");
     if (!isdefined(self.gg) || !isdefined(self.gg.hud))
         return;
     l = __gg_get_layout();
    if (isdefined(gum) && isdefined(gum.shader))
        __gg_set_shader_if_changed(self, self.gg.hud.br_icon, "br_icon", gum.shader, l.br_icon_size, l.br_icon_size);
   // No BR title for Step-1 (leave hint blank until set)
   __gg_set_text_if_changed(self, self.gg.hud.br_hint, "br_hint", "");

    self.gg.hud.br_icon.alpha = 1;
    self.gg.hud.br_bar_bg.alpha = 1;
    self.gg.hud.br_bar_fg.alpha = 1;
    self.gg.hud.br_hint.alpha = 1;
    if (isdefined(self.gg.hud.br_label))
    {
        label_text = "";
        if (isdefined(self.gg.hud.__cache))
            label_text = __gg_cache_get(self, "br_label");
        if (isdefined(label_text) && label_text != "")
            self.gg.hud.br_label.alpha = 1;
        else
            self.gg.hud.br_label.alpha = 0;
    }
}

 hide_br(player)
 {
     if (!isdefined(player))
         return;
     player thread __gg_hide_br_impl();
 }

 __gg_hide_br_impl()
 {
     self endon("disconnect");
     if (!isdefined(self.gg) || !isdefined(self.gg.hud))
         return;
    self.gg.hud.br_icon.alpha = 0;
    self.gg.hud.br_bar_bg.alpha = 0;
    self.gg.hud.br_bar_fg.alpha = 0;
    self.gg.hud.br_hint.alpha = 0;
    if (isdefined(self.gg.hud.br_label))
        self.gg.hud.br_label.alpha = 0;
}

show_br_after_delay(player, secs, expected_name)
{
    // Step 1: show immediately (ignore delay)
    show_br(player, undefined);
}

set_hint(player, text)
{
    if (!isdefined(player))
        return;
    if (!isdefined(text))
        text = "";
    player thread __gg_set_hint_impl(text);
}

clear_hint(player)
{
    set_hint(player, "");
}

__gg_set_hint_impl(text)
{
    self endon("disconnect");
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return;

    if (!isdefined(text))
        text = "";

    debug_on = (GetDvarInt("gg_debug") == 1);

    visible = false;
    if (debug_on && text != "")
        visible = true;

    applied_text = "";
    if (visible)
        applied_text = text;

    __gg_set_text_if_changed(self, self.gg.hud.br_hint, "br_hint", applied_text);
    if (isdefined(self.gg.hud.br_hint))
        self.gg.hud.br_hint.color = (1, 1, 0);

    if (visible)
        self.gg.hud.br_hint.alpha = 1;
    else
        self.gg.hud.br_hint.alpha = 0;
}

// Build 5: BR bar model (uses/rounds/timer). Idempotent, minimal visuals.
br_set_mode(player, mode)
{
    if (!isdefined(player))
        return;
    player thread __gg_br_set_mode_impl(mode);
}

__gg_br_get_state()
{
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return undefined;
    if (!isdefined(self.gg.hud.__br))
        self.gg.hud.__br = spawnstruct();
    if (!isdefined(self.gg.hud.__br.token))
        self.gg.hud.__br.token = 0;
    return self.gg.hud.__br;
}

__gg_br_base_width()
{
    l = __gg_get_layout();
    return l.br_bar_w;
}

__gg_br_set_mode_impl(mode)
{
    self endon("disconnect");
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return;
    st = __gg_br_get_state();
    if (!isdefined(mode))
        mode = "uses";
    st.mode = mode;
    // Reset bar to full
    w = __gg_br_base_width();
    if (isdefined(self.gg.hud.br_bar_fg))
        self.gg.hud.br_bar_fg SetShader("white", w, self.gg.hud.br_bar_fg.height);
}

br_set_total_uses(player, n)
{
    if (!isdefined(player))
        return;
    player thread __gg_br_set_total_impl("uses", n);
}

br_consume_use(player)
{
    if (!isdefined(player))
        return;
    player thread __gg_br_consume_impl("uses");
}

br_set_total_rounds(player, n)
{
    if (!isdefined(player))
        return;
    player thread __gg_br_set_total_impl("rounds", n);
}

br_consume_round(player)
{
    if (!isdefined(player))
        return;
    player thread __gg_br_consume_impl("rounds");
}

__gg_br_set_total_impl(kind, n)
{
    self endon("disconnect");
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return;
    st = __gg_br_get_state();
    if (!isdefined(n) || n <= 0)
        n = 1;
    st.mode = kind;
    st.total = n;
    st.remaining = n;
    __gg_br_update_width_from_state();
}

__gg_br_consume_impl(kind)
{
    self endon("disconnect");
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return;
    st = __gg_br_get_state();
    st.mode = kind;
    if (!isdefined(st.total) || st.total <= 0)
        st.total = 1;
    if (!isdefined(st.remaining))
        st.remaining = st.total;
    if (st.remaining > 0)
        st.remaining -= 1;
    __gg_br_update_width_from_state();
}

__gg_br_update_width_from_state()
{
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return;
    st = __gg_br_get_state();
    total = 1;
    if (isdefined(st.total) && st.total > 0)
        total = st.total;
    remaining = 0;
    if (isdefined(st.remaining) && st.remaining >= 0)
        remaining = st.remaining;
    frac = remaining * 1.0 / total;
    if (frac < 0)
        frac = 0;
    if (frac > 1)
        frac = 1;
    w = int(__gg_br_base_width() * frac);
    if (isdefined(self.gg.hud.br_bar_fg))
        self.gg.hud.br_bar_fg SetShader("white", w, self.gg.hud.br_bar_fg.height);
}

br_start_timer(player, secs)
{
    if (!isdefined(player))
        return;
    player thread __gg_br_start_timer_impl(secs);
}

br_stop_timer(player)
{
    if (!isdefined(player))
        return;
    player thread __gg_br_stop_timer_impl();
}

__gg_br_start_timer_impl(secs)
{
    self endon("disconnect");
    self endon("gg_gum_cleared");
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return;
    st = __gg_br_get_state();
    st.mode = "timer";
    if (!isdefined(secs) || secs <= 0)
        secs = 0.1;
    st.token += 1;
    tok = st.token;
    start = gettime();
    duration_ms = int(secs * 1000);
    base_w = __gg_br_base_width();
    // simple polling loop; idempotent via token
    while (true)
    {
        if (!isdefined(self.gg) || !isdefined(self.gg.hud))
            return;
        if (!isdefined(self.gg.hud.__br) || self.gg.hud.__br.token != tok)
            return;
        now = gettime();
        elapsed = now - start;
        if (elapsed >= duration_ms)
        {
            // force 0 width on completion
            if (isdefined(self.gg.hud.br_bar_fg))
                self.gg.hud.br_bar_fg SetShader("white", 0, self.gg.hud.br_bar_fg.height);
            return;
        }
        frac = 1.0 - (elapsed * 1.0 / duration_ms);
        if (frac < 0) frac = 0;
        if (frac > 1) frac = 1;
        w = int(base_w * frac);
        if (isdefined(self.gg.hud.br_bar_fg))
            self.gg.hud.br_bar_fg SetShader("white", w, self.gg.hud.br_bar_fg.height);
        wait(0.1);
    }
}

__gg_br_stop_timer_impl()
{
    self endon("disconnect");
    if (!isdefined(self.gg) || !isdefined(self.gg.hud) || !isdefined(self.gg.hud.__br))
        return;
    // invalidate any running timer thread
    self.gg.hud.__br.token += 1;
    if (isdefined(self.gg.hud.br_bar_fg))
        self.gg.hud.br_bar_fg SetShader("white", 0, self.gg.hud.br_bar_fg.height);
}

br_set_label(player, text)
{
    if (!isdefined(player))
        return;
    player thread __gg_br_set_label_impl(text);
}

__gg_br_set_label_impl(text)
{
    self endon("disconnect");
    if (!isdefined(self.gg) || !isdefined(self.gg.hud) || !isdefined(self.gg.hud.br_label))
        return;

    if (!isdefined(text))
        text = "";

    __gg_set_text_if_changed(self, self.gg.hud.br_label, "br_label", text);
    if (text == "")
        self.gg.hud.br_label.alpha = 0;
    else
        self.gg.hud.br_label.alpha = 1;
}

br_clear_label(player)
{
    br_set_label(player, "");
}
