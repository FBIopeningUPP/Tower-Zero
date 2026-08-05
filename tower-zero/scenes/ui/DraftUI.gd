extends CanvasLayer

var cards: Array[DraftCard] = []
var card_pool: CardPool
var card_buttons: Array[Button] = []
var card_containers: Array[PanelContainer] = []
var selecting: bool = false

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	card_pool = CardPool.new()
	add_child(card_pool)

func show_draft(card_count: int = 3) -> void:
	cards = card_pool.get_random_cards(card_count)
	visible = true
	get_tree().paused = true
	selecting = false
	_build_ui()
	_animate_cards_in()

func _build_ui() -> void:
	for child in get_children():
		if child is Control and child != card_pool:
			child.queue_free()
	
	card_buttons.clear()
	card_containers.clear()
	
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.anchors_preset = Control.PRESET_FULL_RECT
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	bg.move_child(bg, 0)
	
	var panel = PanelContainer.new()
	panel.anchors_preset = Control.PRESET_FULL_RECT
	add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "CHOOSE AN UPGRADE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.modulate = Color(1, 1, 1, 0)
	vbox.add_child(title)
	_animate_title_in(title)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(spacer)
	
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(hbox)
	
	for i in cards.size():
		var container = PanelContainer.new()
		container.custom_minimum_size = Vector2(320, 420)
		container.scale = Vector2(0.8, 0.8)
		container.modulate = Color(1, 1, 1, 0)
		hbox.add_child(container)
		card_containers.append(container)
		
		var cvbox = VBoxContainer.new()
		cvbox.alignment = BoxContainer.ALIGNMENT_CENTER
		container.add_child(cvbox)
		
		var card_bg = ColorRect.new()
		card_bg.custom_minimum_size = Vector2(300, 400)
		card_bg.color = Color(0.1, 0.1, 0.15, 0.95)
		cvbox.add_child(card_bg)
		
		var card_vbox = VBoxContainer.new()
		card_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		card_bg.add_child(card_vbox)
		
		var name_label = Label.new()
		name_label.text = cards[i].card_name
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 28)
		name_label.modulate = cards[i].icon_color
		card_vbox.add_child(name_label)
		
		var spacer1 = Control.new()
		spacer1.custom_minimum_size = Vector2(0, 20)
		card_vbox.add_child(spacer1)
		
		var desc_label = Label.new()
		desc_label.text = cards[i].description
		desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.custom_minimum_size = Vector2(260, 0)
		desc_label.add_theme_font_size_override("font_size", 22)
		desc_label.modulate = Color(0.9, 0.9, 0.9, 1)
		card_vbox.add_child(desc_label)
		
		var spacer2 = Control.new()
		spacer2.custom_minimum_size = Vector2(0, 30)
		card_vbox.add_child(spacer2)
		
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(200, 50)
		btn.text = "SELECT"
		btn.add_theme_font_size_override("font_size", 22)
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		btn.pressed.connect(_on_card_picked.bind(i))
		btn.mouse_entered.connect(_on_card_hover.bind(i, true))
		btn.mouse_exited.connect(_on_card_hover.bind(i, false))
		card_vbox.add_child(btn)
		card_buttons.append(btn)
		
		var sep = Control.new()
		sep.custom_minimum_size = Vector2(30, 0)
		hbox.add_child(sep)

func _animate_cards_in() -> void:
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_MODE_PROCESS)
	
	for i in card_containers.size():
		var container = card_containers[i]
		tween.tween_property(container, "modulate:a", 1.0, 0.4).set_delay(i * 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(container, "scale", Vector2(1, 1), 0.4).set_delay(i * 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).as_parallel()

func _animate_title_in(title: Label) -> void:
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_MODE_PROCESS)
	tween.tween_property(title, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_card_hover(index: int, entered: bool) -> void:
	if selecting:
		return
	
	var container = card_containers[index]
	var btn = card_buttons[index]
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_MODE_PROCESS)
	
	if entered:
		tween.tween_property(container, "scale", Vector2(1.08, 1.08), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(container, "modulate", Color(1.1, 1.1, 1.1, 1), 0.15).as_parallel()
		btn.modulate = Color(1, 1, 0.8, 1)
	else:
		tween.tween_property(container, "scale", Vector2(1, 1), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(container, "modulate", Color(1, 1, 1, 1), 0.15).as_parallel()
		btn.modulate = Color(1, 1, 1, 1)

func _on_card_picked(index: int) -> void:
	if selecting:
		return
	selecting = true
	
	var player = get_tree().get_first_node_in_group("Player") as Player
	if player:
		cards[index].apply_to(player)
		RunState.add_drafted_card({
			"card_name": cards[index].card_name,
			"effect_type": cards[index].effect_type,
			"effect_value": cards[index].effect_value
		})
	
	_animate_card_selection(index)
	
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_MODE_PROCESS)
	tween.tween_callback(_finish_draft).set_delay(0.8)

func _animate_card_selection(chosen_index: int) -> void:
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_MODE_PROCESS)
	
	for i in card_containers.size():
		var container = card_containers[i]
		var btn = card_buttons[i]
		
		if i == chosen_index:
			tween.tween_property(container, "scale", Vector2(1.3, 1.3), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.tween_property(container, "modulate", Color(1.2, 1.2, 1.0, 1), 0.2).as_parallel()
			btn.visible = false
			
			var hud = get_tree().root.get_node_or_null("SafeRoom/HUD") or get_tree().root.get_node_or_null("TestWorld/HUD")
			if hud:
				var target_pos = hud.get_global_mouse_position() - container.get_global_position()
				tween.tween_property(container, "global_position", hud.get_global_position() + Vector2(0, -100), 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN).set_delay(0.3)
				tween.tween_property(container, "modulate:a", 0.0, 0.3).set_delay(0.6).as_parallel()
				tween.tween_property(container, "scale", Vector2(0.5, 0.5), 0.3).set_delay(0.6).as_parallel()
		else:
			tween.tween_property(container, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			tween.tween_property(container, "scale", Vector2(0.8, 0.8), 0.3).as_parallel()
			btn.visible = false

func _finish_draft() -> void:
	visible = false
	get_tree().paused = false
	for child in get_children():
		if child is Control and child != card_pool:
			child.queue_free()
	EventBus.next_floor_requested.emit()