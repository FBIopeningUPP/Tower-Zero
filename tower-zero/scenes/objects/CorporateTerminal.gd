extends StaticBody2D
class_name CorporateTerminal
signal draft_requested
@onready var interaction_area: Area2D = $InteractionArea
@onready var prompt_label: Label = $PromptLabel
@onready var light: PointLight2D = $PointLight2D
var player_in_range: bool = false
var hacking_minigame_scene = preload("res://scenes/ui/HackingMinigame.tscn")
func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	prompt_label.visible = false
func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		_open_hacking_minigame()
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		prompt_label.visible = true
		_animate_prompt()
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		prompt_label.visible = false
func _animate_prompt() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(prompt_label, "modulate:a", 0.3, 0.8)
	tween.tween_property(prompt_label, "modulate:a", 1.0, 0.8)
func _open_hacking_minigame() -> void:
	var minigame = hacking_minigame_scene.instantiate()
	get_tree().root.add_child(minigame)
	minigame.hacking_completed.connect(_on_hacking_completed)
	get_tree().paused = true
func _on_hacking_completed(result: int) -> void:
	get_tree().paused = false
	draft_requested.emit()
