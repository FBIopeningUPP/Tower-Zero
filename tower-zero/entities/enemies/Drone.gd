extends CharacterBody2D
class_name Drone

@export var speed: float = 120.0
@export var damage: int = 10

var death_particles = preload("res://scenes/effects/DeathParticles.tscn")
@onready var health_component: HealthComponent = $HealthComponent
var target: Node2D = null

func _ready() -> void:
	if health_component:
		health_component.health_depleted.connect(_on_death)
		health_component.health_changed.connect(func(c, m): EventBus.enemy_damaged.emit())
		
	# Find the player!
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		target = players[0]
		
func _on_death() -> void:
	var explosion = death_particles.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = self.global_position
	queue_free()
	
func _physics_process(delta: float) -> void:
	# Ignore gravity! Just fly straight at the target.
	if target:
		var direction = global_position.direction_to(target.global_position)
		velocity = direction * speed
		
	move_and_slide()
