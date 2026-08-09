@tool
extends Node
func _enter_tree():
	if Engine.is_editor_hint():
		call_deferred("_build_level")
func _build_level():
	var root = get_parent()
	if root.has_node("TileMapLayer"):
		queue_free()
		return
	print("Auto-generating TileMapLayer...")
	for node_name in ["Floor", "WallLeft", "WallRight"]:
		if root.has_node(node_name):
			var n = root.get_node(node_name)
			root.remove_child(n)
			n.queue_free()
	var tileset = TileSet.new()
	tileset.tile_size = Vector2i(128, 128)
	tileset.add_physics_layer(0)
	var source = TileSetAtlasSource.new()
	source.texture = preload("res://icon.svg")
	source.texture_region_size = Vector2i(128, 128)
	source.create_tile(Vector2i(0, 0))
	var tile_data = source.get_tile_data(Vector2i(0, 0), 0)
	tile_data.add_collision_polygon(0)
	var polygon = PackedVector2Array([Vector2(-64, -64), Vector2(64, -64), Vector2(64, 64), Vector2(-64, 64)])
	tile_data.set_collision_polygon_points(0, 0, polygon)
	tileset.add_source(source, 0)
	var tml = TileMapLayer.new()
	tml.name = "TileMapLayer"
	tml.tile_set = tileset
	root.add_child(tml)
	tml.owner = root
	for x in range(-2, 12):
		tml.set_cell(Vector2i(x, 4), 0, Vector2i(0,0))
	for y in range(-5, 5):
		tml.set_cell(Vector2i(-3, y), 0, Vector2i(0,0))
		tml.set_cell(Vector2i(12, y), 0, Vector2i(0,0))
	self.queue_free()
