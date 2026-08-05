extends Node2D

@onready var floor_manager: FloorManager = $FloorManager
@onready var draft_ui: CanvasLayer = $DraftUI

func _ready() -> void:
	EventBus.floor_cleared.connect(_on_floor_cleared)
	EventBus.next_floor_requested.connect(_on_next_floor)
	floor_manager.start_floor()

func _on_floor_cleared(_floor: int) -> void:
	draft_ui.show_draft()

func _on_next_floor() -> void:
	floor_manager.advance_floor()
	floor_manager.start_floor()
