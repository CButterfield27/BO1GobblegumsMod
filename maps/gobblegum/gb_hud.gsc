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

__gg_get_fade_secs()
{
    secs = 0.25;
    if (isdefined(level.gb_helpers) && isdefined(level.gb_helpers.GG_HUD_FADE_SECS))
    {
        secs = [[ level.gb_helpers.GG_HUD_FADE_SECS ]]();
    }
    if (!isdefined(secs) || secs < 0)
        secs = 0;
    return secs;
}

__gg_tc_elements()
{
    elems = [];
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return elems;
    elems[elems.size] = self.gg.hud.tc_icon;
    elems[elems.size] = self.gg.hud.tc_name;
    elems[elems.size] = self.gg.hud.tc_uses;
    elems[elems.size] = self.gg.hud.tc_desc;
    return elems;
}

__gg_tc_current_alpha()
{
    elems = __gg_tc_elements();
    for (i = 0; i < elems.size; i++)
    {
        elem = elems[i];
        if (isdefined(elem) && isdefined(elem.alpha))
            return elem.alpha;
    }
    return 0;
}

__gg_tc_apply_alpha(alpha)
{
    if (alpha < 0)
        alpha = 0;
    if (alpha > 1)
        alpha = 1;
    elems = __gg_tc_elements();
    for (i = 0; i < elems.size; i++)
    {
        elem = elems[i];
        if (!isdefined(elem))
            continue;
        elem.alpha = alpha;
    }
}

__gg_tc_invalidate_autohide()
{
    if (!isdefined(self.gg))
        return 0;
    if (!isdefined(self.gg.tc_token))
        self.gg.tc_token = 0;
    self.gg.tc_token += 1;
    return self.gg.tc_token;
}

__gg_tc_begin_show(gum)
{
    token = __gg_tc_invalidate_autohide();

    if (isdefined(self.gg))
    {
        if (isdefined(gum) && isdefined(gum.id))
            self.gg.tc_active_id = gum.id;
        else
            self.gg.tc_active_id = "";
        if (isdefined(gum) && isdefined(gum.name))
            self.gg.tc_active_name = gum.name;
        else
            self.gg.tc_active_name = "";
    }

    return token;
}

__gg_tc_start_fade(target_alpha)
{
    if (!isdefined(self.gg.tc_fade_token))
        self.gg.tc_fade_token = 0;
    self.gg.tc_fade_token += 1;
    tok = self.gg.tc_fade_token;

    start_alpha = __gg_tc_current_alpha();
    duration = __gg_get_fade_secs();
    if (duration <= 0)
    {
        __gg_tc_apply_alpha(target_alpha);
        return tok;
    }

    self thread __gg_tc_fade_thread(start_alpha, target_alpha, duration, tok);
    return tok;
}

__gg_tc_fade_thread(start_alpha, target_alpha, duration_secs, expected_token)
{
    self endon("disconnect");
    // removed endon("gg_gum_cleared") to ensure fades finish

    total_ms = int(duration_secs * 1000);
    if (total_ms <= 0)
    {
        __gg_tc_apply_alpha(target_alpha);
        return;
    }

    start_time = gettime();
    while (true)
    {
        if (!isdefined(self.gg) || !isdefined(self.gg.tc_fade_token) || self.gg.tc_fade_token != expected_token)
            return;

        now = gettime();
        elapsed = now - start_time;
        if (elapsed >= total_ms)
        {
            __gg_tc_apply_alpha(target_alpha);
            return;
        }

        frac = elapsed * 1.0 / total_ms;
        if (frac < 0)
            frac = 0;
        if (frac > 1)
            frac = 1;

        current = start_alpha + (target_alpha - start_alpha) * frac;
        __gg_tc_apply_alpha(current);
        wait(0.05);
    }
}

__gg_br_elements()
{
    elems = [];
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return elems;
    elems[elems.size] = self.gg.hud.br_icon;
    elems[elems.size] = self.gg.hud.br_bar_bg;
    elems[elems.size] = self.gg.hud.br_bar_fg;
    elems[elems.size] = self.gg.hud.br_hint;
    return elems;
}

