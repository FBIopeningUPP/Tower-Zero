import os
import re

directory = 'entities/enemies'
for root, _, files in os.walk(directory):
    for f in files:
        if f.endswith('.tscn'):
            filepath = os.path.join(root, f)
            with open(filepath, 'r') as file:
                content = file.read()
            
            # Ensure HitboxComponent is imported
            if "HitboxComponent.gd" not in content:
                content = re.sub(r'(\[ext_resource.*?\]\n)', r'\g<1>[ext_resource type="Script" path="res://components/HitboxComponent.gd" id=998]\n', content, count=1)
                hitbox_id = "998"
            else:
                m = re.search(r'\[ext_resource.*?path="res://components/HitboxComponent.gd".*?id="?(\w+)"?\]', content)
                if not m:
                    m = re.search(r'\[ext_resource.*?path="res://components/HitboxComponent.gd".*?id=(\d+)\]', content)
                hitbox_id = m.group(1) if m else "998"
                
            # Ensure HurtboxComponent is imported
            if "HurtboxComponent.gd" not in content:
                content = re.sub(r'(\[ext_resource.*?\]\n)', r'\g<1>[ext_resource type="Script" path="res://components/HurtboxComponent.gd" id=999]\n', content, count=1)
                hurtbox_id = "999"
            else:
                m = re.search(r'\[ext_resource.*?path="res://components/HurtboxComponent.gd".*?id="?(\w+)"?\]', content)
                if not m:
                    m = re.search(r'\[ext_resource.*?path="res://components/HurtboxComponent.gd".*?id=(\d+)\]', content)
                hurtbox_id = m.group(1) if m else "999"

            # Attach Hitbox script
            if f'script = ExtResource("{hitbox_id}")' not in content and f'script = ExtResource({hitbox_id})' not in content:
                content = re.sub(r'(\[node name="AttackHitbox" type="Area2D"[^\]]*\])\n', r'\g<1>\nscript = ExtResource("' + hitbox_id + '")\n', content)
                content = re.sub(r'(\[node name="AttackHitbox" type="Area2D"[^\]]*\])\nscript = ExtResource\("' + hitbox_id + '"\)', r'\g<1>\nscript = ExtResource(' + hitbox_id + ')', content)

            # Attach Hurtbox script
            if f'script = ExtResource("{hurtbox_id}")' not in content and f'script = ExtResource({hurtbox_id})' not in content:
                content = re.sub(r'(\[node name="HurtboxComponent" type="Area2D"[^\]]*\])\n', r'\g<1>\nscript = ExtResource("' + hurtbox_id + '")\n', content)
                content = re.sub(r'(\[node name="HurtboxComponent" type="Area2D"[^\]]*\])\nscript = ExtResource\("' + hurtbox_id + '"\)', r'\g<1>\nscript = ExtResource(' + hurtbox_id + ')', content)

            with open(filepath, 'w') as file:
                file.write(content)

