import os
import glob

def fix_gd(file_path, enemy_name):
    with open(file_path, 'r') as f:
        content = f.read()

    injection = f"""
	if animated_sprite and animated_sprite.sprite_frames == null or animated_sprite.sprite_frames.get_animation_names().is_empty() or not animated_sprite.sprite_frames.has_animation("idle"):
		var frames = SpriteFrames.new()
		frames.remove_animation("default")
		var tex_dir = DirAccess.open("res://assets/itch/enemy-galore-1/{enemy_name}/")
		if tex_dir:
			for tex_file in tex_dir.get_files():
				if tex_file.ends_with(".png"):
					var tex = load("res://assets/itch/enemy-galore-1/{enemy_name}/" + tex_file)
					var anim_name = tex_file.replace("{enemy_name}_", "").replace(".png", "").to_lower()
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
"""

    if "func _ready()" in content and "frames.remove_animation" not in content:
        content = content.replace("func _ready() -> void:", "func _ready() -> void:\n\tsuper()" + injection)
        with open(file_path, 'w') as f:
            f.write(content)

for gd_file in glob.glob("entities/enemies/Galore/*.gd"):
    enemy = os.path.basename(gd_file).replace(".gd", "")
    fix_gd(gd_file, enemy)
