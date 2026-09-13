extends Control
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	$CenterContainer/VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu_pressed)
func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	RunState.end_run()
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
