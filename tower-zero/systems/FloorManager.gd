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
var current_room: Node2D = null
var arena_width: float = 2000.0
var arena_height: float = 1200.0
var top_wall: StaticBody2D
var bot_wall: StaticBody2D
var left_wall: StaticBody2D
var right_wall: StaticBody2D
func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)
	_build_initial_arena()
func _build_initial_arena() -> void:
	current_room = Node2D.new()
	current_room.name = "Arena"
	get_parent().call_deferred("add_child", current_room)
	get_parent().call_deferred("move_child", current_room, 1)
	top_wall = _create_wall(Vector2(arena_width, 200))
	bot_wall = _create_wall(Vector2(arena_width, 200))
	left_wall = _create_wall(Vector2(200, arena_height))
	right_wall = _create_wall(Vector2(200, arena_height))
	_position_walls(true)
	_spawn_obstacles(10, 0, 0)
func _create_wall(size: Vector2) -> StaticBody2D:
	var wall = StaticBody2D.new()
	wall.collision_layer = 2
	var shape = CollisionShape2D.new()
	shape.name = "CollisionShape2D"
	var rect = RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	wall.add_child(shape)
	var vis = ColorRect.new()
	vis.name = "ColorRect"
	vis.size = size
	vis.position = -size / 2
	vis.color = Color(0.1, 0.1, 0.15, 1)
	wall.add_child(vis)
	current_room.add_child(wall)
	return wall
func _position_walls(is_initial: bool = false) -> void:
	top_wall.get_node("CollisionShape2D").shape.size = Vector2(arena_width + 400, 200)
	top_wall.get_node("ColorRect").size = Vector2(arena_width + 400, 200)
	top_wall.get_node("ColorRect").position = -Vector2(arena_width + 400, 200) / 2
	bot_wall.get_node("CollisionShape2D").shape.size = Vector2(arena_width + 400, 200)
	bot_wall.get_node("ColorRect").size = Vector2(arena_width + 400, 200)
	bot_wall.get_node("ColorRect").position = -Vector2(arena_width + 400, 200) / 2
	left_wall.get_node("CollisionShape2D").shape.size = Vector2(200, arena_height)
	left_wall.get_node("ColorRect").size = Vector2(200, arena_height)
	left_wall.get_node("ColorRect").position = -Vector2(200, arena_height) / 2
	right_wall.get_node("CollisionShape2D").shape.size = Vector2(200, arena_height)
	right_wall.get_node("ColorRect").size = Vector2(200, arena_height)
	right_wall.get_node("ColorRect").position = -Vector2(200, arena_height) / 2
	var top_pos = Vector2(0, -arena_height/2 - 100)
	var bot_pos = Vector2(0, arena_height/2 + 100)
	var left_pos = Vector2(-arena_width/2 - 100, 0)
	var right_pos = Vector2(arena_width/2 + 100, 0)
	if is_initial:
		top_wall.position = top_pos
		bot_wall.position = bot_pos
		left_wall.position = left_pos
		right_wall.position = right_pos
	else:
		var tween = get_tree().create_tween().set_parallel(true)
		tween.tween_property(top_wall, "position", top_pos, 1.0)
		tween.tween_property(bot_wall, "position", bot_pos, 1.0)
		tween.tween_property(left_wall, "position", left_pos, 1.0)
		tween.tween_property(right_wall, "position", right_pos, 1.0)
var _spawned_obstacle_positions = []
func _spawn_obstacles(amount: int, min_dist: float, max_dist: float) -> void:
	for i in range(amount):
		var pos = Vector2.ZERO
		var valid = false
		var attempts = 0
		while not valid and attempts < 50:
			attempts += 1
			pos.x = randf_range(-arena_width/2 + 200, arena_width/2 - 200)
			pos.y = randf_range(-arena_height/2 + 200, arena_height/2 - 200)
			valid = true
			if min_dist == 0 and max_dist == 0:
				if pos.length() < 500: valid = false
			else:
				var max_x = (arena_width/2) - 200
				var max_y = (arena_height/2) - 200
				var min_x = max_x - 300
				var min_y = max_y - 300
				if abs(pos.x) <= min_x and abs(pos.y) <= min_y:
					valid = false
			if valid:
				for other_pos in _spawned_obstacle_positions:
					if pos.distance_to(other_pos) < 250:
						valid = false
						break
		if not valid:
			continue
		_spawned_obstacle_positions.append(pos)
		var obs = StaticBody2D.new()
		obs.collision_layer = 2
		obs.position = pos
		var w_size = randf_range(60, 120)
		var h_size = randf_range(60, 120)
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
		obs.scale = Vector2.ZERO
		var tween = get_tree().create_tween()
		tween.tween_property(obs, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK)
func start_floor() -> void:
	if floor_active: return
	if current_floor > 1:
		arena_width += 600
		arena_height += 600
		_position_walls()
		_spawn_obstacles(6, arena_width/2 - 300, arena_width/2)
	if current_floor == 5:
		var scene = preload("res://entities/enemies/Galore/Golem.tscn")
		var boss = scene.instantiate()
		get_parent().add_child(boss)
		boss.scale = Vector2(3.0, 3.0)
		if boss.has_node("HealthComponent"):
			boss.get_node("HealthComponent").max_health = 1000
			boss.get_node("HealthComponent").current_health = 1000
		var pos = Vector2.ZERO
		while pos.length() < 600:
			pos.x = randf_range(-arena_width/2 + 100, arena_width/2 - 100)
			pos.y = randf_range(-arena_height/2 + 100, arena_height/2 - 100)
		boss.global_position = pos
		enemies_alive = 1
		floor_active = true
		floor_started.emit(current_floor)
	else:
		var count = base_enemy_count + (current_floor * enemies_per_floor)
		enemies_alive = count
		floor_active = true
		floor_started.emit(current_floor)
		for i in range(count):
			var scene = enemy_pool.pick_random()
			var enemy = scene.instantiate()
			get_parent().add_child(enemy)
			var pos = Vector2.ZERO
			while pos.length() < 600:
				pos.x = randf_range(-arena_width/2 + 100, arena_width/2 - 100)
				pos.y = randf_range(-arena_height/2 + 100, arena_height/2 - 100)
			enemy.global_position = pos
			enemy.modulate.a = 0
			get_tree().create_tween().tween_property(enemy, "modulate:a", 1.0, 1.0)
func _on_enemy_died(_xp: int) -> void:
	if not floor_active: return
	enemies_alive -= 1
	if enemies_alive <= 0:
		enemies_alive = 0
		floor_active = false
		floor_cleared.emit(current_floor)
		if current_floor >= 5:
			var victory_scene = preload("res://scenes/ui/VictoryScreen.tscn")
			var vic = victory_scene.instantiate()
			var canvas = CanvasLayer.new()
			canvas.add_child(vic)
			get_tree().current_scene.add_child(canvas)
			return
		var draft_scene = preload("res://scenes/ui/UpgradeDraft.tscn")
		var draft = draft_scene.instantiate()
		var canvas = CanvasLayer.new()
		canvas.add_child(draft)
		get_tree().current_scene.add_child(canvas)
		draft.upgrade_selected.connect(func():
			canvas.queue_free()
			advance_floor()
			start_floor()
		)
func advance_floor() -> void:
	current_floor += 1
	RunState.advance_floor()
	transition_to_combat.emit(current_floor)
func get_current_floor() -> int:
	return current_floor
