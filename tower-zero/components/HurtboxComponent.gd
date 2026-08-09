extends Area2D
class_name HurtboxComponent
var damage_number_scene = preload("res://scenes/effects/DamageNumber.tscn")
@export var health_component: HealthComponent
func _ready() -> void:
	add_to_group("hurtbox")
	collision_mask |= 4
	area_entered.connect(_on_area_entered)
func take_damage(amount: int) -> void:
	if health_component:
		health_component.take_damage(amount)
		var num = damage_number_scene.instantiate()
		get_tree().current_scene.add_child(num)
		num.global_position = self.global_position
		num.setup(amount)
func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent and health_component != null:
		var attacker = area.get_parent()
		var victim = self.get_parent()
		if attacker == victim:
			return
		var attacker_is_enemy = (attacker is Enemy)
		var victim_is_enemy = (victim is Enemy)
		if attacker_is_enemy and victim_is_enemy:
			return
		health_component.take_damage(area.damage)
		EventBus.hit_landed.emit()
		var num = damage_number_scene.instantiate()
		get_tree().current_scene.add_child(num)
		num.global_position = self.global_position
		num.setup(area.damage)
		var status_comp = victim.get_node_or_null("StatusEffectComponent")
		if status_comp:
			match area.element_type:
				HitboxComponent.Element.FIRE:
					status_comp.apply_fire(5, 4.0)
				HitboxComponent.Element.POISON:
					status_comp.apply_poison(5.0)
				HitboxComponent.Element.ELECTRIC:
					status_comp.apply_electric(area.damage / 2, 2.0)
