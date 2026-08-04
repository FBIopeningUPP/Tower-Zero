extends CharacterBody2D
class_name Player

@export var run_speed: float = 300
@export var walk_speed: float = 120
@export var jump_velocity: float = -400
@export var dash_speed: float = 800
@export var dash_duration: float = 0.2

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_double_jump: bool = false
var is_crouching: bool = false
var dash_timer: float = 0.0

enum State { NORMAL, DASHING }
var current_state: State = State.NORMAL

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
		scale.y = 1
	
	if Input.is_action_just_pressed("dash"):
		start_dash()
		return
	
	var direction := Input.get_axis("move_left", "move_right")
	var current_speed = walk_speed if Input.is_action_pressed("walk") else run_speed
	
	if is_crouching:
		current_speed = 0.0
	
	if direction:
		velocity.x = direction * current_speed
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
	
func handle_dash_state (delta: float) -> void:
	dash_timer -= delta
	if dash_timer <= 0:
		velocity.x = move_toward(velocity.x, 0, run_speed)
		velocity.y = 0
		current_state = State.NORMAL
