extends CanvasLayer

var cards: Array[DraftCard] = []
var card_pool: CardPool
var buttons: Array[Button] = []

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	card_pool = CardPool.new()
	add_child(card_pool)

func show_draft() -> void:
	cards = card_pool.get_random_cards(3)
	visible = true
	get_tree().paused = true
	_build_ui()

func _build_ui() -> void:
	for child in get_children():
		if child is Control:
			child.queue_free()
	
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
	vbox.add_child(title)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(spacer)
	
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(hbox)
	
	for i in cards.size():
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(300, 200)
		btn.text = cards[i].card_name + "\n\n" + cards[i].description
		btn.add_theme_font_size_override("font_size", 24)
		btn.modulate = cards[i].icon_color
		btn.pressed.connect(_on_card_picked.bind(i))
		hbox.add_child(btn)
		var sep = Control.new()
		sep.custom_minimum_size = Vector2(20, 0)
		hbox.add_child(sep)

func _on_card_picked(index: int) -> void:
	var player = get_tree().get_first_node_in_group("Player") as Player
	if player: 
		cards[index].apply_to(player)
	
	visible = false
	get_tree().paused = false
	for child in get_children():
		if child is Control:
			child.queue_free()
	EventBus.next_floor_requested.emit()