__gg_br_current_alpha()
{
    elems = __gg_br_elements();
    for (i = 0; i < elems.size; i++)
    {
        elem = elems[i];
        if (isdefined(elem) && isdefined(elem.alpha))
            return elem.alpha;
    }
    return 0;
}

__gg_br_should_force_zero(elem)
{
    if (!isdefined(elem))
        return false;
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return false;
    if (__gg_hint_is_suppressed())
        return true;
    // Keep hint hidden when no text is assigned
    if (elem == self.gg.hud.br_hint)
    {
        cached = __gg_cache_get(self, "br_hint");
        if (!isdefined(cached) || cached == "")
            return true;
    }
    return false;
}

__gg_br_apply_alpha(alpha)
{
    if (alpha < 0)
        alpha = 0;
    if (alpha > 1)
        alpha = 1;
    elems = __gg_br_elements();
    for (i = 0; i < elems.size; i++)
    {
        elem = elems[i];
        if (!isdefined(elem))
            continue;
        if (__gg_br_should_force_zero(elem))
        {
            elem.alpha = 0;
            continue;
        }
        elem.alpha = alpha;
    }
    if (isdefined(self.gg) && isdefined(self.gg.hud) && isdefined(self.gg.hud.br_label))
    {
        label_text = "";
        if (isdefined(self.gg.hud.__cache))
            label_text = __gg_cache_get(self, "br_label");
        if (!isdefined(label_text) || label_text == "")
            self.gg.hud.br_label.alpha = 0;
        else
            self.gg.hud.br_label.alpha = alpha;
    }
}

__gg_br_start_fade(target_alpha, clear_after)
{
    if (!isdefined(self.gg.br_fade_token))
        self.gg.br_fade_token = 0;
    self.gg.br_fade_token += 1;
    tok = self.gg.br_fade_token;

    start_alpha = __gg_br_current_alpha();
    duration = __gg_get_fade_secs();
    if (duration <= 0)
    {
        __gg_br_apply_alpha(target_alpha);
        if (target_alpha <= 0 && clear_after)
            __gg_br_clear_visual_state();
        return tok;
    }

    self thread __gg_br_fade_thread(start_alpha, target_alpha, duration, tok, clear_after);
    return tok;
}

__gg_br_fade_thread(start_alpha, target_alpha, duration_secs, expected_token, clear_after)
{
    self endon("disconnect");
    // removed endon("gg_gum_cleared") to ensure fades finish

    total_ms = int(duration_secs * 1000);
    if (total_ms <= 0)
    {
        __gg_br_apply_alpha(target_alpha);
        if (target_alpha <= 0 && clear_after)
            __gg_br_clear_visual_state();
        return;
    }

    start_time = gettime();
    while (true)
    {
        if (!isdefined(self.gg) || !isdefined(self.gg.br_fade_token) || self.gg.br_fade_token != expected_token)
            return;

        now = gettime();
        elapsed = now - start_time;
        if (elapsed >= total_ms)
        {
            __gg_br_apply_alpha(target_alpha);
            if (target_alpha <= 0 && clear_after)
                __gg_br_clear_visual_state();
            return;
        }

        frac = elapsed * 1.0 / total_ms;
        if (frac < 0)
            frac = 0;
        if (frac > 1)
            frac = 1;

        current = start_alpha + (target_alpha - start_alpha) * frac;
        __gg_br_apply_alpha(current);
        wait(0.05);
    }
}

