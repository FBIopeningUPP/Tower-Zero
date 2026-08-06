extends Node
class_name ComboManager

signal combo_updated(count: int, rank: String, multiplier: float)
signal combo_dropped

var combo_count: int = 0
var combo_timer: float = 0
var combo_window: float = 3

func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)
