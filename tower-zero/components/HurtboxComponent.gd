extends Area2D
class_name HurtboxComponent

@export var health_component: HealthComponent

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent and health_component != null:
		health_component.take_damage(area.damage)
		EventBus.hit_landed.emit()
