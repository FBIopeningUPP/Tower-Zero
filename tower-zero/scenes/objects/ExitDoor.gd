extends Area2D
class_name ExitDoor

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var door_open: bool = false

func _ready() -> void:
	set_visible(false)
	set_process(false)
	collision.disabled = true
	EventBus.floor_cleared.connect(_on_floor_cleared)
	
func _on_floor_cleared(_floor: int) -> void:
	set_visible(true)
	set_process(true)
	collision.disabled = false
	door_open = true
	anim_player.play("idle")

func _on_body_entered(body: Node2D) -> void:
	if door_open and body.is_in_group("Player"):
		EventBus.next_floor_requested.emit()
		door_open = false
		set_process(false)
		collision.disabled = true
		anim_player.stop()
		hide()

func reset_door() -> void:
	door_open = false
	set_visible(false)
	set_process(false)
	collision.disabled = true
	anim_player.stop()
