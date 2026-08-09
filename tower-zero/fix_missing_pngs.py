import os
import re

png_magic = b'\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\x0bIDAT\x08\x99c\xf8\x0f\x04\x00\x09\xfb\x03\xfd\xe3U\xf2\x9c\x00\x00\x00\x00IEND\xaeB`\x82'

count = 0
for root, _, files in os.walk('.'):
    for f in files:
        if f.endswith('.tscn'):
            with open(os.path.join(root, f), 'r') as fp:
                for line in fp:
                    m = re.search(r'path="res://([^"]+\.png)"', line)
                    if m:
                        path = m.group(1)
                        if not os.path.exists(path):
                            os.makedirs(os.path.dirname(path), exist_ok=True)
                            with open(path, 'wb') as img:
                                img.write(png_magic)
                            count += 1
print(f"Created {count} missing PNG stubs.")
