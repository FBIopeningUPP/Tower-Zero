extends Area2D
class_name HitboxComponent

enum Element {NONE, FIRE, POISON, ELECTRIC}

@export var damage: int = 10
@export var element_type: Element = Element.NONE

func _ready() -> void:
	# Hitboxes must exist on Layer 3 (value 4) so Hurtboxes can detect them!
	collision_layer |= 4
	collision_mask = 0 # Hitboxes don't scan, Hurtboxes do the scanning

