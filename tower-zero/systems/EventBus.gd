extends Node

signal player_health_changed(current, max_hp)
signal player_died
signal enemy_died(xp)
signal floor_cleared
signal hit_landed

func _ready() -> void:
	Engine.time_scale = 0
	await get_tree().create_timer(0.05, true, false, true).timeout
	Engine.time_scale = 1