__gg_br_clear_visual_state()
{
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return;

    if (isdefined(self.gg.hud.br_icon))
        self.gg.hud.br_icon.alpha = 0;
    if (isdefined(self.gg.hud.br_bar_bg))
        self.gg.hud.br_bar_bg.alpha = 0;
    if (isdefined(self.gg.hud.br_bar_fg))
    {
        self.gg.hud.br_bar_fg.alpha = 0;
        self.gg.hud.br_bar_fg SetShader("white", 0, self.gg.hud.br_bar_fg.height);
    }
    if (isdefined(self.gg.hud.br_hint))
        self.gg.hud.br_hint.alpha = 0;
    if (isdefined(self.gg.hud.br_label))
        self.gg.hud.br_label.alpha = 0;

    if (isdefined(self.gg.hud.__br))
    {
        self.gg.hud.__br.total = 0;
        self.gg.hud.__br.remaining = 0;
    }

    if (isdefined(self.gg))
    {
        self.gg.br_pending_gum = undefined;
        self.gg.br_pending_gum_id = undefined;
    }

    __gg_cache_set(self, "br_hint", "");
    __gg_cache_set(self, "br_label", "");
}

__gg_hint_store(text)
{
    if (!isdefined(self.gg))
        return;
    if (!isdefined(text))
        text = "";
    self.gg.hint_last_text = text;
}

__gg_hint_is_suppressed()
{
    if (!isdefined(self.gg) || !isdefined(self.gg.hint_suppressed_until))
        return false;
    return (self.gg.hint_suppressed_until > gettime());
}

__gg_hint_apply_text(text, alpha)
{
    if (!isdefined(self.gg) || !isdefined(self.gg.hud) || !isdefined(self.gg.hud.br_hint))
        return;

    if (!isdefined(text))
        text = "";

    __gg_set_text_if_changed(self, self.gg.hud.br_hint, "br_hint", text);
    self.gg.hud.br_hint.color = (1, 1, 0);
    if (alpha < 0)
        alpha = 0;
    if (alpha > 1)
        alpha = 1;
    if (text == "")
        alpha = 0;
    self.gg.hud.br_hint.alpha = alpha;
}

__gg_hint_hide_immediate()
{
    if (!isdefined(self.gg) || !isdefined(self.gg.hud) || !isdefined(self.gg.hud.br_hint))
        return;
    self.gg.hud.br_hint.alpha = 0;
}

__gg_debug_hud_create()
{
    if (isdefined(level.gg_debug_text))
        return;

    data = spawnstruct();
    data.base_x = 30;
    data.base_y = 110;
    data.line_gap = 20;
    data.max_lines = 5;
    data.font = "objective";
    data.font_scale = 1.0;
    data.hold_secs = 3.0;
    data.fade_secs = 0.5;
    data.next_id = 1;

    level.gg_debug_text = data;
    if (!isdefined(level.gg_debug_lines))
        level.gg_debug_lines = [];
    if (!isdefined(level.gg_debug_queue))
        level.gg_debug_queue = [];
    level.gg_debug_text_owner = self;

    self thread __gg_debug_hud_owner_watch();
}

__gg_debug_hud_owner_watch()
{
    self waittill("disconnect");

    if (isdefined(level.gg_debug_text_owner) && level.gg_debug_text_owner == self)
    {
        __gg_debug_hud_clear_lines();
        level.gg_debug_text = undefined;
        level.gg_debug_text_owner = undefined;
    }
}

__gg_debug_hud_clear_lines()
{
    if (!isdefined(level.gg_debug_lines))
        return;

    for (i = 0; i < level.gg_debug_lines.size; i++)
    {
        entry = level.gg_debug_lines[i];
        if (!isdefined(entry))
            continue;
        if (isdefined(entry.elem))
        {
            entry.elem notify("gg_debug_line_removed");
            entry.elem destroy();
        }
    }

    level.gg_debug_lines = [];
}

__gg_debug_hud_reflow_lines()
{
    if (!isdefined(level.gg_debug_text) || !isdefined(level.gg_debug_lines))
        return;

    base_x = level.gg_debug_text.base_x;
    base_y = level.gg_debug_text.base_y;
    gap = level.gg_debug_text.line_gap;

    count = level.gg_debug_lines.size;
    for (i = 0; i < count; i++)
    {
        entry = level.gg_debug_lines[i];
        if (!isdefined(entry) || !isdefined(entry.elem))
            continue;

        target_y = base_y - ((count - 1 - i) * gap);
        entry.elem.x = base_x;
        entry.elem.y = target_y;
    }
}

