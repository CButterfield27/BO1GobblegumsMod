#include maps\_utility;
#include common_scripts\utility;
#include maps\_zombiemode_utility;
#include maps\gobblegum\gb_helpers;
#include maps\gobblegum\gumballs;

gg_fx_perkaholic(player, gum)
{
    if (!isdefined(player))
        return;

    context = gg_perkaholic_resolve_targets();
    perks = context.perks;
    missing = gg_perkaholic_missing_perks(player, perks);

    if (!isdefined(missing) || missing.size <= 0)
    {
        gg_mark_activation_skip(player);
        if (gg_debug_enabled())
            [[ level.gb_helpers.gg_log ]]("perkaholic skipped: no missing perks");
        gg_show_hint_if_enabled(player, "Perkaholic: all perks acquired");
        return;
    }

    grant_list = gg_perkaholic_normalize_list(missing);

    if (grant_list.size <= 0)
    {
        gg_mark_activation_skip(player);
        if (gg_debug_enabled())
            [[ level.gb_helpers.gg_log ]]("perkaholic skipped: no eligible perks");
        gg_show_hint_if_enabled(player, "Perkaholic: all perks acquired");
        return;
    }

    if (gg_debug_enabled())
    {
        resolved_label = gg_perkaholic_format_list(perks);
        missing_label = gg_perkaholic_format_list(grant_list);
        mulekick_state = "off";
        grant_all_flag = 0;
        include_flag = 0;
        has_machine_flag = 0;
        mulekick_safe_flag = 0;
        if (context.grant_all)
            grant_all_flag = 1;
        if (context.include_mulekick)
            include_flag = 1;
        if (context.map_has_mulekick_machine)
            has_machine_flag = 1;
        if (context.mulekick_safe_to_grant)
            mulekick_safe_flag = 1;
        if (context.include_mulekick)
        {
            mulekick_state = "missing";
            if (context.mulekick_present)
                mulekick_state = "included";
            if (context.mulekick_removed_for_safety)
                mulekick_state = "suppressed";
        }

        log_msg = "perkaholic resolve: grant_all=" + grant_all_flag;
        log_msg = log_msg + ", include_mulekick=" + include_flag;
        log_msg = log_msg + ", map_has_mulekick=" + has_machine_flag;
        log_msg = log_msg + ", mulekick_safe=" + mulekick_safe_flag;
        log_msg = log_msg + ", resolved=" + resolved_label;
        log_msg = log_msg + ", to_grant=" + missing_label;
        log_msg = log_msg + ", mulekick_state=" + mulekick_state;
        [[ level.gb_helpers.gg_log ]](log_msg);

        if (context.mulekick_removed_for_safety)
            [[ level.gb_helpers.gg_log ]]("perkaholic warning: mule kick excluded (no safe machine/token)");
    }

    gg_perkaholic_begin_bypass(player);

    if (gg_debug_enabled())
        [[ level.gb_helpers.gg_log ]]("perkaholic granting " + grant_list.size + " perks (missing=" + missing.size + ")");

    delay = gg_get_perkaholic_grant_delay_secs();

    granted = 0;
    granted_perks = [];
    for (i = 0; i < grant_list.size; i++)
    {
        perk = grant_list[i];
        if (!isdefined(perk) || perk == "")
            continue;

        if (player HasPerk(perk))
            continue;

        player maps\_zombiemode_perks::give_perk(perk);

        gg_perkaholic_trigger_vo_helper(player, perk);

        if (gg_debug_enabled())
            [[ level.gb_helpers.gg_log ]]("perkaholic granted " + perk);

        granted++;
        granted_perks[granted_perks.size] = perk;

        if (delay > 0 && i < grant_list.size - 1)
            wait(delay);
    }

    gg_perkaholic_end_bypass(player);

    if (gg_debug_enabled())
    {
        granted_label = gg_perkaholic_format_list(granted_perks);
        [[ level.gb_helpers.gg_log ]]("perkaholic grant complete (granted=" + granted + ", bypass=1, final=" + granted_label + ")");
    }

    if (granted <= 0)
    {
        gg_mark_activation_skip(player);
        if (gg_debug_enabled())
            [[ level.gb_helpers.gg_log ]]("perkaholic skipped: grant blocked");
        gg_show_hint_if_enabled(player, "Perkaholic: perk grant failed");
        return;
    }

    gg_show_hint_if_enabled(player, "Applied: Perkaholic");
}

gg_perkaholic_include_mulekick_enabled()
{
    if (isdefined(level.gg_config) && isdefined(level.gg_config.perkaholic_include_mulekick))
        return level.gg_config.perkaholic_include_mulekick;
    return true;
}

gg_perkaholic_grant_all_enabled()
{
    if (isdefined(level.gg_config) && isdefined(level.gg_config.perkaholic_grant_all_perks))
        return level.gg_config.perkaholic_grant_all_perks;
    return true;
}

gg_perkaholic_normalize_list(perks)
{
    normalized = [];
    if (!isdefined(perks))
        return normalized;

    for (i = 0; i < perks.size; i++)
    {
        perk = perks[i];
        if (!isdefined(perk) || perk == "")
            continue;
        if (!gg_array_contains(normalized, perk))
            normalized[normalized.size] = perk;
    }

    return normalized;
}

