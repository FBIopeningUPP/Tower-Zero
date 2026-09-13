extends Enemy
class_name NinjaEnemy
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health: HealthComponent = $HealthComponent
@onready var hurtbox: HurtboxComponent = $HurtboxComponent
@onready var patrol_path: Path2D = $PatrolPath
func _ready() -> void:
	pass
