extends Node
class_name EnemySpawner
@export var spawn_interval: float = 2
@export var max_enemies: int = 10
var enemy_scene: PackedScene = preload("res://entities/enemies/Enemy.tscn")
var drone_scene: PackedScene = preload("res://entities/enemies/Drone.tscn")
var spawn_timer: float = 0
var spawned_count: int = 0
var active: bool = false
func _ready() -> void:
	set_process(false)
func start_spawning(target_count: int) -> void:
	max_enemies = target_count
	spawned_count = 0
	active = true
	set_process(true)
	spawn_timer = 0
func stop_spawning() -> void:
	active = false
	set_process(false)
func _process(delta: float) -> void:
	if not active or spawned_count >= max_enemies:
		return
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0
		_spawn_enemy()
func _spawn_enemy() -> void:
	var scene = drone_scene if randf() < 0.3 else enemy_scene
	var enemy = scene.instantiate()
	get_parent().add_child(enemy)
	enemy.global_position = Vector2(randf_range(-2000, 2000), -500)
	spawned_count += 1
