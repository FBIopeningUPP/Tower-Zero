extends Node2D
class_name MuzzleFlash
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	animated_sprite.play("flash")
func _on_timer_timeout() -> void:
	queue_free()
