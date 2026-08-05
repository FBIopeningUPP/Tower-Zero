extends Node2D

@export var ground_enemy: PackedScene = preload("res://entities/enemies/Enemy.tscn")
@export var drone_enemy: PackedScene = preload("res://entities/enemies/Drone.tscn")
@export var boss_enemy: PackedScene = preload("res://entities/enemies/Boss.tscn")

var floor_manager: FloorManager = null
var enemies_to_spawn: int = 0
var spawn_timer: Timer

func _ready() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 1.5
	spawn_timer.autostart = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	
func start_spawning(fm: FloorManager) -> void:
	floor_manager = fm
	enemies_to_spawn = fm.get_enemy_count_for_floor(fm.current_floor)
	spawn_timer.start()

func stop_spawning() -> void:
	spawn_timer.stop()
	enemies_to_spawn = 0

func _on_spawn_timer_timeout() -> void:
	if enemies_to_spawn <= 0:
		spawn_timer.stop()
		return
	
	var scene_to_spawn = ground_enemy
	var drone_chance = min(0.1 + (floor_manager.current_floor + 0.05), 0.6)
	if randf() < drone_chance:
		scene_to_spawn = drone_enemy
		
	var enemy = scene_to_spawn.instantiate()
	get_parent().add_child(enemy)
	var random_offset = Vector2(randf_range(-200, 200), randf_range(-50, 50))
	enemy.global_position = self.global_position + random_offset
	
	enemies_to_spawn -= 1
