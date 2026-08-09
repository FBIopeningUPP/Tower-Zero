extends Control
var shard_label: Label
var hp_button: Button
var dmg_button: Button
var en_button: Button
func _ready() -> void:
	_build_ui()
	_update_ui()
func _build_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.05, 0.05, 0.08, 1)
	add_child(bg)
	var title = Label.new()
	title.text = "TOWER ZERO"
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color.CYAN)
	title.position.y = 100
	add_child(title)
	shard_label = Label.new()
	shard_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	shard_label.add_theme_font_size_override("font_size", 32)
	shard_label.add_theme_color_override("font_color", Color.YELLOW)
	shard_label.position = Vector2(-300, 50)
	add_child(shard_label)
	var start_btn = Button.new()
	start_btn.text = "ENTER THE TOWER"
	start_btn.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	start_btn.position.y = -150
	start_btn.position.x = -150
	start_btn.size = Vector2(300, 80)
	start_btn.add_theme_font_size_override("font_size", 24)
	start_btn.pressed.connect(func():
		RunState.start_new_run()
		get_tree().change_scene_to_file("res://scenes/levels/TestWorld.tscn")
	)
	add_child(start_btn)
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vbox.position.y -= 50
	vbox.custom_minimum_size = Vector2(400, 200)
	add_child(vbox)
	var shop_title = Label.new()
	shop_title.text = "-- UPGRADE TERMINAL --"
	shop_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(shop_title)
	hp_button = Button.new()
	hp_button.pressed.connect(_buy_upgrade.bind("starting_hp"))
	vbox.add_child(hp_button)
	dmg_button = Button.new()
	dmg_button.pressed.connect(_buy_upgrade.bind("sword_damage"))
	vbox.add_child(dmg_button)
	en_button = Button.new()
	en_button.pressed.connect(_buy_upgrade.bind("starting_energy"))
	vbox.add_child(en_button)
func _update_ui() -> void:
	shard_label.text = "Data Shards: " + str(RunState.total_shards)
	var costs = {
		"starting_hp": [50, 100, 200, -1],
		"starting_energy": [50, 100, 200, -1],
		"sword_damage": [75, 150, -1]
	}
	var hp_lvl = RunState.permanent_upgrades.get("starting_hp", 0)
	var hp_cost = costs["starting_hp"][hp_lvl]
	hp_button.text = "Upgrade Max HP (Lvl " + str(hp_lvl) + ") - Cost: " + (str(hp_cost) if hp_cost > 0 else "MAX")
	hp_button.disabled = hp_cost == -1 or RunState.total_shards < hp_cost
	var dmg_lvl = RunState.permanent_upgrades.get("sword_damage", 0)
	var dmg_cost = costs["sword_damage"][dmg_lvl]
	dmg_button.text = "Upgrade Sword Damage (Lvl " + str(dmg_lvl) + ") - Cost: " + (str(dmg_cost) if dmg_cost > 0 else "MAX")
	dmg_button.disabled = dmg_cost == -1 or RunState.total_shards < dmg_cost
	var en_lvl = RunState.permanent_upgrades.get("starting_energy", 0)
	var en_cost = costs["starting_energy"][en_lvl]
	en_button.text = "Upgrade Max Energy (Lvl " + str(en_lvl) + ") - Cost: " + (str(en_cost) if en_cost > 0 else "MAX")
	en_button.disabled = en_cost == -1 or RunState.total_shards < en_cost
func _buy_upgrade(upgrade_id: String) -> void:
	if RunState.purchase_upgrade(upgrade_id):
		_update_ui()
