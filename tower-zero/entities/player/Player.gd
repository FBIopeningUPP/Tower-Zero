extends CharacterBody2D
class_name Player
@export var run_speed: float = 300.0
@export var walk_speed: float = 120.0
@export var jump_velocity: float = -400.0
@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.2
@onready var weapon_manager: WeaponManager = $WeaponManager
@onready var hurtbox_collision: CollisionShape2D = $HurtboxComponent/CollisionShape2D
@onready var camera: Camera2D = $Camera2D
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var sword_hitbox: HitboxComponent = $SwordHitbox
@onready var katana_hitbox: HitboxComponent = $KatanaHitbox
@onready var hammer_hitbox: HitboxComponent = $HammerHitbox
@onready var daggers_hitbox: HitboxComponent = $DaggersHitbox
var game_over_scene = preload("res://scenes/ui/GameOverScreen.tscn")
var projectile_scene = preload("res://entities/projectiles/Projectile.tscn")
var damage_number_scene = preload("res://scenes/effects/DamageNumber.tscn")
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_double_jump: bool = false
var is_crouching: bool = false
var dash_timer: float = 0.0
var energy: int = 100
var max_energy: int = 100
var shake_strength: float = 0.0
var xp: int = 0
var level: int = 1
var xp_to_next_level: int = 50
enum State { NORMAL, DASHING }
var current_state: State = State.NORMAL
func _ready() -> void:
	add_to_group("player")
	sword_hitbox.get_node("CollisionShape2D").disabled = true
	katana_hitbox.get_node("CollisionShape2D").disabled = true
	hammer_hitbox.get_node("CollisionShape2D").disabled = true
	daggers_hitbox.get_node("CollisionShape2D").disabled = true
	sword_hitbox.get_node("CollisionShape2D").position = Vector2.ZERO
	katana_hitbox.get_node("CollisionShape2D").position = Vector2.ZERO
	hammer_hitbox.get_node("CollisionShape2D").position = Vector2.ZERO
	daggers_hitbox.get_node("CollisionShape2D").position = Vector2.ZERO
	if health_component:
		health_component.health_changed.connect(_on_health_changed)
		EventBus.player_energy_changed.emit(energy, max_energy)
	health_component.health_depleted.connect(_on_death)
	EventBus.enemy_damaged.connect(_on_enemy_damaged)
	EventBus.hit_landed.connect(func(): shake_strength = 15.0)
	EventBus.enemy_died.connect(_on_enemy_killed)
	var ui = game_over_scene.instantiate()
	add_child(ui)
	camera.zoom = Vector2(0.6, 0.6)
	camera.position_smoothing_enabled = true
func _on_enemy_damaged() -> void:
	energy = min(energy + 20, max_energy)
	EventBus.player_energy_changed.emit(energy, max_energy)
func _on_health_changed(current: int, max_hp: int) -> void:
	sprite.modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
	velocity.y = -300
	EventBus.player_health_changed.emit(current, max_hp)
func _physics_process(delta: float) -> void:
	match current_state:
		State.NORMAL:
			handle_normal_state(delta)
		State.DASHING:
			handle_dash_state(delta)
	move_and_slide()
	update_animations()
func handle_normal_state(delta: float) -> void:
	if Input.is_action_pressed("crouch"):
		is_crouching = true
		scale.y = 0.5
	else:
		is_crouching = false
		scale.y = 1.0
	if Input.is_action_just_pressed("dash"):
		start_dash()
		return
	if Input.is_action_just_pressed("attack"):
		weapon_manager.attack_melee()
	if Input.is_action_just_pressed("shoot"):
		weapon_manager.attack_ranged()
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var current_speed = walk_speed if Input.is_action_pressed("walk") else run_speed
	if is_crouching:
		current_speed = 0.0
	if input_dir != Vector2.ZERO:
		velocity = input_dir * current_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, current_speed)
func start_dash() -> void:
	var input_vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vec == Vector2.ZERO:
		input_vec = Vector2(sign(velocity.x) if velocity.x != 0 else 1.0, 0.0)
	velocity = input_vec.normalized() * dash_speed
	dash_timer = dash_duration
	current_state = State.DASHING
	scale.y = 1.0
	hurtbox_collision.set_deferred("disabled", true)
	sprite.modulate = Color.CYAN
func handle_dash_state(delta: float) -> void:
	dash_timer -= delta
	if dash_timer <= 0:
		velocity = velocity.move_toward(Vector2.ZERO, run_speed)
		current_state = State.NORMAL
		hurtbox_collision.set_deferred("disabled", false)
		sprite.modulate = Color.WHITE
func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0.0, 10 * delta)
		var offset_x = randf_range(-shake_strength, shake_strength)
		var offset_y = randf_range(-shake_strength, shake_strength)
		camera.offset = Vector2(offset_x, offset_y)
	else:
		camera.offset = Vector2.ZERO
	var mouse_dir = global_position.direction_to(get_global_mouse_position())
	var angle = mouse_dir.angle()
	var dist = 70.0
	var chest_offset = Vector2(0, -48)
	sword_hitbox.position = chest_offset + mouse_dir * dist
	sword_hitbox.rotation = angle
	katana_hitbox.position = chest_offset + mouse_dir * dist
	katana_hitbox.rotation = angle
	hammer_hitbox.position = chest_offset + mouse_dir * dist
	hammer_hitbox.rotation = angle
	daggers_hitbox.position = chest_offset + mouse_dir * (dist * 0.7)
	daggers_hitbox.rotation = angle
func _on_death() -> void:
	var ui = get_node("GameOverScreen")
	if ui:
		ui.show_death_screen()
func _on_enemy_killed(gained_xp: int) -> void:
	xp += int(gained_xp * RunState.modifier_multiplier * RunState.combo_multiplier)
	if xp >= xp_to_next_level:
		xp -= xp_to_next_level
		level += 1
		xp_to_next_level = int(xp_to_next_level * 1.5)
		max_energy += 25
		energy = max_energy
		EventBus.player_energy_changed.emit(energy, max_energy)
		health_component.current_health = health_component.max_health
		EventBus.player_health_changed.emit(health_component.current_health, health_component.max_health)
		var popup = damage_number_scene.instantiate()
		get_parent().add_child(popup)
		popup.global_position = self.global_position
		popup.setup("LEVEL UP!")
		popup.label.add_theme_color_override("font_color", Color.GOLD)
func update_animations() -> void:
	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir != 0:
		sprite.flip_h = input_dir < 0
	if sprite.animation == "slash" and sprite.is_playing():
		if sprite.frame >= 14:
			sprite.play("idle")
		else:
			return
	if current_state == State.DASHING:
		sprite.play("dash")
	elif input_dir != 0:
		sprite.play("run")
	else:
		sprite.play("idle")
