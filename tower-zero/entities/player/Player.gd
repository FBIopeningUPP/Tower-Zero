extends CharacterBody2D
class_name Player

@export var run_speed: float = 300.0
@export var walk_speed: float = 120.0
@export var jump_velocity: float = -400.0
@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.2

@onready var hurtbox_collision: CollisionShape2D = $HurtboxComponent/CollisionShape2D

var game_over_scene = preload("res://scenes/ui/GameOverScreen.tscn")
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_double_jump: bool = false
var is_crouching: bool = false
var dash_timer: float = 0.0
var energy: int = 100
var max_energy: int = 100
var shake_strength: float = 0
@onready var camera: Camera2D = $Camera2D

enum State { NORMAL, DASHING }
var current_state: State = State.NORMAL

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var sword_hitbox: Area2D = $SwordHitbox

var projectile_scene = preload("res://entities/projectiles/Projectile.tscn")

func _ready() -> void:
	if health_component:
		health_component.health_changed.connect(_on_health_changed)
		EventBus.player_energy_changed.emit(energy, max_energy)
	
	EventBus.enemy_damaged.connect(_on_enemy_damaged)
	EventBus.hit_landed.connect(func(): shake_strength = 15.0)
	
	health_component.health_depleted.connect(_on_death)
	
	var ui = game_over_scene.instantiate()
	add_child(ui)

func _on_enemy_damaged() -> void:
	energy = min(energy + 20, max_energy)
	EventBus.player_energy_changed.emit(energy, max_energy)

func _on_health_changed(current: int, max_hp: int) -> void:
	sprite.modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
	
	velocity.y = -300
	
	print("OUCH! Player HP: ", current, "/", max_hp)
	EventBus.player_health_changed.emit(current, max_hp)

func _physics_process(delta: float) -> void:
	match current_state:
		State.NORMAL:
			handle_normal_state(delta)
		State.DASHING:
			handle_dash_state(delta)
	
	move_and_slide()

func handle_normal_state(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		can_double_jump = true

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_velocity
		elif can_double_jump:
			velocity.y = jump_velocity
			can_double_jump = false

	if Input.is_action_pressed("crouch") and is_on_floor():
		is_crouching = true
		scale.y = 0.5
	else:
		is_crouching = false
		scale.y = 1.0

	if Input.is_action_just_pressed("dash"):
		start_dash()
		return
	
	if Input.is_action_just_pressed("attack"):
		sword_hitbox.get_node("CollisionShape2D").set_deferred("disabled", false)
		get_tree().create_timer(0.1).timeout.connect(func(): sword_hitbox.get_node("CollisionShape2D").set_deferred("disabled", true))
		print("Swung Sword!")
		
	if Input.is_action_just_pressed("shoot"):
		print("SHOOT PRESSED! Energy: ", energy, "/", max_energy)
		if energy >= 25:
			energy -= 25
			EventBus.player_energy_changed.emit(energy, max_energy)
			
			print("PEW! Fired Blaster! Energy remaining: ", energy)
			
			var proj = projectile_scene.instantiate()
			get_parent().add_child(proj)
			proj.global_position = global_position
			proj.direction = sign(velocity.x) if velocity.x != 0 else 1
		else:
			print("NOT ENOUGH ENERGY TO SHOOT!")

	var direction := Input.get_axis("move_left", "move_right")
	var current_speed = walk_speed if Input.is_action_pressed("walk") else run_speed
	
	if is_crouching:
		current_speed = 0.0
		
	if direction:
		velocity.x = direction * current_speed
		sword_hitbox.position.x = abs(sword_hitbox.position.x) * direction
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

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
		velocity.x = move_toward(velocity.x, 0, run_speed)
		velocity.y = 0
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
		
func _on_death() -> void:
	var ui = get_node("GameOverScreen")
	if ui:
		ui.show_death_screen()
