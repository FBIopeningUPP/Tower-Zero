extends Node

signal floor_changed(floor: int)
signal draft_ready(card_count: int)
signal run_ended(final_floor: int, total_kills: int, total_shards: int)

var current_floor: int = 1
var total_kills: int = 0
var total_shards: int = 0
var drafted_cards: Array = []
var player_stats: Dictionary = {}

var active_weapon_primary: String = "Sword"
var active_weapon_secondary: String = "Blaster"
var unlocked_characters: Array = ["Default"]
var selected_character: String = "Default"
var permanent_upgrades: Dictionary = {}
var modifiers: Array = []
var modifier_multiplier: float = 1.0
var best_floor: int = 1
var total_runs: int = 0
var tutorial_completed: bool = false

var biome_colors: Dictionary = {
	"Office": Color(1.0, 0.95, 0.85),
	"Server": Color(0.6, 0.7, 1.0),
	"Lab": Color(0.7, 1.0, 0.7),
	"Foundry": Color(1.0, 0.6, 0.4),
	"Core": Color(0.5, 0.3, 0.7)
}

func _ready() -> void:
	_load_save()
	if player_stats.is_empty():
		_reset_player_stats_to_base()
		_apply_permanent_upgrades()
		_apply_character_passive()

func start_new_run() -> void:
	current_floor = 1
	total_kills = 0
	total_shards = 0
	drafted_cards.clear()
	_reset_player_stats_to_base()
	_apply_permanent_upgrades()
	_apply_character_passive()
	_apply_modifiers()
	emit_signal("floor_changed", current_floor)
	_save()

func _reset_player_stats_to_base() -> void:
	player_stats = {
		"max_hp": 100,
		"max_energy": 100,
		"sword_damage": 40,
		"blaster_damage": 20,
		"run_speed": 300,
		"jump_velocity": -400,
		"dash_speed": 800,
		"dash_duration": 0.2,
		"double_jumps": 1,
		"energy_per_kill": 0,
		"hp_per_kill": 0,
		"damage_reduction": 0.0
	}

func _apply_permanent_upgrades() -> void:
	for upgrade_id in permanent_upgrades.keys():
		var level = permanent_upgrades[upgrade_id]
		match upgrade_id:
			"starting_hp":
				player_stats["max_hp"] += [0, 25, 50, 100][level]
			"starting_energy":
				player_stats["max_energy"] += [0, 25, 50, 100][level]
			"sword_damage":
				player_stats["sword_damage"] += [0, 10, 20][level]
			"blaster_damage":
				player_stats["blaster_damage"] += [0, 5, 10][level]
			"dash_duration":
				player_stats["dash_duration"] += [0.0, 0.05, 0.1][level]
			"triple_jump":
				if level > 0:
					player_stats["double_jumps"] = 2

func _apply_character_passive() -> void:
	match selected_character:
		"Berserker":
			player_stats["sword_damage"] = int(player_stats["sword_damage"] * 1.5)
			player_stats["max_hp"] = int(player_stats["max_hp"] * 0.75)
		"Hacker":
			player_stats["max_energy"] = int(player_stats["max_energy"] * 1.5)
			player_stats["sword_damage"] = int(player_stats["sword_damage"] * 0.75)
			player_stats["energy_per_kill"] += 5
		"Ghost":
			player_stats["dash_speed"] = int(player_stats["dash_speed"] * 1.5)
			player_stats["dash_duration"] *= 2.0
			player_stats["max_hp"] = int(player_stats["max_hp"] * 0.5)

func _apply_modifiers() -> void:
	modifier_multiplier = 1.0
	for mod in modifiers:
		match mod:
			"glass_cannon":
				player_stats["sword_damage"] = int(player_stats["sword_damage"] * 2)
				player_stats["blaster_damage"] = int(player_stats["blaster_damage"] * 2)
				player_stats["max_hp"] = int(player_stats["max_hp"] * 0.5)
				modifier_multiplier *= 1.5
			"bullet_hell":
				modifier_multiplier *= 2.0
			"speedrun":
				modifier_multiplier *= 1.5
			"one_hit":
				player_stats["max_hp"] = 1
				modifier_multiplier *= 3.0
			"pacifist":
				player_stats["sword_damage"] = 0
				player_stats["energy_per_kill"] += 10
				modifier_multiplier *= 2.0

