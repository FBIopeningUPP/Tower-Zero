extends CharacterBody2D
class_name Enemy

@export var speed: float = 100
@export var damage: int = 10

var death_particles = preload("res://scenes/effects/DeathParticles.tscn")
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: int = -1

@onready var health_component: HealthComponent = $HealthComponent

func _ready() -> void:
	if health_component:
		health_component.health_depleted.connect(_on_death)
		health_component.health_changed.connect(func(c, m): EventBus.enemy_damaged.emit())
		
func _on_death() -> void:
	var explosion = death_particles.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = self.global_position
	
	queue_free()
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	velocity.x = direction * speed
	
	if is_on_wall():
		direction *= -1
	
	move_and_slide()
