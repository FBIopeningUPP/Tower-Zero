extends Enemy
class_name Slime

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health: HealthComponent = $HealthComponent
@onready var hitbox: HitboxComponent = $AttackHitbox
@onready var hurtbox: HurtboxComponent = $HurtboxComponent
@onready var patrol_path: Path2D = $PatrolPath
@onready var death_effect: CPUParticles2D = $DeathEffect

func _ready() -> void:
	super()
	if animated_sprite and animated_sprite.sprite_frames == null or animated_sprite.sprite_frames.get_animation_names().is_empty() or not animated_sprite.sprite_frames.has_animation("idle"):
		var frames = SpriteFrames.new()
		frames.remove_animation("default")
		var tex_dir = DirAccess.open("res://assets/itch/enemy-galore-1/Slime/")
		if tex_dir:
			for tex_file in tex_dir.get_files():
				if tex_file.ends_with(".png"):
					var tex = load("res://assets/itch/enemy-galore-1/Slime/" + tex_file)
					var anim_name = tex_file.replace("Slime_", "").replace(".png", "").to_lower()
					if not frames.has_animation(anim_name):
						frames.add_animation(anim_name)
					
					var w = tex.get_width()
					var h = tex.get_height()
					var count = w / h
					for i in range(count):
						var atlas = AtlasTexture.new()
						atlas.atlas = tex
						atlas.region = Rect2(i * h, 0, h, h)
						frames.add_frame(anim_name, atlas)
					frames.set_animation_loop(anim_name, true)
					frames.set_animation_speed(anim_name, 10.0)
		animated_sprite.sprite_frames = frames
		if frames.has_animation("idle"):
			animated_sprite.play("idle")
		elif frames.has_animation("fly"):
			animated_sprite.play("fly")

	pass
