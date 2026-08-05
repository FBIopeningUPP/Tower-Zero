extends CanvasLayer
class_name HackingMinigame

signal hacking_completed(result: int)

@onready var moving_bar: ColorRect = $Panel/VBoxContainer/GaugeContainer/GaugeBG/MovingBar
@onready var fail_zone_left: ColorRect = $Panel/VBoxContainer/GaugeContainer/GaugeBG/FailZone_Left
@onready var ok_zone: ColorRect = $Panel/VBoxContainer/GaugeContainer/GaugeBG/OkZone
@onready var perfect_zone: ColorRect = $Panel/VBoxContainer/GaugeContainer/GaugeBG/PerfectZone
@onready var timer_label: Label = $Panel/VBoxContainer/TimerLabel
@onready var fail_label: Label = $Panel/VBoxContainer/Legend/FailLabel
@onready var ok_label: Label = $Panel/VBoxContainer/Legend/OkLabel
@onready var perfect_label: Label = $Panel/VBoxContainer/Legend/PerfectLabel

var bar_position: float = 0.0
var bar_direction: float = 1.0
var bar_speed: float = 350.0
var gauge_width: float = 600.0
var bar_width: float = 8.0
var time_remaining: float = 3.0
var auto_stop_timer: float = 0.0
var completed: bool = false
var result: int = 1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	bar_position = 0.0
	bar_direction = 1.0
	time_remaining = 3.0
	completed = false
	_update_timer_display()

func _process(delta: float) -> void:
	if completed:
		return
	
	_move_bar(delta)
	_update_timer(delta)
	_check_input()

func _move_bar(delta: float) -> void:
	bar_position += bar_direction * bar_speed * delta
	
	if bar_position >= gauge_width - bar_width:
		bar_position = gauge_width - bar_width
		bar_direction = -1.0
	elif bar_position <= 0:
		bar_position = 0.0
		bar_direction = 1.0
	
	moving_bar.offset_left = bar_position
	moving_bar.offset_right = bar_position + bar_width

func _update_timer(delta: float) -> void:
	time_remaining -= delta
	auto_stop_timer += delta
	
	if time_remaining <= 0:
		_finish_hacking(0)
		return
	
	if auto_stop_timer >= 10.0:
		_finish_hacking(1)
		return
	
	_update_timer_display()

func _update_timer_display() -> void:
	timer_label.text = "TIME: " + String.format("%.1f", [time_remaining]) + "s"
	
	if time_remaining <= 1.0:
		timer_label.modulate = Color(1, 0.3, 0.3, 1)
		timer_label.add_theme_font_size_override("font_size", 28)
	else:
		timer_label.modulate = Color(1, 1, 1, 1)

func _check_input() -> void:
	if Input.is_action_just_pressed("interact"):
		_finish_hacking(_calculate_result())

func _calculate_result() -> int:
	var bar_center = bar_position + bar_width / 2.0
	
	var perfect_left = perfect_zone.offset_left
	var perfect_right = perfect_zone.offset_left + perfect_zone.size.x
	
	var ok_left = ok_zone.offset_left
	var ok_right = ok_zone.offset_left + ok_zone.size.x
	
	if bar_center >= perfect_left and bar_center <= perfect_right:
		return 2
	elif bar_center >= ok_left and bar_center <= ok_right:
		return 1
	else:
		return 0

func _finish_hacking(res: int) -> void:
	if completed:
		return
	
	completed = true
	result = res
	
	_show_result_feedback()
	
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_MODE_PROCESS)
	tween.tween_callback(_emit_result.bind(result)).set_delay(1.0)
	tween.tween_callback(queue_free.bind()).set_delay(1.5)

func _show_result_feedback() -> void:
	fail_label.modulate = Color(0.5, 0.2, 0.2, 1)
	ok_label.modulate = Color(0.5, 0.5, 0.2, 1)
	perfect_label.modulate = Color(0.2, 0.5, 0.3, 1)
	
	match result:
		0:
			fail_label.modulate = Color(1, 0.4, 0.4, 1)
			fail_label.add_theme_font_size_override("font_size", 24)
		1:
			ok_label.modulate = Color(1, 1, 0.4, 1)
			ok_label.add_theme_font_size_override("font_size", 24)
		2:
			perfect_label.modulate = Color(0.4, 1, 0.6, 1)
			perfect_label.add_theme_font_size_override("font_size", 24)

func _emit_result(res: int) -> void:
	hacking_completed.emit(res)
