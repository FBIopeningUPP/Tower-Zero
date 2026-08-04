extends Area2D
class_name projectile

@export var speed: float = 800
var direction: int = 1
func _physics_process(delta: float) -> void:
	position.x += speed * direction * delta

func _on_timer_timeout() -> void:
	queue_free()