__gg_debug_hud_remove_line(elem, line_id)
{
    if (!isdefined(level.gg_debug_lines))
        return;

    removed = false;
    keep = [];
    for (i = 0; i < level.gg_debug_lines.size; i++)
    {
        entry = level.gg_debug_lines[i];
        if (!isdefined(entry))
            continue;

        if (!removed && isdefined(elem) && isdefined(entry.elem) && entry.elem == elem)
        {
            removed = true;
            continue;
        }

        if (!removed && isdefined(line_id) && isdefined(entry.id) && entry.id == line_id)
        {
            if (isdefined(entry.elem) && entry.elem != elem)
            {
                entry.elem notify("gg_debug_line_removed");
                entry.elem destroy();
            }
            removed = true;
            continue;
        }

        keep[keep.size] = entry;
    }

    if (removed)
    {
        level.gg_debug_lines = keep;
        __gg_debug_hud_reflow_lines();
    }
}

__gg_debug_hud_drop_oldest()
{
    if (!isdefined(level.gg_debug_lines) || level.gg_debug_lines.size <= 0)
        return;

    entry = level.gg_debug_lines[0];
    if (isdefined(entry) && isdefined(entry.elem))
    {
        entry.elem notify("gg_debug_line_removed");
        entry.elem destroy();
    }

    next = [];
    for (i = 1; i < level.gg_debug_lines.size; i++)
    {
        next[next.size] = level.gg_debug_lines[i];
    }

    level.gg_debug_lines = next;
    __gg_debug_hud_reflow_lines();
}

__gg_debug_hud_add_line(message)
{
    if (!isdefined(level.gg_debug_text))
        return;

    if (!isdefined(level.gg_debug_lines))
        level.gg_debug_lines = [];

    mgr = level.gg_debug_text;

    text = createFontString(mgr.font, 1.0);
    text.foreground = true;
    text.hidewheninmenu = true;
    text.alpha = 1;
    text.color = (1, 1, 0);
    text.sort = 45;
    text.alignX = "left";
    text.alignY = "top";
    text.horzAlign = "left";
    text.vertAlign = "top";
    text.fontScale = mgr.font_scale;
    text setPoint("LEFT", "TOP", mgr.base_x, mgr.base_y);
    text SetText(message);

    entry = spawnstruct();
    entry.elem = text;
    entry.id = mgr.next_id;
    entry.created = gettime();
    mgr.next_id += 1;

    level.gg_debug_lines[level.gg_debug_lines.size] = entry;
    __gg_debug_hud_reflow_lines();

    text thread __gg_debug_line_fade_thread(entry.id);

    if (level.gg_debug_lines.size > mgr.max_lines)
    {
        __gg_debug_hud_drop_oldest();
    }
}

__gg_debug_line_fade_thread(line_id)
{
    self endon("disconnect");
    self endon("gg_debug_line_removed");

    hold_secs = 3.0;
    fade_secs = 0.5;
    if (isdefined(level.gg_debug_text))
    {
        if (isdefined(level.gg_debug_text.hold_secs))
            hold_secs = level.gg_debug_text.hold_secs;
        if (isdefined(level.gg_debug_text.fade_secs))
            fade_secs = level.gg_debug_text.fade_secs;
    }

    wait(hold_secs);

    if (fade_secs > 0)
    {
        self FadeOverTime(fade_secs);
        wait(fade_secs);
    }

    self.alpha = 0;
    __gg_debug_hud_remove_line(self, line_id);
    self destroy();
}

__gg_debug_hud_process_queue()
{
    if (!isdefined(level.gg_debug_queue) || level.gg_debug_queue.size <= 0)
        return;

    while (level.gg_debug_queue.size > 0)
    {
        msg = __gg_debug_hud_dequeue();
        if (isdefined(msg))
        {
            __gg_debug_hud_add_line(msg);
        }
    }
}

