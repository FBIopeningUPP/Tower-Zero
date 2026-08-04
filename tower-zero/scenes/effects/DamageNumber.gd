extends Node2D

@onready var label: Label = $Label

func setup(damage: Variant) -> void:
	var random_x = randf_range(-30, 30)
	position += Vector2(random_x, -50)
	
	label.text = str(damage)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 100, 1.0).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
	
	get_tree().create_timer(1.0).timeout.connect(queue_free)
