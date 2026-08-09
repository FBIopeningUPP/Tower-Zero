extends Node
class_name CardPool
var pool: Array[DraftCard] = []
func _ready() -> void:
	_build_pool()
func _build_pool() -> void:
		pool.append(_make("Iron Skin", "+25 Max HP", Color.RED, "max_hp", 25))
		pool.append(_make("Titanium Plating", "+50 Max HP", Color.DARK_RED, "max_hp", 50))
		pool.append(_make("Adrenaline Shot", "+30 Max Energy", Color.CYAN, "max_energy", 30))
		pool.append(_make("Battery Pack", "+50 Max Energy", Color.BLUE, "max_energy", 50))
		pool.append(_make("Sharpened Blade", "+15 Sword Damage", Color.ORANGE, "sword_damage", 15))
		pool.append(_make("Tempered Steel", "+25 Sword Damage", Color.ORANGE_RED, "sword_damage", 25))
		pool.append(_make("Combat Boots", "+50 Run Speed", Color.GREEN, "run_speed", 50))
		pool.append(_make("Jet Thrusters", "+100 Jump Power", Color.SKY_BLUE, "jump_power", 100))
		pool.append(_make("Flash Step", "+200 Dash Speed", Color.PURPLE, "dash_speed", 200))
func get_random_cards(count: int) -> Array[DraftCard]:
	var shuffled = pool.duplicate()
	shuffled.shuffle()
	return shuffled.slice(0, count)
func _make(n: String, d: String, c: Color, t: String, v: float) -> DraftCard:
	var card = DraftCard.new()
	card.card_name = n
	card.description = d
	card.icon_color = c
	card.effect_type = t
	card.effect_value = v
	return card
