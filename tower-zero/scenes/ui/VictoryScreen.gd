extends Control
func _ready() -> void:
	$CenterContainer/VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu_pressed)
func _on_main_menu_pressed() -> void:
	RunState.end_run()
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
