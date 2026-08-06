extends Node
class_name FloorManager

signal floor_cleared(floor_number: int)
signal floor_started(floor_number: int)
signal transition_to_safe_room(floor_number: int)
signal transition_to_combat(floor_number: int)

@export var base_enemy_count: int = 3
@export var enemies_per_floor: int = 2

var current_floor: int = 1
var enemies_alive: int = 0
var floor_active: bool = false

var enemy_pool: Array[PackedScene] = [
	preload("res://entities/enemies/Enemy.tscn"),
	preload("res://entities/enemies/Drone.tscn"),
	preload("res://entities/enemies/NinjaEnemy.tscn"),
	preload("res://entities/enemies/StrikerEnemy.tscn"),
	preload("res://entities/enemies/Galore/Bat.tscn"),
	preload("res://entities/enemies/Galore/Crab.tscn"),
	preload("res://entities/enemies/Galore/Golem.tscn"),
	preload("res://entities/enemies/Galore/Pebble.tscn"),
	preload("res://entities/enemies/Galore/Rat.tscn"),
	preload("res://entities/enemies/Galore/Skull.tscn"),
	preload("res://entities/enemies/Galore/Slime.tscn")
]

var room_pool: Array[PackedScene] = [
	preload("res://scenes/levels/rooms/Room1.tscn")
]
var current_room: Node2D = null

func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)

func start_floor() -> void:
	if floor_active:
		return
		
	if current_room:
		current_room.queue_free()
		
	var room_scene = room_pool.pick_random()
	current_room = room_scene.instantiate()
	get_parent().add_child(current_room)
	get_parent().move_child(current_room, 1) # Put it behind the player but in front of background
	
	var count = base_enemy_count + (current_floor - 1) * enemies_per_floor
	enemies_alive = count
	floor_active = true
	floor_started.emit(current_floor)
	
	var spawn_points = current_room.get_node_or_null("SpawnPoints")
	var spawners = []
	if spawn_points:
		spawners = spawn_points.get_children()
	
	for i in range(count):
		var scene = enemy_pool.pick_random()
		var enemy = scene.instantiate()
		get_parent().add_child(enemy)
		
		if spawners.size() > 0:
			var spawner = spawners[randi() % spawners.size()]
			enemy.global_position = spawner.global_position + Vector2(randf_range(-50, 50), -50)
		else:
			enemy.global_position = Vector2(randf_range(0, 1000), -500)

func _on_enemy_died(_xp: int) -> void:
	if not floor_active:
		return
	enemies_alive -= 1
	if enemies_alive <= 0:
		enemies_alive = 0
		floor_active = false
		floor_cleared.emit(current_floor)
		transition_to_safe_room.emit(current_floor)

func advance_floor() -> void:
	current_floor += 1
	RunState.advance_floor()
	transition_to_combat.emit(current_floor)

func get_current_floor() -> int:
	return current_floor