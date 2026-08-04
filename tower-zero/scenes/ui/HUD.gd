extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var energy_bar: ProgressBar = $EnergyBar
@onready var kill_counter: Label = $KillCounter

var total_kills: int = 0

func _ready() -> void:
	EventBus.player_health_changed.connect(_on_player_health_changed)
	EventBus.player_energy_changed.connect(_on_player_energy_changed)
	
	EventBus.enemy_died.connect(_on_enemy_died)
	
func _on_enemy_died(xp: int) -> void:
	total_kills += 1
	kill_counter.text = "KILLS: " + str(total_kills)

func _on_player_health_changed(current: int, max_hp: int) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current

func _on_player_energy_changed(current: int, max_energy: int) -> void:
	energy_bar.max_value = max_energy
	energy_bar.value = current
