extends Node
signal player_health_changed(current, max_hp)
signal player_died
signal enemy_died(xp)
signal floor_cleared(floor_number: int)
signal floor_started(floor_number: int)
signal hit_landed
signal next_floor_requested
signal door_entered
signal enemy_damaged
signal player_energy_changed(current, max_energy)
func _ready() -> void:
	pass
func _on_hit_landed() -> void:
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.05).timeout
	Engine.time_scale = 1.0
