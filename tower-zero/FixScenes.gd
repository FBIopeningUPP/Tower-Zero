extends SceneTree
func _init():
	var dir = DirAccess.open("res://entities/enemies/Galore/")
	for file in dir.get_files():
		if file.ends_with(".tscn"):
			var scene = load("res://entities/enemies/Galore/" + file)
			var node = scene.instantiate()
			var anim_sprite = node.get_node_or_null("AnimatedSprite2D")
			if anim_sprite:
				var frames = SpriteFrames.new()
				frames.remove_animation("default")
				var enemy_name = file.replace(".tscn", "")
				var tex_path = "res://assets/itch/enemy-galore-1/" + enemy_name + "/"
				var tex_dir = DirAccess.open(tex_path)
				if tex_dir:
					for tex_file in tex_dir.get_files():
						if tex_file.ends_with(".png"):
							var tex = load(tex_path + tex_file)
							var anim_name = tex_file.replace(enemy_name + "_", "").replace(".png", "").to_lower()
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
				anim_sprite.sprite_frames = frames
				if frames.has_animation("idle"):
					anim_sprite.animation = "idle"
				elif frames.has_animation("fly"):
					anim_sprite.animation = "fly"
				var packed = PackedScene.new()
				packed.pack(node)
				ResourceSaver.save(packed, "res://entities/enemies/Galore/" + file)
				print("Fixed: ", file)
	quit()
