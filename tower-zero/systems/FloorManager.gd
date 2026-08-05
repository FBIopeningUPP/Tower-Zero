extends Node
class_name FloorManager

var current_floor: int = 1
var enemies_alive: int = 0
var floor_active: bool = false

var ground_enemy: PackedScene = preload("res://entities/enemies/Enemy.tscn")
var drone_enemy: PackedScene = preload("res://entities/enemies/Drone.tscn")

func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)

func start_floor() -> void:
	var count = 3 + (current_floor *2)
	enemies_alive = count
	floor_active = true
	for i in count:
		var scene = drone_enemy if randf() < 0.3 else ground_enemy
		var enemy = scene.instantiate()
		get_parent().add_child(enemy)
		enemy.global_position = Vector2(randf_range(-2000, 2000), -500)
	
func _on_enemy_died(_xp: int) -> void:
	if not floor_active:
		return
	enemies_alive -= 1
	if enemies_alive <= 0:
		enemies_alive = 0
		floor_active = false
		EventBus.floor_cleared.emit(current_floor)

func advance_floor() -> void:
	current_floor += 1
