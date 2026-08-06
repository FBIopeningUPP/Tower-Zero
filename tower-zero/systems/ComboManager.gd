extends Node

signal combo_updated(count: int, rank: String, multiplier: float)
signal combo_dropped

var combo_count: int = 0
var combo_timer: float = 0.0
var combo_window: float = 3.0

func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)

func _process(delta: float) -> void:
	if combo_count > 0:
		combo_timer -= delta                                                                                                                                                                                 
		if combo_timer <= 0:                                                                                                                                                                                 
			combo_count = 0                                                                                                                                                                                  
			combo_dropped.emit()                                                                                                                                                                             

func _on_enemy_died(base_xp: int) -> void:
	combo_count += 1
	combo_timer = combo_window

	var rank = get_rank()
	var mult = get_multiplier()

	RunState.modifier_multiplier = mult

	combo_updated.emit(combo_count, rank, mult)

func get_rank() -> String:
	if combo_count >= 20: return "SSS"
	if combo_count >= 15: return "S"
	if combo_count >= 10: return "A"
	if combo_count >= 6:  return "B"
	if combo_count >= 3:  return "C"
	return "D"

func get_multiplier() -> float:
	if combo_count >= 20: return 5.0
	if combo_count >= 15: return 3.0
	if combo_count >= 10: return 2.0
	if combo_count >= 6:  return 1.5
	if combo_count >= 3:  return 1.2
	return 1.0