__gg_debug_hud_dequeue()
{
    if (!isdefined(level.gg_debug_queue) || level.gg_debug_queue.size <= 0)
        return undefined;

    msg = level.gg_debug_queue[0];

    if (level.gg_debug_queue.size <= 1)
    {
        level.gg_debug_queue = [];
    }
    else
    {
        next = [];
        for (i = 1; i < level.gg_debug_queue.size; i++)
        {
            next[next.size] = level.gg_debug_queue[i];
        }
        level.gg_debug_queue = next;
    }

    return msg;
}

__gg_debug_hud_loop()
{
    self endon("disconnect");

    while (true)
    {
        // Show the debug HUD when explicitly requested, or when any logging mode is active
        dvar_on = (GetDvarInt("gg_debug_hud") != 0)
            || (GetDvarInt("gg_debug") != 0)
            || (GetDvarInt("gg_log_dispatch") != 0)
            || (GetDvarInt("gg_consume_logs") != 0);

        if (dvar_on)
        {
            if (!isdefined(level.gg_debug_text) || !isdefined(level.gg_debug_text_owner))
            {
                __gg_debug_hud_create();
            }

            if (isdefined(level.gg_debug_text_owner) && level.gg_debug_text_owner == self)
            {
                __gg_debug_hud_process_queue();
            }
        }
        else if (isdefined(level.gg_debug_text_owner) && level.gg_debug_text_owner == self)
        {
            __gg_debug_hud_clear_lines();
            if (isdefined(level.gg_debug_queue))
                level.gg_debug_queue = [];
        }

        wait(0.05);
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
    level.gb_hud.hide_tc_immediate = ::hide_tc_immediate;
    level.gb_hud.show_br = ::show_br;
    level.gb_hud.hide_br = ::hide_br;
    level.gb_hud.show_br_after_delay = ::show_br_after_delay;
    level.gb_hud.set_hint = ::set_hint;
    level.gb_hud.clear_hint = ::clear_hint;
    level.gb_hud.update_hint = ::update_hint;
    level.gb_hud.suppress_hint = ::suppress_hint;
    level.gb_hud.end_suppress_hint = ::end_suppress_hint;
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

    if (!isdefined(self.gg))
    {
        self.gg = spawnstruct();
    }

    if (!isdefined(self.gg.debug_hud_thread_started))
    {
        self.gg.debug_hud_thread_started = true;
        self thread __gg_debug_hud_loop();
    }

    // Idempotent: reuse if already built
    if (isdefined(self.gg.hud) && isdefined(self.gg.hud.tc_icon))
    {
        self.gg.hud thread __gg_apply_layout_thread();
        return;
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

show_tc(player, gum)
{
    if (!isdefined(player))
        return;
    player thread __gg_show_tc_impl(gum);
}

__gg_show_tc_impl(gum)
{
    self endon("disconnect");
    // removed endon("gg_gum_cleared") to ensure fades finish
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return;
    __gg_update_tc_impl(gum);

    __gg_tc_begin_show(gum);
    __gg_tc_start_fade(1);
}

hide_tc_after(player, secs, expected_name)
{
    if (!isdefined(player))
        return;
    expected_token = undefined;
    if (isdefined(player.gg) && isdefined(player.gg.tc_token))
        expected_token = player.gg.tc_token;
    player thread __gg_tc_hide_after(secs, expected_name, expected_token);
}

__gg_tc_hide_after(secs, expected_name, expected_token)
{
    self endon("disconnect");
    // removed endon("gg_gum_cleared") to ensure fades finish
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return;

    wait(0.05);
    if (isdefined(self.gg) && isdefined(self.gg.tc_token))
    {
        expected_token = self.gg.tc_token;
    }

    if (!isdefined(secs))
        secs = 0;
    if (secs > 0)
        wait(secs);

    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return;
    if (isdefined(expected_token) && (!isdefined(self.gg.tc_token) || self.gg.tc_token != expected_token))
        return;

    if (isdefined(expected_name) && expected_name != "")
    {
        current_name = "";
        if (isdefined(self.gg.tc_active_name))
            current_name = self.gg.tc_active_name;
        current_id = "";
        if (isdefined(self.gg.tc_active_id))
            current_id = self.gg.tc_active_id;
        if (expected_name != current_name && expected_name != current_id)
            return;
    }

    __gg_tc_start_fade(0);
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

    if (isdefined(self.gg.hud.tc_uses))
    {
        uses_text = "";
        if (isdefined(gum.uses_description))
            uses_text = gum.uses_description;
        __gg_set_text_if_changed(self, self.gg.hud.tc_uses, "tc_uses", uses_text);
        if (uses_text == "")
            self.gg.hud.tc_uses.alpha = 0;
        else
            self.gg.hud.tc_uses.alpha = __gg_tc_current_alpha();
    }

    if (isdefined(gum.desc))
        __gg_set_text_if_changed(self, self.gg.hud.tc_desc, "tc_desc", gum.desc);
}

hide_tc_immediate(player)
{
    if (!isdefined(player))
        return;
    player thread __gg_hide_tc_immediate_impl();
}

__gg_hide_tc_immediate_impl()
{
    self endon("disconnect");
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return;
    __gg_tc_invalidate_autohide();
    __gg_tc_apply_alpha(0);
    // Invalidate any in-flight TC fade so it can't re-raise alpha
    if (isdefined(self.gg.tc_fade_token))
        self.gg.tc_fade_token += 1;
    self.gg.tc_active_id = "";
    self.gg.tc_active_name = "";
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
    // removed endon("gg_gum_cleared") to ensure fades finish
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return;
    l = __gg_get_layout();
    if (isdefined(gum) && isdefined(gum.shader))
        __gg_set_shader_if_changed(self, self.gg.hud.br_icon, "br_icon", gum.shader, l.br_icon_size, l.br_icon_size);

    if (isdefined(self.gg.hud.br_hint))
        self.gg.hud.br_hint.color = (1, 1, 0);

    __gg_br_start_fade(1, false);
    __gg_br_update_width_from_state();
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
    // removed endon("gg_gum_cleared") to ensure fades finish
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return;

    if (!isdefined(self.gg.br_delay_token))
        self.gg.br_delay_token = 0;
    self.gg.br_delay_token += 1;

    __gg_br_start_fade(0, true);
}

show_br_after_delay(player, secs, expected_name)
{
    if (!isdefined(player))
        return;
    player thread __gg_br_after_delay_impl(secs, expected_name);
}

__gg_br_after_delay_impl(secs, expected_name)
{
    self endon("disconnect");
    // removed endon("gg_gum_cleared") to ensure fades finish

    if (!isdefined(self.gg))
        return;

    if (!isdefined(self.gg.br_delay_token))
        self.gg.br_delay_token = 0;
    self.gg.br_delay_token += 1;
    tok = self.gg.br_delay_token;

    if (!isdefined(secs))
        secs = 0;
    if (secs < 0)
        secs = 0;
    if (secs > 0)
        wait(secs);

    if (!isdefined(self.gg.br_delay_token) || self.gg.br_delay_token != tok)
        return;

    if (isdefined(expected_name) && expected_name != "")
    {
        current_name = "";
        if (isdefined(self.gg.selected_name))
            current_name = self.gg.selected_name;
        current_id = "";
        if (isdefined(self.gg.selected_id))
            current_id = self.gg.selected_id;
        if (expected_name != current_name && expected_name != current_id)
            return;
    }

    gum = undefined;
    if (isdefined(self.gg.br_pending_gum))
        gum = self.gg.br_pending_gum;
    if (!isdefined(gum) && isdefined(self.gg.br_pending_gum_id) && isdefined(level.gg_find_gum_by_id))
        gum = [[ level.gg_find_gum_by_id ]](self.gg.br_pending_gum_id);
    if (!isdefined(gum) && isdefined(self.gg.selected_id) && isdefined(level.gg_find_gum_by_id))
        gum = [[ level.gg_find_gum_by_id ]](self.gg.selected_id);

    if (!isdefined(gum))
        return;

    show_br(self, gum);
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
    if (!isdefined(player))
        return;
    player thread __gg_clear_hint_impl();
}

update_hint(player)
{
    if (!isdefined(player))
        return;
    player thread __gg_update_hint_impl();
}

suppress_hint(player, ms)
{
    if (!isdefined(player))
        return;
    player thread __gg_suppress_hint_impl(ms);
}

end_suppress_hint(player)
{
    if (!isdefined(player))
        return;
    player thread __gg_end_suppress_hint_impl();
}

__gg_set_hint_impl(text)
{
    self endon("disconnect");
    // removed endon("gg_gum_cleared") to ensure fades finish
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return;

    if (!isdefined(text))
        text = "";

    __gg_hint_store(text);

    if (__gg_hint_is_suppressed())
        return;

    __gg_hint_apply_text(text, 1);
}

__gg_clear_hint_impl()
{
    self endon("disconnect");
    // removed endon("gg_gum_cleared") to ensure fades finish
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return;

    __gg_hint_store("");
    __gg_hint_apply_text("", 0);
}

__gg_update_hint_impl()
{
    self endon("disconnect");
    // removed endon("gg_gum_cleared") to ensure fades finish
    if (!isdefined(self.gg) || !isdefined(self.gg.hud))
        return;

    text = "";
    if (isdefined(self.gg.hint_last_text))
        text = self.gg.hint_last_text;

    if (__gg_hint_is_suppressed())
        return;

    if (text == "")
        __gg_hint_apply_text("", 0);
    else
        __gg_hint_apply_text(text, 1);
}

__gg_suppress_hint_impl(ms)
{
    self endon("disconnect");
    // removed endon("gg_gum_cleared") to ensure fades finish
    if (!isdefined(self.gg))
        return;

    if (!isdefined(ms))
        ms = 0;
    if (ms < 0)
        ms = 0;

    until = gettime() + int(ms);
    self.gg.hint_suppressed_until = until;

    __gg_hint_hide_immediate();
}

__gg_end_suppress_hint_impl()
{
    self endon("disconnect");
    // removed endon("gg_gum_cleared") to ensure fades finish
    if (!isdefined(self.gg))
        return;

    self.gg.hint_suppressed_until = 0;
    __gg_update_hint_impl();
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

__gg_clamp01(value)
{
    if (!isdefined(value))
        return 0;
    if (value < 0)
        return 0;
    if (value > 1)
        return 1;
    return value;
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
    frac = 0;
    if (total > 0)
        frac = remaining * 1.0 / total;
    frac = __gg_clamp01(frac);
    w = int(__gg_br_base_width() * frac);
    if (isdefined(self.gg.hud.br_bar_fg))
        self.gg.hud.br_bar_fg SetShader("white", w, self.gg.hud.br_bar_fg.height);

    if (frac <= 0 && isdefined(st.mode) && (st.mode == "uses" || st.mode == "rounds"))
        __gg_br_start_fade(0, true);
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
    tick_ms = GetDvarInt("gg_timer_tick_ms");
    if (!isdefined(tick_ms) || tick_ms < 10)
        tick_ms = 100;
    // simple polling loop; idempotent via token
    while (true)
    {
        if (!isdefined(self.gg) || !isdefined(self.gg.hud))
            break;
        if (!isdefined(self.gg.hud.__br) || self.gg.hud.__br.token != tok)
            break;
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
        frac = __gg_clamp01(frac);
        w = int(base_w * frac);
        if (isdefined(self.gg.hud.br_bar_fg))
            self.gg.hud.br_bar_fg SetShader("white", w, self.gg.hud.br_bar_fg.height);
        wait(tick_ms / 1000.0);
    }

    // If the loop exits early (e.g. gum cleared), make sure the bar is fully drained.
    if (isdefined(self.gg) && isdefined(self.gg.hud))
    {
        if (isdefined(self.gg.hud.br_bar_fg))
            self.gg.hud.br_bar_fg SetShader("white", 0, self.gg.hud.br_bar_fg.height);
        if (isdefined(self.gg.hud.__br))
            self.gg.hud.__br.remaining = 0;
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

