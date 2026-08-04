extends Node2D

@export var enemy_scene: PackedScene = preload("res://entities/enemies/Enemy.tscn")
@export var spawn_interval: float = 3

func _ready() -> void:
	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(timer)

func _on_spawn_timer_timeout() -> void:
	if enemy_scene:
		var enemy = enemy_scene.instantiate()
		get_parent().add_child(enemy)
		enemy.global_position = self.global_position
