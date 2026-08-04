extends Area2D
class_name HurtboxComponent

var damage_number_scene = preload("res://scenes/effects/DamageNumber.tscn")

@export var health_component: HealthComponent

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent and health_component != null:
		if area.get_parent() == self.get_parent():
			return # Don't hit yourself!
			
		# Prevent enemies from hitting each other and freezing the game
		if area.get_parent() is Enemy and self.get_parent() is Enemy:
			return
			
		health_component.take_damage(area.damage)
		EventBus.hit_landed.emit()
		
		var num = damage_number_scene.instantiate()
		get_tree().current_scene.add_child(num)
		num.global_position = self.global_position
		num.setup(area.damage)
