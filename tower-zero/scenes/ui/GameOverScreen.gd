extends  CanvasLayer

func _ready() -> void:
	self.visible = false
	
func show_death_screen() -> void:
	self.visible = true
	get_tree().paused = true

func _process(delta: float) -> void:
	if self.visible and Input.is_action_just_pressed("restart"):
		get_tree().paused = false
		get_tree().reload_current_scene()
