extends CharacterBody2D
class_name Boss
@export var speed: float = 60.0
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var death_particles = preload("res://scenes/effects/DeathParticles.tscn")
@onready var health_component: HealthComponent = $HealthComponent
var direction: int = 1
func _ready() -> void:
	if health_component:
		health_component.health_depleted.connect(_on_death)
		health_component.health_changed.connect(func(c, m): EventBus.enemy_damaged.emit())
func _on_death() -> void:
	EventBus.enemy_died.emit(500)
	var explosion = death_particles.instantiate()
	explosion.scale = Vector2(4, 4)
	get_parent().add_child(explosion)
	explosion.global_position = self.global_position
	queue_free()
func _physics_process(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		var dir = global_position.direction_to(player.global_position)
		velocity = dir * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
