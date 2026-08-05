extends Area2D

var active: bool = false

func _ready() -> void:
	visible = false
	monitoring = false
	body_entered.connect(_on_body_entered)
	EventBus.floor_cleared.connect(_on_floor_cleared)

func _on_floor_cleared(_floor: int) -> void:
	active = true
	visible = true
	monitoring = true
	modulate = Color.GREEN

func _on_body_entered(body: Node2D) -> void:
	if body is Player and active:
		active = false
		visible = false
		monitoring = false
