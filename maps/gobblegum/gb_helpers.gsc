#include maps\_utility;
#include common_scripts\utility;

gg_debug_on()
{
	return (GetDvarInt("gg_debug") == 1);
}

gg_debug_set_dvar_if_changed(name, value)
{
	if (!isdefined(name) || name == "")
		return;

	current = GetDvarInt(name);
	if (current != value)
		SetDvar(name, value);
}

gg_debug_clear_overlay_fallback()
{
	if (isdefined(level.gg_debug_lines))
	{
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

	level.gg_debug_text = undefined;
	level.gg_debug_text_owner = undefined;
	level.gg_debug_hud_refs = [];
}

gg_sync_debug_state()
{
	enabled = gg_debug_on();

	if (!isdefined(level.gg_state))
		level.gg_state = spawnstruct();

	level.gg_state.debug_enabled = enabled;

	if (isdefined(level.gg_config))
		level.gg_config.consume_logs = enabled;

	return enabled;
}

gg_debug_apply_state(enabled)
{
	value = 0;
	if (enabled)
		value = 1;

	gg_debug_set_dvar_if_changed("gg_debug_hud", value);
	gg_debug_set_dvar_if_changed("gg_log_dispatch", value);
	gg_debug_set_dvar_if_changed("gg_consume_logs", value);

	gg_sync_debug_state();

	if (!enabled)
	{
		if (isdefined(level.gb_hud) && isdefined(level.gb_hud.debug_teardown))
			[[ level.gb_hud.debug_teardown ]]();
		else
			gg_debug_clear_overlay_fallback();

		if (isdefined(level.gg_debug_queue))
			level.gg_debug_queue = [];

		if (isdefined(level.players) && isdefined(level.players.size)
			&& isdefined(level.gb_hud) && isdefined(level.gb_hud.clear_hint))
		{
			for (i = 0; i < level.players.size; i++)
			{
				player = level.players[i];
				if (!isdefined(player))
					continue;
				[[ level.gb_hud.clear_hint ]](player);
			}
		}
	}

	if (isdefined(level.gb_hud) && isdefined(level.gb_hud.on_debug_state_changed))
		[[ level.gb_hud.on_debug_state_changed ]](enabled);
}

gg_debug_watch_thread()
{
	last = undefined;

	while (true)
	{
		state = gg_debug_on();

		if (!isdefined(last) || state != last)
		{
			gg_debug_apply_state(state);
			last = state;
		}

		wait(0.1);
	}
}

gg_debug_queue_message(message)
{
	if (!isdefined(level.gg_debug_queue))
		level.gg_debug_queue = [];

	level.gg_debug_queue[level.gg_debug_queue.size] = message;

	max_queue = 16;
	if (level.gg_debug_queue.size > max_queue)
	{
		trim = [];
		start = level.gg_debug_queue.size - max_queue;
		for (i = start; i < level.gg_debug_queue.size; i++)
		{
			trim[trim.size] = level.gg_debug_queue[i];
		}
		level.gg_debug_queue = trim;
	}
}

gg_log(msg)
{
	if (!gg_debug_on())
		return;

	if (!isdefined(msg))
		msg = "";

	message = "[gg] " + msg;
	print(message);

	gg_debug_queue_message(message);
}

// Literal-return helpers (constants)
ACT_AUTO() { return 1; }
ACT_USER() { return 2; }
CONS_TIMED() { return 1; }
CONS_ROUNDS() { return 2; }
CONS_USES() { return 3; }
GG_TC_AUTOHIDE_SECS() { return 7.5; }
GG_HUD_FADE_SECS() { return 0.25; }
GG_FADE_SECS() { return GG_HUD_FADE_SECS(); }
GG_BR_DELAYED_SHOW_SECS() { return 1.5; }
GG_ARMED_GRACE_SECS() { return 3.0; }

helpers_array_contains(arr, value)
{
	if (!isdefined(arr))
		return false;
	for (i = 0; i < arr.size; i++)
	{
		if (arr[i] == value)
			return true;
	}
	return false;
}

normalize_mapname(name)
{
	if (!isdefined(name) || name == "")
		return "";

	lower = tolower(name);
	if (!isdefined(lower) || lower == "")
		return "";

	if (lower == "cosmodrome" || lower == "zm_cosmodrome")
		return "zombie_cosmodrome";

	if (lower == "coast" || lower == "zm_coast" || lower == "shangri_la")
		return "zombie_coast";

	if (lower == "kino" || lower == "kino_der_toten" || lower == "theater" || lower == "zm_theater")
		return "zombie_theater";

	if (lower == "moon" || lower == "zm_moon")
		return "zombie_moon";

	return lower;
}

get_current_mapname()
{
	name = undefined;
	if (isdefined(level.script))
	{
		name = level.script;
	}
	if (!isdefined(name) || name == "")
	{
		name = GetDvar("mapname");
	}
	return normalize_mapname(name);
}

// Returns true for features supported by the current map.
// Step 1: only special-case "death_machine" on cosmodrome/coast/moon.
map_allows(feature)
{
	if (!isdefined(feature))
		return true;

	if (feature == "death_machine")
	{
		name = get_current_mapname();
		if (!isdefined(name))
			return false;

		// Allow-list: cosmodrome (Ascension), coast (Shangri-La), moon
		if (name == "zombie_cosmodrome"
			|| name == "zombie_coast"
			|| name == "zombie_moon")
		{
			return true;
		}
		return false;
	}

	// Default allow for other features in Step 1
	return true;
}

map_allows_death_machine()
{
	return map_allows("death_machine");
}

is_cosmodrome()
{
	name = get_current_mapname();
	if (!isdefined(name))
		return false;
	return (name == "zombie_cosmodrome");
}

get_map_perk_list()
{
	if (isdefined(level.gb_helpers) && isdefined(level.gb_helpers.map_perk_cache))
		return level.gb_helpers.map_perk_cache;

	perks = [];

	triggers = GetEntArray("zombie_vending", "targetname");
	if (!isdefined(triggers))
		triggers = [];

	for (i = 0; i < triggers.size; i++)
	{
		trig = triggers[i];
		if (!isdefined(trig) || !isdefined(trig.script_noteworthy))
			continue;

		perk = trig.script_noteworthy;
		if (!isdefined(perk) || perk == "")
			continue;

		if (!helpers_array_contains(perks, perk))
			perks[perks.size] = perk;
	}

	if (isdefined(level.gb_helpers))
		level.gb_helpers.map_perk_cache = perks;

	return perks;
}

get_all_perk_list()
{
	if (isdefined(level.gb_helpers) && isdefined(level.gb_helpers.all_perk_cache))
		return level.gb_helpers.all_perk_cache;

	perks = [];
	perks[perks.size] = "specialty_armorvest";
	perks[perks.size] = "specialty_quickrevive";
	perks[perks.size] = "specialty_fastreload";
	perks[perks.size] = "specialty_rof";
	perks[perks.size] = "specialty_longersprint";
	perks[perks.size] = "specialty_flakjacket";
	perks[perks.size] = "specialty_deadshot";
	perks[perks.size] = "specialty_additionalprimaryweapon";

	if (isdefined(level.gb_helpers))
		level.gb_helpers.all_perk_cache = perks;

	return perks;
}

map_has_mulekick_machine()
{
	perks = get_map_perk_list();
	return helpers_array_contains(perks, "specialty_additionalprimaryweapon");
}

mulekick_safe_without_machine()
{
	if (!isdefined(level))
		return false;

	if (isdefined(level.zombiemode_using_additionalprimaryweapon_perk) && is_true(level.zombiemode_using_additionalprimaryweapon_perk))
		return true;

	if (isdefined(level.zombie_additionalprimaryweapon_machine_origin))
		return true;

	return false;
}

// Stubs (Step 1)
get_wonder_pool(map)
{
	pool = [];

	if (!isdefined(map) || map == "")
		map = get_current_mapname();

	if (!isdefined(level) || !isdefined(level.zombie_weapons))
		return pool;

	aliases = spawnstruct();
	aliases["scavenger_zm"] = "sniper_explosive_zm";
	aliases["human_gun_zm"] = "humangun_zm";

	candidates = [];
	candidates[candidates.size] = "ray_gun_zm";
	candidates[candidates.size] = "tesla_gun_zm";
	candidates[candidates.size] = "thundergun_zm";
	candidates[candidates.size] = "freezegun_zm";
	candidates[candidates.size] = "scavenger_zm";
	candidates[candidates.size] = "shrink_ray_zm";
	candidates[candidates.size] = "human_gun_zm";
	candidates[candidates.size] = "humangun_zm";
	candidates[candidates.size] = "microwavegundw_zm";

	for (i = 0; i < candidates.size; i++)
	{
		name = candidates[i];
		if (!isdefined(name) || name == "")
			continue;

		resolved = name;
		if (isdefined(aliases[name]))
			resolved = aliases[name];

		if (!isdefined(level.zombie_weapons[resolved]))
			continue;
		if (!isdefined(level.zombie_weapons[resolved].is_in_box) || !level.zombie_weapons[resolved].is_in_box)
			continue;
		already = false;
		for (j = 0; j < pool.size; j++)
		{
			if (pool[j] == resolved)
			{
				already = true;
				break;
			}
		}
		if (!already)
			pool[pool.size] = resolved;
	}

	if (GetDvarInt("gg_wonder_include_specials") != 0)
	{
		specials = [];
		specials[0] = "zombie_black_hole_bomb";
		specials[1] = "zombie_quantum_bomb";
		for (i = 0; i < specials.size; i++)
		{
			special = specials[i];
			if (!isdefined(special) || special == "")
				continue;
			if (!isdefined(level.zombie_weapons[special]))
				continue;
			if (!isdefined(level.zombie_weapons[special].is_in_box) || !level.zombie_weapons[special].is_in_box)
				continue;
			already = false;
			for (j = 0; j < pool.size; j++)
			{
				if (pool[j] == special)
				{
					already = true;
					break;
				}
			}
			if (!already)
				pool[pool.size] = special;
		}
	}

	return pool;
}

get_weapon_display_name(weapon)
{
	if (!isdefined(weapon) || weapon == "")
		return "";

	if (!isdefined(level) || !isdefined(level.zombie_weapons) || !isdefined(level.zombie_weapons[weapon]))
		return weapon;

	if (isdefined(level.zombie_weapons[weapon].hint) && level.zombie_weapons[weapon].hint != "")
		return level.zombie_weapons[weapon].hint;

	return weapon;
}

upgrade_weapon(player, base)
{
	if (!isdefined(player) || !isdefined(base) || base == "")
	{
		return false;
	}

	if (!isdefined(level.zombie_weapons) || !isdefined(level.zombie_weapons[base]))
	{
		return false;
	}

	if (!isdefined(level.zombie_weapons[base].upgrade_name))
	{
		// No upgrade path known for this weapon.
		return false;
	}

	upgrade = level.zombie_weapons[base].upgrade_name;
	if (!isdefined(upgrade) || upgrade == "")
	{
		return false;
	}

	if (player maps\_zombiemode_weapons::is_weapon_upgraded(base) || player HasWeapon(upgrade))
	{
		// Already upgraded; nothing to do.
		return true;
	}

	had_base = (player HasWeapon(base));
	success = false;

	if (isdefined(level.zombie_weapons[upgrade]))
	{
		options = player maps\_zombiemode_weapons::get_pack_a_punch_weapon_options(upgrade);

		if (isdefined(options))
		{
			player GiveWeapon(upgrade, 0, options);
		}
		else
		{
			helpers_upgrade_debug("Using basic GiveWeapon for " + upgrade);
			player GiveWeapon(upgrade);
		}

		success = player HasWeapon(upgrade);

		if (!success && had_base && !(player HasWeapon(base)))
		{
			player GiveWeapon(base);
			player GiveStartAmmo(base);
			maps\_zombiemode_weapons::acquire_weapon_toggle(base, player);
		}
	}

	if (!success)
	{
		return upgrade_weapon_fallback(player, base, upgrade);
	}

	if (had_base && player HasWeapon(base))
	{
		player TakeWeapon(base);
		maps\_zombiemode_weapons::unacquire_weapon_toggle(base);
	}

	player GiveStartAmmo(upgrade);
	maps\_zombiemode_weapons::acquire_weapon_toggle(upgrade, player);
	player SwitchToWeapon(upgrade);
	player maps\_zombiemode_weapons::play_weapon_vo(upgrade);
	player notify("pap_taken");
	player.pap_used = true;

	return true;
}

upgrade_weapon_fallback(player, base, upgrade)
{
	helpers_upgrade_debug("Fallback upgrade path for " + base);

	if (!isdefined(upgrade) || upgrade == "")
		return false;

	had_base = false;
	if (player HasWeapon(base))
	{
		had_base = true;
		player TakeWeapon(base);
		maps\_zombiemode_weapons::unacquire_weapon_toggle(base);
	}

	player GiveWeapon(upgrade);
	player GiveStartAmmo(upgrade);
	maps\_zombiemode_weapons::acquire_weapon_toggle(upgrade, player);
	player SwitchToWeapon(upgrade);
	player notify("pap_taken");
	player.pap_used = true;

	return had_base || (player HasWeapon(upgrade));
}

helpers_upgrade_debug(msg)
{
	if (!gg_debug_on())
		return;
	if (!isdefined(msg) || msg == "")
		msg = "upgrade debug";
	gg_log("upgrade: " + msg);
}

player_has_all_map_perks(player)
{
	if (!isdefined(player))
		return false;

	perks = get_map_perk_list();
	if (!isdefined(perks) || perks.size <= 0)
		return true;

	for (i = 0; i < perks.size; i++)
	{
		perk = perks[i];
		if (!isdefined(perk) || perk == "")
			continue;
		if (!(player HasPerk(perk)))
			return false;
	}

	return true;
}

trigger_perk_vo_if_cosmodrome(player, perk)
{
	if (!is_cosmodrome())
		return false;

	if (!isdefined(level))
		return false;

	invoked = false;
	if (isdefined(level.perk_bought_func) && isdefined(player) && isdefined(perk) && perk != "")
	{
		player [[ level.perk_bought_func ]](perk);
		invoked = true;
	}

	previously_set = false;
	if (isdefined(level.perk_bought) && level.perk_bought)
		previously_set = true;

	level.perk_bought = true;

	if (isdefined(level.flag_set))
	{
		[[ level.flag_set ]]("perk_bought");
	}
	else
	{
		flag_set("perk_bought");
	}

	if (gg_debug_on())
	{
		name = get_current_mapname();
		if (!isdefined(name) || name == "")
			name = "unknown_map";

		label = "perk_bought flag set";
		if (previously_set)
			label = "perk_bought flag reassert";

		if (invoked)
			label = label + ", perk_bought_func invoked";

		gg_log("cosmodrome perk vo: " + label + " (" + name + ")");
	}

	return true;
}

helpers_init()
{
	if (isdefined(level.gb_helpers))
	{
		return;
	}

	level.gb_helpers = spawnstruct();
	level.gb_helpers.map_allows = ::map_allows;
	level.gb_helpers.is_cosmodrome = ::is_cosmodrome;
	level.gb_helpers.normalize_mapname = ::normalize_mapname;
	level.gb_helpers.get_current_mapname = ::get_current_mapname;
	level.gb_helpers.get_map_perk_list = ::get_map_perk_list;
	level.gb_helpers.get_all_perk_list = ::get_all_perk_list;
	level.gb_helpers.map_has_mulekick_machine = ::map_has_mulekick_machine;
	level.gb_helpers.mulekick_safe_without_machine = ::mulekick_safe_without_machine;
	level.gb_helpers.get_wonder_pool = ::get_wonder_pool;
	level.gb_helpers.get_weapon_display_name = ::get_weapon_display_name;
	level.gb_helpers.upgrade_weapon = ::upgrade_weapon;
	level.gb_helpers.player_has_all_map_perks = ::player_has_all_map_perks;
	level.gb_helpers.trigger_perk_vo_if_cosmodrome = ::trigger_perk_vo_if_cosmodrome;
	level.gb_helpers.gg_log = ::gg_log;
	level.gb_helpers.gg_debug_on = ::gg_debug_on;
	level.gb_helpers.gg_sync_debug_state = ::gg_sync_debug_state;

	level.gb_helpers.ACT_AUTO = ::ACT_AUTO;
	level.gb_helpers.ACT_USER = ::ACT_USER;
	level.gb_helpers.CONS_TIMED = ::CONS_TIMED;
	level.gb_helpers.CONS_ROUNDS = ::CONS_ROUNDS;
	level.gb_helpers.CONS_USES = ::CONS_USES;
	level.gb_helpers.GG_TC_AUTOHIDE_SECS = ::GG_TC_AUTOHIDE_SECS;
	level.gb_helpers.GG_HUD_FADE_SECS = ::GG_HUD_FADE_SECS;
	level.gb_helpers.GG_FADE_SECS = ::GG_FADE_SECS;
	level.gb_helpers.GG_BR_DELAYED_SHOW_SECS = ::GG_BR_DELAYED_SHOW_SECS;
	level.gb_helpers.GG_ARMED_GRACE_SECS = ::GG_ARMED_GRACE_SECS;
	level.gb_helpers.map_allows_death_machine = ::map_allows_death_machine;

	if (!isdefined(level.gg_debug_watch_started))
	{
		level.gg_debug_watch_started = true;
		gg_debug_apply_state(gg_debug_on());
		level thread gg_debug_watch_thread();
	}
}

gg_powerup_single_drop(player, gum)
{
	gum_id = "<unknown>";
	if (isdefined(gum) && isdefined(gum.id))
		gum_id = gum.id;

	code = gg_powerup_code_for_gum(gum);
	if (!isdefined(code) || code == "")
	{
		if (gg_debug_on())
			[[ level.gb_helpers.gg_log ]]("dispatch: power-up alias missing for " + gum_id);

		gg_mark_activation_skip(player);
		return false;
	}

	if (!gg_spawn_powerup_for_gum(player, gum, code))
	{
		if (gg_debug_on())
			[[ level.gb_helpers.gg_log ]]("dispatch: power-up spawn failed for " + gum_id);

		gg_mark_activation_skip(player);
		return false;
	}

	return true;
}

gg_powerup_code_for_gum(gum)
{
	id = undefined;
	if (isdefined(gum))
	{
		if (isstring(gum))
		{
			id = gum;
		}
		else if (isdefined(gum.id))
		{
			id = gum.id;
		}
	}
	return gg_powerup_code_for_id(id);
}

gg_spawn_powerup_for_gum(player, gum, code)
{
	if (!isdefined(code) || code == "")
		return false;

	if (code == "bonus_points_player")
	{
		ensured = maps\gobblegum\gumballs::gg_require_powerup("bonus_points_player");
		if (!ensured)
		{
			attempts = 0;
			while (attempts < 3)
			{
				wait(0.05);
				if (maps\gobblegum\gumballs::gg_require_powerup_now("bonus_points_player"))
				{
					ensured = true;
					break;
				}
				attempts++;
			}

			if (!ensured)
			{
				if (gg_debug_on())
					[[ level.gb_helpers.gg_log ]]("dispatch: power-up registration pending for bonus_points_player");
				return false;
			}
		}
	}

	gum_id = "<unknown>";
	if (isdefined(gum) && isdefined(gum.id))
		gum_id = gum.id;

	return gg_spawn_and_track_powerup(player, gum_id, code, 0, true);
}

gg_mark_activation_skip(player)
{
	if (!isdefined(player))
		return;

	if (!isdefined(player.gg))
		maps\gobblegum\gumballs::build_player_state(player);

	player.gg.skip_activation_consume_once = true;
}

gg_spawn_and_track_powerup(player, gum_id, code, fan_offset, show_hint, pos_override)
{
	success = undefined;
	if (isdefined(pos_override))
		success = maps\gobblegum\gumballs::gg_spawn_powerup_drop_at(player, code, pos_override);
	else
		success = maps\gobblegum\gumballs::gg_spawn_powerup_drop(player, code, fan_offset);

	if (!success)
		return false;

	maps\gobblegum\gumballs::gg_log_powerup_spawn(gum_id, code);

	if (isdefined(show_hint) && show_hint)
		gg_show_powerup_hint(player, maps\gobblegum\gumballs::gg_powerup_label_for_code(code));

	return true;
}

gg_can_spawn_death_machine()
{
	if (!isdefined(level.gb_helpers))
		return true;
	if (isdefined(level.gb_helpers.map_allows_death_machine))
		return [[ level.gb_helpers.map_allows_death_machine ]]();
	if (isdefined(level.gb_helpers.map_allows))
		return [[ level.gb_helpers.map_allows ]]("death_machine");
	return true;
}

gg_collect_reign_drop_codes()
{
	codes = [];
	ids = [];

	ids[ids.size] = "whos_keeping_score";     // Double Points
	ids[ids.size] = "kill_joy";               // Insta-Kill
	if (gg_reigndrops_include_firesale())
		ids[ids.size] = "immolation";        // Fire Sale (optional)
	ids[ids.size] = "dead_of_nuclear_winter"; // Nuke
	ids[ids.size] = "licensed_contractor";    // Carpenter
	ids[ids.size] = "cache_back";             // Max Ammo
	ids[ids.size] = "on_the_house";           // Free Perk
	ids[ids.size] = "extra_credit";           // Bonus Points
	if (gg_can_spawn_death_machine())
		ids[ids.size] = "fatal_contraption"; // Death Machine (map-gated)

	for (i = 0; i < ids.size; i++)
	{
		alias_id = ids[i];
		if (!isdefined(alias_id) || alias_id == "")
			continue;

		code = gg_powerup_code_for_id(alias_id);
		if (!isdefined(code) || code == "")
		{
			if (gg_debug_on())
				[[ level.gb_helpers.gg_log ]]("dispatch: reign drops alias missing for " + alias_id);
			continue;
		}

		if (!maps\gobblegum\gumballs::gg_array_contains(codes, code))
			codes[codes.size] = code;
	}

	return codes;
}

gg_reigndrops_include_firesale()
{
	if (isdefined(level.gg_config) && isdefined(level.gg_config.reigndrops_include_firesale))
		return level.gg_config.reigndrops_include_firesale;
	return true;
}

gg_powerup_code_for_id(id)
{
	maps\gobblegum\gumballs::gg_init_powerup_tables();
	if (!isdefined(id) || id == "")
		return undefined;

	// Try alias table first
	if (isdefined(level.gg_powerup_alias) && isdefined(level.gg_powerup_alias[id]))
		return level.gg_powerup_alias[id];

	// Fallback: known id -> code mapping, and populate alias for future calls
	code = undefined;
	switch (id)
	{
	case "dead_of_nuclear_winter": code = "nuke"; break;
	case "kill_joy": code = "insta_kill"; break;
	case "whos_keeping_score": code = "double_points"; break;
	case "licensed_contractor": code = "carpenter"; break;
	case "cache_back": code = "full_ammo"; break;
	case "immolation": code = "fire_sale"; break;
	case "on_the_house": code = "free_perk"; break;
	case "fatal_contraption": code = "minigun"; break;
	case "extra_credit": code = "bonus_points_player"; break;
	}

	if (isdefined(code) && code != "")
	{
		if (!isdefined(level.gg_powerup_alias))
			level.gg_powerup_alias = spawnstruct();
		level.gg_powerup_alias[id] = code;
		return code;
	}

	return undefined;
}

gg_spawn_reign_drop_sequence(player, gum, codes)
{
	if (!isdefined(player) || !isdefined(codes) || codes.size <= 0)
		return false;

	if (!isdefined(player.gg))
		maps\gobblegum\gumballs::build_player_state(player);

	gum_id = "<unknown>";
	if (isdefined(gum) && isdefined(gum.id))
		gum_id = gum.id;

	spacing = maps\gobblegum\gumballs::gg_get_reigndrops_spacing_secs();
	if (spacing < 0)
		spacing = 0;

	if (!isdefined(player.gg.reign_drops_token))
		player.gg.reign_drops_token = 0;
	player.gg.reign_drops_token += 1;
	token = player.gg.reign_drops_token;

	player thread maps\gobblegum\gumballs::gg_reign_drop_sequence_thread(gum_id, codes, spacing, token);
	return true;
}

gg_wonderbar_suppress_label(player, duration)
{
	if (!isdefined(player))
		return;

	if (!isdefined(player.gg))
		maps\gobblegum\gumballs::build_player_state(player);

	suppress_secs = duration;
	if (!isdefined(suppress_secs) || suppress_secs <= 0)
		suppress_secs = maps\gobblegum\gumballs::gg_get_wonder_label_suppress_ms() / 1000.0;

	if (!isdefined(player.gg.wonderbar_suppress_until))
		player.gg.wonderbar_suppress_until = 0;

	suppress_ms = int(suppress_secs * 1000);
	if (suppress_ms < 0)
		suppress_ms = 0;

	player.gg.wonderbar_suppress_until = gettime() + suppress_ms;

	if (suppress_ms > 0 && isdefined(level.gb_hud) && isdefined(level.gb_hud.suppress_hint))
		[[ level.gb_hud.suppress_hint ]](player, suppress_ms);

	if (maps\gobblegum\gumballs::gg_debug_enabled())
		[[ level.gb_helpers.gg_log ]]("wonderbar label suppressed for " + suppress_secs + "s");
}

gg_apply_upgrade_for_weapon(player, weapon)
{
	if (!isdefined(level.gb_helpers) || !isdefined(level.gb_helpers.upgrade_weapon))
		return false;
	return [[ level.gb_helpers.upgrade_weapon ]](player, weapon);
}

gg_weapon_has_upgrade(weapon)
{
	if (!isdefined(weapon) || weapon == "" || !isdefined(level.zombie_weapons))
		return false;

	if (!isdefined(level.zombie_weapons[weapon]))
		return false;

	if (!isdefined(level.zombie_weapons[weapon].upgrade_name))
		return false;

	upgrade = level.zombie_weapons[weapon].upgrade_name;
	return (isdefined(upgrade) && upgrade != "");
}

gg_weapon_is_spawn_pistol(weapon)
{
	return (weapon == "m1911_zm");
}

gg_weapon_is_wall_buy(weapon)
{
	if (!isdefined(weapon) || weapon == "" || !isdefined(level.zombie_weapons))
		return false;

	if (!isdefined(level.zombie_weapons[weapon]))
		return false;

	info = level.zombie_weapons[weapon];

	is_box_weapon = false;
	if (isdefined(info.is_in_box))
		is_box_weapon = info.is_in_box;
	else if (isdefined(maps\_zombiemode_weapons::get_is_in_box))
		is_box_weapon = maps\_zombiemode_weapons::get_is_in_box(weapon);

	if (is_box_weapon)
		return false;

	if (isdefined(info.cost) && info.cost > 0)
		return true;

	if (isdefined(info.ammo_cost) && info.ammo_cost > 0)
		return true;

	if (isdefined(maps\_zombiemode_weapons::get_weapon_toggle))
	{
		toggle = maps\_zombiemode_weapons::get_weapon_toggle(weapon);
		if (isdefined(toggle))
			return true;
	}

	if (isdefined(info.hint) && info.hint != "")
		return true;

	return false;
}

gg_weapon_is_box_weapon(weapon)
{
	if (!isdefined(weapon) || weapon == "" || !isdefined(level.zombie_weapons))
		return false;

	if (!isdefined(level.zombie_weapons[weapon]))
		return false;

	return maps\_zombiemode_weapons::get_is_in_box(weapon);
}

gg_clone_array(arr)
{
	clone = [];
	if (!isdefined(arr))
		return clone;
	for (i = 0; i < arr.size; i++)
	{
		clone[i] = arr[i];
	}
	return clone;
}

gg_get_primary_weapons(player)
{
	if (!isdefined(player))
		return [];

	weapons = player GetWeaponsListPrimaries();
	if (!isdefined(weapons))
		weapons = [];
	return weapons;
}

gg_detect_new_weapon(prev, curr)
{
	if (!isdefined(curr))
		return undefined;

	for (i = 0; i < curr.size; i++)
	{
		weapon = curr[i];
		if (!isdefined(weapon) || weapon == "" || weapon == "none")
			continue;
		if (!maps\gobblegum\gumballs::gg_array_contains(prev, weapon))
			return weapon;
	}

	return undefined;
}

gg_show_powerup_hint(player, text, raw)
{
	if (!isdefined(player))
		return;

	if (!maps\gobblegum\gumballs::gg_powerup_hints_enabled())
		return;

	if (!isdefined(text) || text == "")
		text = "Power-Up";

	msg = text;
	if (!isdefined(raw) || !raw)
		msg = "Spawned: " + text;

	if (isdefined(level.gb_hud) && isdefined(level.gb_hud.set_hint))
		[[ level.gb_hud.set_hint ]](player, msg);
}

gg_show_hint_if_enabled(player, text)
{
	if (!isdefined(player))
		return;

	if (!isdefined(text) || text == "")
	{
		if (isdefined(level.gb_hud) && isdefined(level.gb_hud.clear_hint))
			[[ level.gb_hud.clear_hint ]](player);
		return;
	}

	if (!maps\gobblegum\gumballs::gg_debug_enabled())
	{
		if (isdefined(level.gb_hud) && isdefined(level.gb_hud.clear_hint))
			[[ level.gb_hud.clear_hint ]](player);
		return;
	}

	if (!maps\gobblegum\gumballs::gg_powerup_hints_enabled())
		return;

	if (isdefined(level.gb_hud) && isdefined(level.gb_hud.set_hint))
		[[ level.gb_hud.set_hint ]](player, text);
}

gg_end_current_gum(player, reason)
{
	if (!isdefined(player) || !isdefined(player.gg))
		return;

	if (maps\gobblegum\gumballs::gg_consume_logs_enabled() && isdefined(reason))
		[[ level.gb_helpers.gg_log ]]("consumption: ending gum (" + reason + ")");

	// keep TC autohide window
	maps\gobblegum\gumballs::gg_selection_close(player, reason, false, true);
	maps\gobblegum\gumballs::gg_set_effect_state(player, undefined, false);

	if (isdefined(level.gb_hud) && isdefined(level.gb_hud.br_stop_timer))
		[[ level.gb_hud.br_stop_timer ]](player);

	if (isdefined(level.gb_hud) && isdefined(level.gb_hud.hide_br))
		[[ level.gb_hud.hide_br ]](player);

	if (isdefined(level.gb_hud) && isdefined(level.gb_hud.clear_hint))
		[[ level.gb_hud.clear_hint ]](player);

	player.gg.is_active = false;
	player.gg.uses_remaining = 0;
	player.gg.rounds_remaining = 0;
	player.gg.timer_endtime = 0;
	player.gg.used_this_round = false;
	player.gg.active_token += 1;

	if (isdefined(player.gg) && isdefined(player.gg.armed_flags))
	{
		player.gg.armed_flags.wall = false;
		player.gg.armed_flags.crate = false;
		player.gg.armed_flags.crate_power_active = false;
		player.gg.armed_flags.wonder = false;
		player.gg.armed_flags.wonderbar_active = false;
	}

	if (isdefined(player.gg))
	{
		player.gg.crate_power_armed_time = 0;
		player.gg.armed_since = 0;
		player.gg.wonderbar_armed_time = 0;
		player.gg.wonderbar_choice = undefined;
		player.gg.wonderbar_label_text = "";
		player.gg.wonderbar_suppress_until = 0;
	}

	player notify("gg_wall_power_cancel");
	player notify("gg_crate_power_cancel");
	player notify("gg_wonderbar_cancel");

	player notify("gg_wonderbar_end");

	player.gg.selected_id = undefined;
	player.gg.selection_active = false;

	player notify("gg_gum_cleared");
}

gg_on_gum_used() {}

gg_effect_stub_common(player, gum, category)
{
	if (!isdefined(player) || !isdefined(gum))
		return;

	gum_id = "<unknown>";
	if (isdefined(gum.id))
		gum_id = gum.id;

	gum_name = gum_id;
	if (isdefined(gum.name) && gum.name != "")
		gum_name = gum.name;

	if (maps\gobblegum\gumballs::gg_log_dispatch_enabled())
	{
		[[ level.gb_helpers.gg_log ]]("dispatch: effect stub [" + category + "] -> " + gum_id);
	}

	if (!maps\gobblegum\gumballs::gg_simulate_effects_enabled())
		return;

	gg_show_hint_if_enabled(player, "Activated: " + gum_name);
}

gg_powerup_fan_offset(index, total)
{
	if (!isdefined(index) || !isdefined(total) || total <= 1)
		return 0;

	spread = 30.0;
	mid = (total - 1) * 0.5;
	return (index - mid) * spread;
}

gg_spawn_firesale_test_drop(player)
{
	if (!isdefined(player))
		return;

	if (!isdefined(player.origin) || !isdefined(player.angles))
		return;

	if (!maps\gobblegum\gumballs::gg_test_drop_firesale_enabled())
		return;

	if (maps\gobblegum\gumballs::gg_spawn_powerup_drop(player, "fire_sale", 0))
	{
		if (maps\gobblegum\gumballs::gg_debug_enabled())
			[[ level.gb_helpers.gg_log ]]("test fire sale drop spawned");
	}
}
