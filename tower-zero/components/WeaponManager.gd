extends Node
class_name WeaponManager

@onready var player: Player = get_parent()

var current_melee: String = "katana"
var current_ranged: String = "blaster"

func attack_melee() -> void:
	match current_melee:
		"sword":
			player.sword_hitbox.damage = RunState.player_stats.get("sword_damage", 40)
			player.sword_hitbox.get_node("CollisionShape2D").set_deferred("disabled", false)
			get_tree().create_timer(0.1).timeout.connect(func(): player.sword_hitbox.get_node("CollisionShape2D").set_deferred("disabled", true))
		"katana":
			player.katana_hitbox.damage = int(RunState.player_stats.get("sword_damage", 40) * 0.75)
			player.katana_hitbox.get_node("CollisionShape2D").set_deferred("disabled", false)
			get_tree().create_timer(0.05).timeout.connect(func(): player.katana_hitbox.get_node("CollisionShape2D").set_deferred("disabled", true))
		"hammer":
			player.hammer_hitbox.damage = int(RunState.player_stats.get("sword_damage", 40) * 2.0)
			player.hammer_hitbox.get_node("CollisionShape2D").set_deferred("disabled", false)
			player.shake_strength = 20.0
			get_tree().create_timer(0.2).timeout.connect(func(): player.hammer_hitbox.get_node("CollisionShape2D").set_deferred("disabled", true))
		"daggers":
			player.daggers_hitbox.damage = int(RunState.player_stats.get("sword_damage", 40) * 0.5)
			player.daggers_hitbox.get_node("CollisionShape2D").set_deferred("disabled", false)
			player.velocity.x += sign(player.velocity.x if player.velocity.x != 0 else 1) * 300 # thrust forward
			get_tree().create_timer(0.05).timeout.connect(func(): player.daggers_hitbox.get_node("CollisionShape2D").set_deferred("disabled", true))
	
func attack_ranged() -> void:
	var cost = 25
	var base_dmg = RunState.player_stats.get("blaster_damage", 20)
	match current_ranged:
		"blaster":
			cost = 25
			if player.energy >= cost:
				player.energy -= cost
				EventBus.player_energy_changed.emit(player.energy, player.max_energy)
				var proj = player.projectile_scene.instantiate()
				proj.damage = base_dmg
				get_tree().current_scene.add_child(proj)
				proj.global_position = player.global_position
				proj.direction = player.global_position.direction_to(player.get_global_mouse_position())
		"shotgun":
			cost = 40
			if player.energy >= cost:
				player.energy -= cost
				EventBus.player_energy_changed.emit(player.energy, player.max_energy)
				var base_dir = player.global_position.direction_to(player.get_global_mouse_position())
				for i in range(3):
					var proj = player.projectile_scene.instantiate()
					proj.damage = int(base_dmg * 0.7)
					get_tree().current_scene.add_child(proj)
					proj.global_position = player.global_position
					# Add slight random spread to the angle
					var spread_angle = randf_range(-0.3, 0.3)
					proj.direction = base_dir.rotated(spread_angle)
		"sniper":
			cost = 50
			if player.energy >= cost:
				player.energy -= cost
				EventBus.player_energy_changed.emit(player.energy, player.max_energy)
				var proj = player.projectile_scene.instantiate()
				proj.damage = int(base_dmg * 2.5)
				get_tree().current_scene.add_child(proj)
				proj.global_position = player.global_position
				var dir = player.global_position.direction_to(player.get_global_mouse_position())
				proj.direction = dir
				proj.rotation = dir.angle()
				proj.speed = 2000 # Super fast
				proj.scale = Vector2(2, 0.5)
