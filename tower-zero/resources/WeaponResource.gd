extends Resource
class_name WeaponResource
enum WeaponType { MELEE, RANGED }
enum Element { NONE, FIRE, POISON, ELECTRIC }
@export var damage: int = 0
@export var attack_speed: float = 1.0
@export var range: float = 100.0
@export var energy_cost: int = 0
@export var cooldown: float = 0.0
@export var element: Element = Element.NONE
@export var weapon_type: WeaponType = WeaponType.MELEE
@export var projectile_scene: PackedScene = null
@export var muzzle_scene: PackedScene = null
@export var hitbox_shape: int = 0
@export var hitbox_size: Vector2 = Vector2(0, 0)
@export var hitbox_offset: Vector2 = Vector2(0, 0)
@export var screen_shake: float = 15.0
@export var knockback: float = 0.0
