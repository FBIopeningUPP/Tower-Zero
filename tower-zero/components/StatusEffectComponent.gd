extends Node
class_name StatusEffectComponent

@export var health_component: HealthComponent
@export var parent_body: CharacterBody2D

var burn_timer: float = 0
var burn_damage: int = 0
var burn_tick_timer: float = 0.0

var poison_timer: float = 0
var electric_timer: float = 0
var original_speed: float = 0

var explosion_scene = preload("res://scenes/effects/DeathParticles.tscn")

func _ready() -> void:
	if parent_body and "speed" in parent_body:
		original_speed = parent_body.speed

func _get_sprite() -> Node2D:
	if not parent_body: return null
	var s = parent_body.get_node_or_null("AnimatedSprite2D")
	if s: return s
	return parent_body.get_node_or_null("Sprite2D")

func _process(delta: float) -> void:
	var sprite = _get_sprite()
	
	if electric_timer > 0:
		electric_timer -= delta
		if electric_timer <= 0 and parent_body and "speed" in parent_body:
			parent_body.speed = original_speed
			if sprite: sprite.modulate = Color.WHITE
			
	if burn_timer > 0:
		burn_timer -= delta
		burn_tick_timer -= delta
		if burn_tick_timer <= 0:
			burn_tick_timer = 0.5
			if health_component:
				health_component.take_damage(burn_damage)
		if burn_timer <= 0 and poison_timer <= 0 and electric_timer <= 0 and sprite:
			sprite.modulate = Color.WHITE
	
	if poison_timer > 0:
		poison_timer -= delta
		if poison_timer <= 0 and parent_body and "speed" in parent_body:
			parent_body.speed = original_speed
			if burn_timer <= 0 and electric_timer <= 0 and sprite:
				sprite.modulate = Color.WHITE

func apply_fire(damage: int, duration: float) -> void:
	if poison_timer > 0:
		_trigger_combo("Explosion", damage * 2, Color.ORANGE)
		poison_timer = 0
		return
	if electric_timer > 0:
		_trigger_combo("Overload", damage * 3, Color.RED)
		electric_timer = 0
		return
		
	burn_damage = damage
	burn_timer = duration
	var sprite = _get_sprite()
	if sprite: sprite.modulate = Color.ORANGE

func apply_poison(duration: float) -> void:
	if burn_timer > 0:
		_trigger_combo("Explosion", burn_damage * 2, Color.ORANGE)
		burn_timer = 0
		return
	if electric_timer > 0:
		_trigger_combo("Meltdown", 30, Color.YELLOW)
		electric_timer = 0
		return
		
	poison_timer = duration
	if parent_body and "speed" in parent_body:
		parent_body.speed = original_speed * 0.5
	var sprite = _get_sprite()
	if sprite: sprite.modulate = Color.GREEN

func apply_electric(damage: int, duration: float) -> void:
	if burn_timer > 0:
		_trigger_combo("Overload", burn_damage * 3, Color.RED)
		burn_timer = 0
		return
	if poison_timer > 0:
		_trigger_combo("Meltdown", 30, Color.YELLOW)
		poison_timer = 0
		return
		
	electric_timer = duration
	if parent_body and "speed" in parent_body:
		parent_body.speed = 0 # Stun!
	var sprite = _get_sprite()
	if sprite: sprite.modulate = Color.CYAN
	
	_chain_lightning(damage)

func _chain_lightning(damage: int) -> void:
	if not parent_body: return
	var enemies = get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		if e == parent_body: continue
		if e.global_position.distance_to(parent_body.global_position) < 150:
			var e_health = e.get_node_or_null("HealthComponent")
			if e_health:
				e_health.take_damage(damage)
				var e_status = e.get_node_or_null("StatusEffectComponent")
				if e_status:
					# Don't infinitely chain, just apply a mini stun
					e_status.electric_timer = 0.5
					if e.get("speed") != null: e.speed = 0

func _trigger_combo(combo_name: String, damage: int, color: Color) -> void:
	if health_component:
		health_component.take_damage(damage)
	
	if explosion_scene and parent_body:
		var exp = explosion_scene.instantiate()
		get_tree().current_scene.add_child(exp)
		exp.global_position = parent_body.global_position
		exp.modulate = color
		exp.scale = Vector2(2, 2)
