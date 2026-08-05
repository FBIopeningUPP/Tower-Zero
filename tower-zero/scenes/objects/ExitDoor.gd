extends Area2D
var draft_ui_scene = preload("res://scenes/ui/DraftUI.gd")
var draft_ui: CanvasLayer = null

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
		if not draft_ui:
			draft_ui = CanvasLayer.new()
			draft_ui.set_script(draft_ui_scene)
			get_tree().current_scene.add_child(draft_ui)
		draft_ui.show_draft()
		await get_tree().create_timer(0.1).timeout
		draft_ui.tree_exited
		EventBus.next_floor_requested.emit()
