@tool
extends Node
func _enter_tree():
	if Engine.is_editor_hint():
		call_deferred("_expand_arena")
func _expand_arena():
	var root = get_parent()
	var tml: TileMapLayer = root.get_node_or_null("TileMapLayer")
	if tml:
		print("Auto-expanding Arena TileMapLayer...")
		tml.clear()
		for x in range(-30, 30):
			tml.set_cell(Vector2i(x, 4), 0, Vector2i(0,0))
			tml.set_cell(Vector2i(x, 5), 0, Vector2i(0,0))
		for y in range(-25, 5):
			tml.set_cell(Vector2i(-30, y), 0, Vector2i(0,0))
			tml.set_cell(Vector2i(30, y), 0, Vector2i(0,0))
		for x in range(-15, -8):
			tml.set_cell(Vector2i(x, -2), 0, Vector2i(0,0))
		for x in range(8, 15):
			tml.set_cell(Vector2i(x, -6), 0, Vector2i(0,0))
		for x in range(-5, 5):
			tml.set_cell(Vector2i(x, -12), 0, Vector2i(0,0))
	var spawner = root.get_node_or_null("EnemySpawner")
	if spawner:
		spawner.global_position = Vector2(0, -2500)
	if not root.has_node("EnemySpawnerLeft"):
		var spawner_left = spawner.duplicate()
		spawner_left.name = "EnemySpawnerLeft"
		root.add_child(spawner_left)
		spawner_left.owner = root
		spawner_left.global_position = Vector2(-1500, -2500)
	if not root.has_node("EnemySpawnerRight"):
		var spawner_right = spawner.duplicate()
		spawner_right.name = "EnemySpawnerRight"
		root.add_child(spawner_right)
		spawner_right.owner = root
		spawner_right.global_position = Vector2(1500, -2500)
	self.queue_free()
