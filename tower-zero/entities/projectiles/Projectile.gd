extends HitboxComponent
class_name projectile
@export var speed: float = 800
var direction: Vector2 = Vector2.RIGHT
var velocity: Vector2 = Vector2.ZERO
func _physics_process(delta: float) -> void:
	position += (direction * speed + velocity) * delta
func _on_timer_timeout() -> void:
	queue_free()
