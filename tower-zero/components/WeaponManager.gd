extends Node
class_name WeaponManager

@onready var parent: Player = get_parent()

var current_melee: String = "katana"
var current_ranged: String = "blaster"

var can_attack: bool = true
var attack_cooldown: float = 0.4
var attack_timer: float = 0.0

var can_shoot: bool = true
var shoot_cooldown: float = 0.2
var shoot_timer: float = 0.0

var projectile_scene = preload("res://entities/projectiles/Projectile.tscn")
var muzzle_flash_scene = preload("res://entities/projectiles/MuzzleFlash.tscn")

func _process(delta: float) -> void:
	if not can_attack:
		attack_timer -= delta
		if attack_timer <= 0:
			can_attack = true
			
	if not can_shoot:
		shoot_timer -= delta
		if shoot_timer <= 0:
			can_shoot = true

func attack_melee() -> void:
	if not can_attack:
		return
		
	var target_pos = parent.get_global_mouse_position()
	var dir = parent.global_position.direction_to(target_pos)
	var angle = dir.angle()
	
	var active_hitbox: HitboxComponent = null
	
	match RunState.active_weapon_primary:
		"Sword":
			active_hitbox = parent.sword_hitbox
			parent.sprite.play("slash")
		"Katana":
			active_hitbox = parent.katana_hitbox
		"Hammer":
			active_hitbox = parent.hammer_hitbox
		"Daggers":
			active_hitbox = parent.sowrd_hitbox
	
	if active_hitbox:
		active_hitbox.damage = RunState.player_stats["sword_damage"]
		
		# Assign elements based on weapon
		match RunState.active_weapon_primary:
			"Sword":
				active_hitbox.element_type = HitboxComponent.Element.ELECTRIC
			"Katana":
				active_hitbox.element_type = HitboxComponent.Element.FIRE
			"Hammer":
				active_hitbox.element_type = HitboxComponent.Element.POISON
			_:
				active_hitbox.element_type = HitboxComponent.Element.NONE
		
		# Enable hitbox, then disable it after a short delay so it can hit again!
		# CRITICAL: We must rotate the hitbox so it actually swings where we aim!
		active_hitbox.rotation = angle
		
		var shape = active_hitbox.get_node("CollisionShape2D")
		shape.set_deferred("disabled", false)
		
		var timer = get_tree().create_timer(0.2)
		timer.timeout.connect(func():
			if is_instance_valid(shape):
				shape.set_deferred("disabled", true)
		)
	
	can_attack = false
	attack_timer = attack_cooldown

func attack_ranged() -> void:
	if not can_shoot:
		return
	
	var proj = projectile_scene.instantiate()
	get_tree().current_scene.add_child(proj)
	proj.global_position = parent.global_position
	
	var target_pos = parent.get_global_mouse_position()
	proj.direction = parent.global_position.direction_to(target_pos)
	
	proj.damage = RunState.player_stats["blaster_damage"]
	
	proj.element_type = HitboxComponent.Element.FIRE
	var proj_sprite = proj.get_node_or_null("Sprite2D")
	if proj_sprite:
		proj_sprite.modulate = Color.ORANGE
	
	if muzzle_flash_scene:
		var flash = muzzle_flash_scene.instantiate()
		get_tree().current_scene.add_child(flash)
		flash.global_position = parent.global_position
		flash.rotation = proj.direction.angle()
	
	can_shoot = false
	shoot_timer = shoot_cooldown
