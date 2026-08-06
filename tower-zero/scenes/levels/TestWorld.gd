extends Node2D

@onready var floor_manager: FloorManager = $FloorManager
@onready var draft_ui: CanvasLayer = $DraftUI
@onready var exit_door: ExitDoor = $ExitDoor

@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var particles: CPUParticles2D = $EnvironmentParticles

func _ready() -> void:
	EventBus.next_floor_requested.connect(_on_next_floor)
	EventBus.floor_started.connect(_on_floor_started)
	EventBus.door_entered.connect(_on_door_entered)
	floor_manager.start_floor()

func _on_floor_started(_floor: int) -> void:
	exit_door.reset_door()
	_setup_biome()

func _setup_biome() -> void:
	var biome = RunState.get_current_biome()
	var color = RunState.get_biome_color()
	if canvas_modulate:
		canvas_modulate.color = color
	_adjust_parallax_for_biome(biome)
	_adjust_particles_for_biome(biome)

func _adjust_parallax_for_biome(biome: String) -> void:
	var bg = $ParallaxBackground
	if not bg: return
	match biome:
		"Office":
			bg.get_node("ParallaxLayer_Far/ColorRect_Far").modulate = Color(0.9, 0.95, 1.0, 0.3)
			bg.get_node("ParallaxLayer_Mid/ColorRect_Mid").modulate = Color(0.8, 0.9, 1.0, 0.5)
			bg.get_node("ParallaxLayer_Near/ColorRect_Near").modulate = Color(0.7, 0.85, 1.0, 0.7)
		"Server":
			bg.get_node("ParallaxLayer_Far/ColorRect_Far").modulate = Color(0.4, 0.5, 0.8, 0.3)
			bg.get_node("ParallaxLayer_Mid/ColorRect_Mid").modulate = Color(0.3, 0.4, 0.7, 0.5)
			bg.get_node("ParallaxLayer_Near/ColorRect_Near").modulate = Color(0.2, 0.3, 0.6, 0.7)
		"Lab":
			bg.get_node("ParallaxLayer_Far/ColorRect_Far").modulate = Color(0.5, 0.8, 0.5, 0.3)
			bg.get_node("ParallaxLayer_Mid/ColorRect_Mid").modulate = Color(0.4, 0.7, 0.4, 0.5)
			bg.get_node("ParallaxLayer_Near/ColorRect_Near").modulate = Color(0.3, 0.6, 0.3, 0.7)
		"Foundry":
			bg.get_node("ParallaxLayer_Far/ColorRect_Far").modulate = Color(0.9, 0.4, 0.2, 0.3)
			bg.get_node("ParallaxLayer_Mid/ColorRect_Mid").modulate = Color(0.8, 0.3, 0.1, 0.5)
			bg.get_node("ParallaxLayer_Near/ColorRect_Near").modulate = Color(0.7, 0.2, 0.1, 0.7)
		"Core":
			bg.get_node("ParallaxLayer_Far/ColorRect_Far").modulate = Color(0.4, 0.2, 0.5, 0.3)
			bg.get_node("ParallaxLayer_Mid/ColorRect_Mid").modulate = Color(0.3, 0.1, 0.4, 0.5)
			bg.get_node("ParallaxLayer_Near/ColorRect_Near").modulate = Color(0.2, 0.1, 0.3, 0.7)

func _adjust_particles_for_biome(biome: String) -> void:
	if not particles: return
	match biome:
		"Office":
			particles.color_ramp = Gradient.new()
			particles.color_ramp.colors = [Color(1, 1, 1, 0), Color(1, 1, 1, 0.3), Color(1, 1, 1, 0)]
			particles.gravity = Vector2(0, -10)
		"Server":
			particles.color_ramp = Gradient.new()
			particles.color_ramp.colors = [Color(0, 0.5, 1, 0), Color(0, 0.8, 1, 0.4), Color(0, 0.5, 1, 0)]
			particles.gravity = Vector2(0, 0)
		"Lab":
			particles.color_ramp = Gradient.new()
			particles.color_ramp.colors = [Color(0, 1, 0, 0), Color(0.5, 1, 0, 0.4), Color(0, 1, 0, 0)]
			particles.gravity = Vector2(0, -5)
		"Foundry":
			particles.color_ramp = Gradient.new()
			particles.color_ramp.colors = [Color(1, 0.3, 0, 0), Color(1, 0.5, 0, 0.5), Color(1, 0.3, 0, 0)]
			particles.gravity = Vector2(0, 20)
		"Core":
			particles.color_ramp = Gradient.new()
			particles.color_ramp.colors = [Color(0.5, 0, 1, 0), Color(0.8, 0, 1, 0.4), Color(0.5, 0, 1, 0)]
			particles.gravity = Vector2(0, 0)

func _on_door_entered() -> void:
	draft_ui.show_draft()

func _on_next_floor() -> void:
	floor_manager.advance_floor()
	floor_manager.start_floor()
