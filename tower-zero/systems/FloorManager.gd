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
		
	# Phase D: Procedural Map Generation!
	current_room = Node2D.new()
	current_room.name = "ProceduralRoom"
	get_parent().add_child(current_room)
	get_parent().move_child(current_room, 1) # Put it behind the player
	
	var width = 2400.0
	var height = 1400.0
	
	# Generate 4 outer walls
	var walls = [
		{"pos": Vector2(0, -height/2), "size": Vector2(width, 100)}, # Top
		{"pos": Vector2(0, height/2), "size": Vector2(width, 100)}, # Bottom
		{"pos": Vector2(-width/2, 0), "size": Vector2(100, height)}, # Left
		{"pos": Vector2(width/2, 0), "size": Vector2(100, height)} # Right
	]
	
	for w in walls:
		var wall = StaticBody2D.new()
		wall.collision_layer = 2 # Environment layer
		wall.position = w["pos"]
		
		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = w["size"]
		shape.shape = rect
		wall.add_child(shape)
		current_room.add_child(wall)
		
	# Generate random internal obstacles (pillars, crates, servers)
	var num_obstacles = 15 + (current_floor * 2)
	for i in range(num_obstacles):
		var pos = Vector2.ZERO
		# Keep a safe zone in the center for the player to spawn
		while pos.length() < 400:
			pos.x = randf_range(-width/2 + 200, width/2 - 200)
			pos.y = randf_range(-height/2 + 200, height/2 - 200)
			
		var obs = StaticBody2D.new()
		obs.collision_layer = 2
		obs.position = pos
		
		var w_size = randf_range(80, 250)
		var h_size = randf_range(80, 250)
		
		var vis = ColorRect.new()
		vis.size = Vector2(w_size, h_size)
		vis.position = -vis.size / 2
		vis.color = RunState.get_biome_color().darkened(0.6)
		obs.add_child(vis)
		
		var o_shape = CollisionShape2D.new()
		var o_rect = RectangleShape2D.new()
		o_rect.size = vis.size
		o_shape.shape = o_rect
		obs.add_child(o_shape)
		
		current_room.add_child(obs)
		
	# Spawn Spike Traps!
	var trap_scene = preload("res://scenes/objects/SpikeTrap.tscn")
	var num_traps = 5 + (current_floor * 2) # More traps on higher floors
	for i in range(num_traps):
		var pos = Vector2.ZERO
		while pos.length() < 500: # Keep traps further away from spawn
			pos.x = randf_range(-width/2 + 200, width/2 - 200)
			pos.y = randf_range(-height/2 + 200, height/2 - 200)
			
		var trap = trap_scene.instantiate()
		trap.position = pos
		current_room.add_child(trap)
	
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
			# If no hardcoded spawners, spawn anywhere in the procedural bounds!
			# We use the width and height of our procedural room (2400x1400)
			# But keep them away from the exact center (0,0) where the player is.
			var pos = Vector2.ZERO
			while pos.length() < 400:
				pos.x = randf_range(-1100, 1100)
				pos.y = randf_range(-600, 600)
			enemy.global_position = pos

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