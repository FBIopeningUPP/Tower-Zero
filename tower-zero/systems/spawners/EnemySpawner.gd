extends Node2D

@export var ground_enemy: PackedScene = preload("res://entities/enemies/Enemy.tscn")
@export var drone_enemy: PackedScene = preload("res://entities/enemies/Drone.tscn")
@export var boss_enemy: PackedScene = preload("res://entities/enemies/Boss.tscn")
@export var starting_spawn_interval: float = 3.0
@export var minimum_spawn_interval: float = 0.5 

var current_interval: float
var timer: Timer
var kill_count: int = 0
var boss_spawned: bool = false

func _ready() -> void:
	current_interval = starting_spawn_interval
	
	timer = Timer.new()
	timer.wait_time = current_interval
	timer.autostart = true
	timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(timer)
	
	EventBus.enemy_died.connect(_on_enemy_died)
	
func _on_enemy_died(xp: int) -> void:
	current_interval = max(current_interval * 0.98, minimum_spawn_interval)
	timer.wait_time = current_interval
	
	kill_count += 1
	if kill_count == 50 and not boss_spawned:
		boss_spawned = true
		var boss = boss_enemy.instantiate()
		get_parent().add_child(boss)
		boss.global_position = self.global_position

func _on_spawn_timer_timeout() -> void:
	var scene_to_spawn = ground_enemy
	
	if randf() > 0.5:
		scene_to_spawn = drone_enemy
		
	if scene_to_spawn:
		var enemy = scene_to_spawn.instantiate()
		get_parent().add_child(enemy)
		
		# Add a random offset so they don't spawn perfectly inside each other!
		var random_offset = Vector2(randf_range(-100, 100), randf_range(-50, 50))
		enemy.global_position = self.global_position + random_offset
