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
	var script_path = get_script().resource_path
	if "Galore" in script_path:
		_load_galore_sprites(script_path)
func _load_galore_sprites(script_path: String) -> void:
	var enemy_name = script_path.get_file().replace(".gd", "")
	var sprite = get_node_or_null("AnimatedSprite2D")
	if not sprite: return
	var frames = SpriteFrames.new()
	frames.remove_animation("default")
	var base_dir = "res://assets/itch/enemy-galore-1/" + enemy_name + "/"
	var dirs_to_check = [base_dir]
	if enemy_name == "Golem":
		dirs_to_check = [base_dir + "Armored/", base_dir + "No Armor/"]
	for d in dirs_to_check:
		var dir = DirAccess.open(d)
		if dir:
			for file in dir.get_files():
				if file.ends_with(".png"):
					var tex = load(d + file)
					var anim = file.replace(".png", "").to_lower()
					anim = anim.replace(enemy_name.to_lower() + "_", "")
					anim = anim.replace("spiked_", "")
					anim = anim.replace("armor_", "")
					if not frames.has_animation(anim):
						frames.add_animation(anim)
					var frame_size = 64
					var cols = tex.get_width() / frame_size
					var rows = tex.get_height() / frame_size
					for y in range(rows):
						for x in range(cols):
							var atlas = AtlasTexture.new()
							atlas.atlas = tex
							atlas.region = Rect2(x * frame_size, y * frame_size, frame_size, frame_size)
							frames.add_frame(anim, atlas)
					frames.set_animation_loop(anim, true)
					frames.set_animation_speed(anim, 10)
					for y in range(rows):
						for x in range(cols):
							var atlas = AtlasTexture.new()
							atlas.atlas = tex
							atlas.region = Rect2(x * frame_size, y * frame_size, frame_size, frame_size)
							frames.add_frame(anim, atlas)
					frames.set_animation_loop(anim, true)
					frames.set_animation_speed(anim, 10.0)
	sprite.sprite_frames = frames
	if frames.has_animation("idle"):
		sprite.play("idle")
	elif frames.has_animation("fly"):
		sprite.play("fly")
func _on_death() -> void:
	var explosion = death_particles.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = self.global_position
	EventBus.enemy_died.emit(10)
	queue_free()
func _physics_process(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		if global_position.distance_to(player.global_position) > 40:
			var dir = global_position.direction_to(player.global_position)
			velocity = dir * speed
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
	move_and_slide()
