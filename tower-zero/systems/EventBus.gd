extends Node


signal player_health_changed(current, max_hp)
signal player_died
signal enemy_died(xp)
signal floor_cleared
signal hit_landed 

func _ready() -> void:
	hit_landed.connect(_on_hit_landed)

func _on_hit_landed() -> void:
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.05, true, false, true).timeout # ignore time scale
	Engine.time_scale = 1.0

signal enemy_damaged
signal player_energy_changed(current, max_energy)
