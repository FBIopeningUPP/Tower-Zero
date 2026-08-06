extends CanvasLayer

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var energy_bar: TextureProgressBar = $EnergyBar
@onready var kill_counter: Label = $KillCounter
@onready var floor_label: Label = $FloorLabel 

var total_kills: int = 0

func _ready() -> void:
	EventBus.player_health_changed.connect(_on_player_health_changed)
	EventBus.player_energy_changed.connect(_on_player_energy_changed)
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.floor_started.connect(_on_floor_started)  

func _on_enemy_died(xp: int) -> void:
	total_kills += 1
	kill_counter.text = "KILLS: " + str(total_kills)

func _on_player_health_changed(current: int, max_hp: int) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current

func _on_player_energy_changed(current: int, max_energy: int) -> void:
	energy_bar.max_value = max_energy
	energy_bar.value = current

func _on_floor_started(floor: int) -> void:  
	floor_label.text = "FLOOR " + str(floor)
	floor_label.visible = true
	var tween = create_tween()
	tween.tween_property(floor_label, "position:x", 100, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(floor_label, "position:x", 50, 0.3).set_delay(2.0)
