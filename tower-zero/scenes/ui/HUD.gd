extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var energy_bar: ProgressBar = $EnergyBar

func _ready() -> void:
	EventBus.player_health_changed.connect(_on_player_health_changed)
	EventBus.player_energy_changed.connect(_on_player_energy_changed)

func _on_player_health_changed(current: int, max_hp: int) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current

func _on_player_energy_changed(current: int, max_energy: int) -> void:
	energy_bar.max_value = max_energy
	energy_bar.value = current
