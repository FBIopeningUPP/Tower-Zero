@tool
extends Sprite2D
class_name OfficeProp
enum PropType {
	DESK, DOCUMENT, PENCIL, COIN, PEN_CUP, PAPERS,
	MUG, KEYBOARD, MOUSE, MONITOR, EXTINGUISHER, WHITEBOARD
}
@export var prop_type: PropType = PropType.DESK:
	set(value):
		prop_type = value
		_update_region()
func _ready() -> void:
	texture = preload("res://assets/office/spritesheet.png")
	region_enabled = true
	_update_region()
func _update_region() -> void:
	var col = int(prop_type) % 6
	var row = int(prop_type) / 6
	region_rect = Rect2(col * 32, row * 32, 32, 32)
