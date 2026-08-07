extends Enemy
class_name Rat

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health: HealthComponent = $HealthComponent
@onready var hitbox: HitboxComponent = $AttackHitbox
@onready var hurtbox: HurtboxComponent = $HurtboxComponent
@onready var patrol_path: Path2D = $PatrolPath
@onready var death_effect: CPUParticles2D = $DeathEffect
@onready var ability_effect: CPUParticles2D = $AbilityEffect # if present