func advance_floor() -> void:
	current_floor += 1
	if current_floor > best_floor:
		best_floor = current_floor
	emit_signal("floor_changed", current_floor)
	_save()

func add_kill(xp: int) -> void:
	total_kills += 1
	total_shards += int(5 * modifier_multiplier)

func add_boss_kill() -> void:
	total_shards += int(50 * modifier_multiplier)

func add_drafted_card(card_data: Dictionary) -> void:
	drafted_cards.append(card_data)

func _apply_card_to_stats(card: Dictionary) -> void:
	var t = card.get("effect_type", "")
	var value = card.get("effect_value", 0)
	match t:
		"max_hp":
			player_stats["max_hp"] += int(value)
		"max_energy":
			player_stats["max_energy"] += int(value)
		"sword_damage":
			player_stats["sword_damage"] += int(value)
		"blaster_damage":
			player_stats["blaster_damage"] += int(value)
		"run_speed":
			player_stats["run_speed"] += value
		"jump_power":
			player_stats["jump_velocity"] -= value
		"dash_speed":
			player_stats["dash_speed"] += value
		"energy_per_kill":
			player_stats["energy_per_kill"] += value
		"hp_per_kill":
			player_stats["hp_per_kill"] += value
		"damage_reduction":
			player_stats["damage_reduction"] += value / 100.0
		"double_jump":
			player_stats["double_jumps"] += int(value)

func get_draft_card_count(hacking_result: int) -> int:
	match hacking_result:
		0: return 2
		1: return 3
		2: return 4
	return 3

func get_current_biome() -> String:
	if current_floor <= 3: return "Office"
	if current_floor <= 6: return "Server"
	if current_floor <= 9: return "Lab"
	if current_floor <= 12: return "Foundry"
	return "Core"

func get_biome_color() -> Color:
	return biome_colors.get(get_current_biome(), Color.WHITE)

func end_run() -> void:
	total_runs += 1
	emit_signal("run_ended", current_floor, total_kills, total_shards)
	_save()

func purchase_upgrade(upgrade_id: String) -> bool:
	var costs = {
		"starting_hp": [50, 100, 200],
		"starting_energy": [50, 100, 200],
		"sword_damage": [75, 150],
		"blaster_damage": [75, 150],
		"dash_duration": [100, 200],
		"triple_jump": [300],
		"head_start": [250],
		"card_pool_plus": [200]
	}
	var current_level = permanent_upgrades.get(upgrade_id, 0)
	if not costs.has(upgrade_id):
		return false
	if current_level >= costs[upgrade_id].size():
		return false
	var cost = costs[upgrade_id][current_level]
	if total_shards >= cost:
		total_shards -= cost
		permanent_upgrades[upgrade_id] = current_level + 1
		_save()
		return true
	return false

func unlock_character(character: String) -> void:
	if character not in unlocked_characters:
		unlocked_characters.append(character)
		_save()

func select_character(character: String) -> void:
	if character in unlocked_characters:
		selected_character = character
		_save()

func toggle_modifier(mod: String) -> void:
	if mod in modifiers:
		modifiers.erase(mod)
	else:
		modifiers.append(mod)
	_save()

func _save() -> void:
	var save_data = {
		"total_shards": total_shards,
		"upgrades_purchased": permanent_upgrades,
		"characters_unlocked": unlocked_characters,
		"best_floor": best_floor,
		"total_runs": total_runs,
		"selected_character": selected_character,
		"active_modifiers": modifiers,
		"tutorial_completed": tutorial_completed
	}
	var file = FileAccess.open("user://save.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))

func _load_save() -> void:
	var file = FileAccess.open("user://save.json", FileAccess.READ)
	if file:
		var text = file.get_as_text()
		var data = JSON.parse_string(text)
		if data and typeof(data) == TYPE_DICTIONARY:
			total_shards = data.get("total_shards", 0)
			permanent_upgrades = data.get("upgrades_purchased", {})
			unlocked_characters = data.get("characters_unlocked", ["Default"])
			best_floor = data.get("best_floor", 1)
			total_runs = data.get("total_runs", 0)
			selected_character = data.get("selected_character", "Default")
			modifiers = data.get("active_modifiers", [])
			tutorial_completed = data.get("tutorial_completed", false)
