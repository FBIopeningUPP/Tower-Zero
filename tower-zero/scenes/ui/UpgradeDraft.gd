extends Control
signal upgrade_selected
@onready var container = $CenterContainer/HBoxContainer
var possible_upgrades = [
	{"name": "+20 Max HP", "effect_type": "max_hp", "effect_value": 20},
	{"name": "+10 Sword Dmg", "effect_type": "sword_damage", "effect_value": 10},
	{"name": "+5 Blaster Dmg", "effect_type": "blaster_damage", "effect_value": 5},
	{"name": "+50 Run Speed", "effect_type": "run_speed", "effect_value": 50},
	{"name": "Heal 50 HP", "effect_type": "heal", "effect_value": 50}
]
func _ready() -> void:
	var choices = possible_upgrades.duplicate()
	choices.shuffle()
	for i in range(3):
		var card = choices[i]
		var btn = Button.new()
		btn.text = card["name"]
		btn.custom_minimum_size = Vector2(200, 300)
		btn.add_theme_font_size_override("font_size", 24)
		btn.pressed.connect(func(): _on_upgrade_chosen(card))
		container.add_child(btn)
func _on_upgrade_chosen(card: Dictionary) -> void:
	if card["effect_type"] == "heal":
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_node("HealthComponent"):
			player.get_node("HealthComponent").current_health += card["effect_value"]
	else:
		RunState._apply_card_to_stats(card)
	upgrade_selected.emit()
	queue_free()
