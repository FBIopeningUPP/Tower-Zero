extends Area2D
class_name SpikeTrap
@export var damage: int = 20
@export var trigger_delay: float = 0.5
@export var active_durration: float = 1
var is_active: bool = false
var is_triggered: bool = false
var original_color: Color = Color.DARK_GRAY
@onready var visual: ColorRect = $ColorRect
@onready var collision: CollisionShape2D = $CollisionShape2D
func _ready() -> void:
	collision_layer = 0
	collision_mask = 1 | 2
	visual.color = original_color
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
func _on_body_entered(body: Node2D) -> void:
	if not is_triggered:
		trigger_trap()
func _on_area_entered(area: Area2D) -> void:
	if not is_triggered:
		trigger_trap()
func trigger_trap() -> void:
	is_triggered = true
	visual.color = Color.ORANGE
	await get_tree().create_timer(trigger_delay).timeout
	is_active = true
	visual.color = Color.RED
	var overlapping_bodies = get_overlapping_bodies()
	for body in overlapping_bodies:
		_deal_damage(body)
	var overlapping_areas = get_overlapping_areas()
	for area in overlapping_areas:
		_deal_damage(area.get_parent())
	await get_tree().create_timer(active_durration).timeout
	is_active = false
	is_triggered = false
	visual.color = original_color
func _deal_damage(entity: Node) -> void:
	if not is_active: return
	if entity.has_node("HealthComponent"):
		entity.get_node("HealthComponent").take_damage(damage)
	elif entity is Player:
		RunState.player_stats["max_hp"] -= damage
