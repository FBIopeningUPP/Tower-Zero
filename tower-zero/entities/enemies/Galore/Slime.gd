extends Enemy
class_name Slime
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health: HealthComponent = $HealthComponent
@onready var hitbox: HitboxComponent = $AttackHitbox
@onready var hurtbox: HurtboxComponent = $HurtboxComponent
@onready var patrol_path: Path2D = $PatrolPath
@onready var death_effect: CPUParticles2D = $DeathEffect
