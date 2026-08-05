extends Area2D
class_name HurtboxComponent

var damage_number_scene = preload("res://scenes/effects/DamageNumber.tscn")

@export var health_component: HealthComponent

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent and health_component != null:
		var attacker = area.get_parent()
		var victim = self.get_parent()
		
		if attacker == victim:
			return 
			
		if attacker is projectile and victim is Player:
			return
			
		var attacker_is_enemy = (attacker is Enemy) or (attacker is Drone) or (attacker is Boss)
		var victim_is_enemy = (victim is Enemy) or (victim is Drone) or (victim is Boss)
		if attacker_is_enemy and victim_is_enemy:
			return
			
		health_component.take_damage(area.damage)
		EventBus.hit_landed.emit()
		
		var num = damage_number_scene.instantiate()
		get_tree().current_scene.add_child(num)
		num.global_position = self.global_position
		num.setup(area.damage)
