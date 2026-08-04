extends  CharacterBody2D
class_name Player

@export var run_speed: float = 300.0
@export var walk_speed: float = 120.0
@export var jump_velocity: float = -400.0

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_double_jump: bool = false
var is_crouching: bool = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else: 
		can_double_jump	 = true
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
	
	var direction := Input.get_axis("move_left", "move_right")
	
	var current_speed = walk_speed if Input.is_action_pressed("walk") else run_speed	
	if is_crouching:
		current_speed = 0.0
		
	if direction:
		velocity.x = direction * current_speed
	else: 
		velocity.x = move_toward(velocity.x, 0, current_speed)
		
	move_and_slide()
