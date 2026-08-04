extends Node2D

@export var enemy_scene: PackedScene = preload("res://entities/enemies/Enemy.tscn")
@export var ground_enemy: PackedScene = preload("res://entities/enemies/Enemy.tscn")
@export var drone_enemy: PackedScene = preload("res://entities/enemies/Drone.tscn")
@export var spawn_interval: float = 3

func _ready() -> void:
	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(timer)

func _on_spawn_timer_timeout() -> void:
	var scene_to_spawn = ground_enemy
	
	if randf() > 0.5:
		scene_to_spawn = drone_enemy
		
	if scene_to_spawn:
		var enemy = scene_to_spawn.instantiate()
		get_parent().add_child(enemy)
		enemy.global_position = self.global_position
