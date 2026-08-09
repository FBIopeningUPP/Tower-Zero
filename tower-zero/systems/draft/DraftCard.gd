extends Resource
class_name DraftCard
@export var card_name: String = ""
@export var description: String = ""
@export var icon_color: Color = Color.WHITE
@export var effect_type: String = ""
@export var effect_value: float = 0
func apply_to(player: Player) -> void:
	match effect_type:
		"max_hp":
			player.health_component.max_health += int(effect_value)
			player.health_component.current_health += int(effect_value)
			EventBus.player_health_changed.emit(player.health_component.current_health, player.health_component.max_health)
		"max_energy":
			player.max_energy += int(effect_value)
			player.energy += int(effect_value)
			EventBus.player_energy_changed.emit(player.energy, player.max_energy)
		"run_speed":
			player.run_speed += effect_value
		"jump_power":
			player.jump_velocity -= effect_value
		"dash_speed":
			player.dash_speed += effect_value
		"sword_damage":
			player.sword_hitbox.damage += int(effect_value)
