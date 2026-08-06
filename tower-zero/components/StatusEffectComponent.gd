extends Node
class_name StatusEffectComponent

@export var health_component: HealthComponent
@export var parent_body: CharacterBody2D

var burn_timer: float = 0
var burn_damage: int = 0

var poison_timer: float = 0
var original_speed: float = 0

var burn_tick_timer: float = 0.0

func _ready() -> void:
	if parent_body and "speed" in parent_body:
		original_speed = parent_body.speed

func _process(delta: float) -> void:
	if burn_timer > 0:
		burn_timer -= delta
		burn_tick_timer -= delta
		if burn_tick_timer <= 0:
			burn_tick_timer = 0.5
			if health_component:
				health_component.take_damage(burn_damage)
		if burn_timer <= 0 and poison_timer <= 0 and parent_body and parent_body.has_node("Sprite2D"):
			parent_body.get_node("Sprite2D").modulate = Color.WHITE
	
	if poison_timer > 0:
		poison_timer -= delta
		if poison_timer <= 0 and parent_body and "speed" in parent_body:
			parent_body.speed = original_speed
			if burn_timer <= 0 and parent_body.has_node("Sprite2D"):
				parent_body.get_node("Sprite2D").modulate = Color.WHITE

func apply_fire(damage: int, duration: float) -> void:
	burn_damage = damage
	burn_timer = duration
	if parent_body and parent_body.has_node("Sprite2D"):
		parent_body.get_node("Sprite2D").modulate = Color.ORANGE

func apply_poison(duration: float) -> void:
	poison_timer = duration
	if parent_body and "speed" in parent_body:
		parent_body.speed = original_speed * 0.5
	if parent_body and parent_body.has_node("Sprite2D"):
		parent_body.get_node("Sprite2D").modulate = Color.GREEN
