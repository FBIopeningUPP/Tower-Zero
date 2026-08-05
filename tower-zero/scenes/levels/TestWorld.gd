extends Node2D

@onready var floor_manager: FloorManager = $FloorManager
@onready var draft_ui: CanvasLayer = $DraftUI
@onready var exit_door: ExitDoor = $ExitDoor

func _ready() -> void:
	EventBus.floor_cleared.connect(_on_floor_cleared)
	EventBus.next_floor_requested.connect(_on_next_floor)
	EventBus.floor_started.connect(_on_floor_started)
	floor_manager.start_floor()

func _on_floor_cleared(_floor: int) -> void:
	draft_ui.show_draft()

func _on_floor_started(_floor: int) -> void:
	exit_door.reset_door()

func _on_next_floor() -> void:
	floor_manager.advance_floor()
	floor_manager.start_floor()
