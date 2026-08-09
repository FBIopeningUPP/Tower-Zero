extends Node2D
class_name SafeRoom
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var terminal_pos: Marker2D = $TerminalPos
@onready var shaft_pos: Marker2D = $ShaftPos
@onready var terminal: CorporateTerminal = $CorporateTerminal
@onready var exit_door: ExitDoor = $ExitDoor
@onready var parallex_bg: ParallaxBackground = $ParallaxBackground
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var particles: CPUParticles2D = $CPUParticles2D
func _ready() -> void:
	_setup_biome()
	_spawn_player()
	_setup_terminal()
	_setup_exit_door()
func _setup_biome() -> void:
	var biome = RunState.get_current_biome()
	var color = RunState.get_biome_color()
	canvas_modulate.color = color
	_adjust_parallax_for_biome(biome)
	_adjust_particles_for_biome(biome)
func _adjust_parallax_for_biome(biome: String) -> void:
	match biome:
		"Office":
			$ParallaxBackground/ParallaxLayer_Far/ColorRect_Far.modulate = Color(0.9, 0.95, 1.0, 0.3)
			$ParallaxBackground/ParallaxLayer_Mid/ColorRect_Mid.modulate = Color(0.8, 0.9, 1.0, 0.5)
			$ParallaxBackground/ParallaxLayer_Near/ColorRect_Near.modulate = Color(0.7, 0.85, 1.0, 0.7)
		"Server":
			$ParallaxBackground/ParallaxLayer_Far/ColorRect_Far.modulate = Color(0.4, 0.5, 0.8, 0.3)
			$ParallaxBackground/ParallaxLayer_Mid/ColorRect_Mid.modulate = Color(0.3, 0.4, 0.7, 0.5)
			$ParallaxBackground/ParallaxLayer_Near/ColorRect_Near.modulate = Color(0.2, 0.3, 0.6, 0.7)
		"Lab":
			$ParallaxBackground/ParallaxLayer_Far/ColorRect_Far.modulate = Color(0.5, 0.8, 0.5, 0.3)
			$ParallaxBackground/ParallaxLayer_Mid/ColorRect_Mid.modulate = Color(0.4, 0.7, 0.4, 0.5)
			$ParallaxBackground/ParallaxLayer_Near/ColorRect_Near.modulate = Color(0.3, 0.6, 0.3, 0.7)
		"Foundry":
			$ParallaxBackground/ParallaxLayer_Far/ColorRect_Far.modulate = Color(0.9, 0.4, 0.2, 0.3)
			$ParallaxBackground/ParallaxLayer_Mid/ColorRect_Mid.modulate = Color(0.8, 0.3, 0.1, 0.5)
			$ParallaxBackground/ParallaxLayer_Near/ColorRect_Near.modulate = Color(0.7, 0.2, 0.1, 0.7)
		"Core":
			$ParallaxBackground/ParallaxLayer_Far/ColorRect_Far.modulate = Color(0.4, 0.2, 0.5, 0.3)
			$ParallaxBackground/ParallaxLayer_Mid/ColorRect_Mid.modulate = Color(0.3, 0.1, 0.4, 0.5)
			$ParallaxBackground/ParallaxLayer_Near/ColorRect_Near.modulate = Color(0.2, 0.1, 0.3, 0.7)
func _adjust_particles_for_biome(biome: String) -> void:
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
func _spawn_player() -> void:
	var player_scene = preload("res://entities/player/Player.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	player.global_position = player_spawn.global_position
	player.add_to_group("Player")
func _setup_terminal() -> void:
	terminal.global_position = terminal_pos.global_position
	terminal.draft_requested.connect(_on_draft_requested)
func _setup_exit_door() -> void:
	exit_door.global_position = shaft_pos.global_position
	exit_door.body_entered.connect(_on_shaft_entered.bind())
func _on_draft_requested() -> void:
	var card_count = RunState.get_draft_card_count(0)
	$DraftUI.show_draft(card_count)
func _on_shaft_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		EventBus.next_floor_requested.emit()
