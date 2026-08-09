extends CanvasLayer
class_name FloorTransition
signal transition_finished(next_scene: String)
@onready var fade_rect: ColorRect = $FadeRect
@onready var floor_label: Label = $FloorLabel
@onready var sub_label: Label = $SubLabel
var target_scene: String = ""
func transition_to(next_scene_path: String, floor_number: int, is_safe_room: bool = false) -> void:
	target_scene = next_scene_path
	floor_label.text = "FLOOR " + str(floor_number)
	sub_label.text = "SAFE ROOM" if is_safe_room else "COMBAT ZONE"
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.visible = true
	floor_label.modulate = Color(1, 1, 1, 0)
	sub_label.modulate = Color(0.7, 0.8, 1.0, 0)
	_play_transition()
func _play_transition() -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(_on_fade_in_complete)
	tween.tween_property(floor_label, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(sub_label, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.1)
	tween.tween_callback(_hold_text).set_delay(1.0)
	tween.tween_property(floor_label, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(sub_label, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(fade_rect, "color:a", 0.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_on_transition_finished)
func _on_fade_in_complete() -> void:
	if target_scene != "":
		get_tree().change_scene_to_file(target_scene)
func _hold_text() -> void:
	pass
func _on_transition_finished() -> void:
	fade_rect.visible = false
	emit_signal("transition_finished", target_scene)
	queue_free()
