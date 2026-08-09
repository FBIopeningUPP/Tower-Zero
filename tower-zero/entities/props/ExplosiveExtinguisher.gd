extends StaticBody2D
@export var explosion_damage: int = 50
@export var explosion_radius: float = 150
@onready var health_component: HealthComponent = $HealthComponent
func _ready() -> void:
	if health_component:
		health_component.health_depleted.connect(_explode)
func _explode() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player):
		player.shake_strength = 30
	var death_particles = preload("res://scenes/effects/DeathParticles.tscn")
	var explosion = death_particles.instantiate()
	explosion.scale = Vector2(3, 3)
	get_parent().add_child(explosion)
	var hitboxes = get_tree().get_nodes_in_group("hurtbox")
	for hurtbox in hitboxes:
		if hurtbox is HurtboxComponent:
			var distance = global_position.distance_to(hurtbox.global_position)
			if distance <= explosion_radius:
				hurtbox.take_damage(explosion_damage)
	queue_free()