gg_perkaholic_remove_perk(perks, perk_name)
{
    filtered = [];
    if (!isdefined(perks))
        return filtered;

    for (i = 0; i < perks.size; i++)
    {
        perk = perks[i];
        if (!isdefined(perk) || perk == "")
            continue;
        if (perk == perk_name)
            continue;
        filtered[filtered.size] = perk;
    }

    return filtered;
}

gg_perkaholic_ensure_perk(perks, perk_name)
{
    if (!isdefined(perks))
        perks = [];

    if (!gg_array_contains(perks, perk_name))
        perks[perks.size] = perk_name;

    return perks;
}

gg_perkaholic_format_list(perks)
{
    if (!isdefined(perks) || perks.size <= 0)
        return "[]";

    label = "[";
    for (i = 0; i < perks.size; i++)
    {
        perk = perks[i];
        if (i > 0)
            label = label + ", ";
        if (!isdefined(perk))
            perk = "undefined";
        label = label + perk;
    }

    label = label + "]";
    return label;
}

gg_perkaholic_resolve_targets()
{
    context = spawnstruct();
    context.perks = [];
    context.grant_all = gg_perkaholic_grant_all_enabled();
    context.include_mulekick = gg_perkaholic_include_mulekick_enabled();
    context.map_has_mulekick_machine = false;
    context.mulekick_safe_without_machine = false;
    context.mulekick_safe_to_grant = false;
    context.mulekick_removed_for_safety = false;
    context.mulekick_present = false;

    base = [];
    if (context.grant_all)
    {
        if (isdefined(level.gb_helpers) && isdefined(level.gb_helpers.get_all_perk_list))
            base = gg_clone_array([[ level.gb_helpers.get_all_perk_list ]]());
    }
    else
    {
        if (isdefined(level.gb_helpers) && isdefined(level.gb_helpers.get_map_perk_list))
            base = gg_clone_array([[ level.gb_helpers.get_map_perk_list ]]());
    }

    base = gg_perkaholic_normalize_list(base);

    if (isdefined(level.gb_helpers))
    {
        if (isdefined(level.gb_helpers.map_has_mulekick_machine))
            context.map_has_mulekick_machine = [[ level.gb_helpers.map_has_mulekick_machine ]]();
        if (isdefined(level.gb_helpers.mulekick_safe_without_machine))
            context.mulekick_safe_without_machine = [[ level.gb_helpers.mulekick_safe_without_machine ]]();
    }

    mulekick = "specialty_additionalprimaryweapon";

    if (!context.include_mulekick)
    {
        base = gg_perkaholic_remove_perk(base, mulekick);
    }
    else
    {
        safe = context.map_has_mulekick_machine;
        if (!safe && context.mulekick_safe_without_machine)
            safe = true;

        context.mulekick_safe_to_grant = safe;

        if (!safe)
        {
            if (gg_array_contains(base, mulekick))
                base = gg_perkaholic_remove_perk(base, mulekick);
            context.mulekick_removed_for_safety = true;
        }
        else
        {
            base = gg_perkaholic_ensure_perk(base, mulekick);
        }
    }

    context.perks = base;
    context.mulekick_present = gg_array_contains(context.perks, mulekick);

    return context;
}

gg_perkaholic_missing_perks(player, perks)
{
    missing = [];
    if (!isdefined(perks))
        perks = [];

    for (i = 0; i < perks.size; i++)
    {
        perk = perks[i];
        if (!isdefined(perk) || perk == "")
            continue;
        if (isdefined(player) && (player HasPerk(perk)))
            continue;
        if (!gg_array_contains(missing, perk))
            missing[missing.size] = perk;
    }

    return missing;
}

gg_perkaholic_slots_available(player)
{
    cap = gg_get_perk_cap();
    if (cap <= 0)
        return 12;

    current = gg_get_player_perk_count(player);
    room = cap - current;
    if (room < 0)
        room = 0;
    return room;
}

gg_perkaholic_begin_bypass(player)
{
    if (!isdefined(player))
        return;

    if (!isdefined(player.gg_perk_cap_bypass_depth))
        player.gg_perk_cap_bypass_depth = 0;

    player.gg_perk_cap_bypass_depth += 1;
    player.gg_perk_cap_bypass = true;

    if (gg_debug_enabled() && player.gg_perk_cap_bypass_depth == 1)
        [[ level.gb_helpers.gg_log ]]("perkaholic: perk cap bypass enabled");
}

gg_perkaholic_end_bypass(player)
{
    if (!isdefined(player))
        return;

    if (!isdefined(player.gg_perk_cap_bypass_depth))
        player.gg_perk_cap_bypass_depth = 0;

    player.gg_perk_cap_bypass_depth -= 1;
    if (player.gg_perk_cap_bypass_depth > 0)
        return;

    player.gg_perk_cap_bypass = undefined;
    player.gg_perk_cap_bypass_depth = undefined;

    if (gg_debug_enabled())
        [[ level.gb_helpers.gg_log ]]("perkaholic: perk cap bypass cleared");
}

gg_perkaholic_trigger_vo_helper(player, perk)
{
    if (!isdefined(level.gb_helpers) || !isdefined(level.gb_helpers.trigger_perk_vo_if_cosmodrome))
        return false;
    return [[ level.gb_helpers.trigger_perk_vo_if_cosmodrome ]](player, perk);
}
