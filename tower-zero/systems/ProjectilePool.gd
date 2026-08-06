extends Node
class_name ProjectilePool

@export var initial_size: int = 20
@export var projectile_scene: PackedScene
@export var muzzle_flash_scene: PackedScene

var projectile_pool: Array[Node] = []
var muzzle_pool: Array[Node] = []

func _ready() -> void:
	_prefill_pool()

func _prefill_pool() -> void:
	for i in range(initial_size):    
		var proj = projectile_scene.instantiate()
		proj.queue_free()
		projectile_pool.append(proj)
		
		var muzzle = muzzle_flash_scene.instantiate()
		muzzle.queue_free()
		muzzle_pool.append(muzzle)

func get_projectile() -> Node:
	if projectile_pool.is_empty():
		return projectile_scene.instantiate()
	return projectile_pool.pop_back()

func return_projectile(proj: Node) -> void:
	projectile_pool.append(proj)

func get_muzzle_flash() -> Node:
	if muzzle_pool.is_empty():
		return muzzle_flash_scene.instantiate()
	return muzzle_pool.pop_back()

func return_muzzle_flash(muzzle: Node) -> void:
	muzzle_pool.append(muzzle)
