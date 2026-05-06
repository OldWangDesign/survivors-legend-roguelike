extends Node

## Spatial hash grid for O(1) enemy lookups instead of O(N) group traversal.
## Cell size should be >= largest weapon range for single-cell queries.

const CELL_SIZE := 128.0
const INV_CELL := 1.0 / CELL_SIZE

var _grid: Dictionary = {}
var _entity_cells: Dictionary = {}


func _cell_coord(pos: Vector2) -> Vector2i:
	return Vector2i(int(floor(pos.x * INV_CELL)), int(floor(pos.y * INV_CELL)))


func _cell_key(pos: Vector2) -> int:
	var cx := int(floor(pos.x * INV_CELL))
	var cy := int(floor(pos.y * INV_CELL))
	return cx * 73856093 + cy * 19349663


func register(entity: Node2D) -> void:
	var key := _cell_key(entity.global_position)
	if not _grid.has(key):
		_grid[key] = []
	_grid[key].append(entity)
	_entity_cells[entity.get_instance_id()] = key


func unregister(entity: Node2D) -> void:
	var eid := entity.get_instance_id()
	if not _entity_cells.has(eid):
		return
	var old_key: int = _entity_cells[eid]
	if _grid.has(old_key):
		_grid[old_key].erase(entity)
		if _grid[old_key].is_empty():
			_grid.erase(old_key)
	_entity_cells.erase(eid)


func update_position(entity: Node2D) -> void:
	var eid := entity.get_instance_id()
	var new_key := _cell_key(entity.global_position)
	if _entity_cells.has(eid) and _entity_cells[eid] == new_key:
		return
	if _entity_cells.has(eid):
		var old_key: int = _entity_cells[eid]
		if _grid.has(old_key):
			_grid[old_key].erase(entity)
			if _grid[old_key].is_empty():
				_grid.erase(old_key)
	if not _grid.has(new_key):
		_grid[new_key] = []
	_grid[new_key].append(entity)
	_entity_cells[eid] = new_key


func get_nearby(pos: Vector2, radius: float) -> Array:
	var result: Array = []
	var cells_needed := int(ceil(radius * INV_CELL))
	var cc := _cell_coord(pos)
	for dx in range(-cells_needed, cells_needed + 1):
		for dy in range(-cells_needed, cells_needed + 1):
			var key := (cc.x + dx) * 73856093 + (cc.y + dy) * 19349663
			if _grid.has(key):
				for entity in _grid[key]:
					if is_instance_valid(entity):
						result.append(entity)
	return result


func get_in_range(pos: Vector2, radius: float) -> Array:
	var result: Array = []
	var r_sq := radius * radius
	var cells_needed := int(ceil(radius * INV_CELL))
	var cc := _cell_coord(pos)
	for dx in range(-cells_needed, cells_needed + 1):
		for dy in range(-cells_needed, cells_needed + 1):
			var key := (cc.x + dx) * 73856093 + (cc.y + dy) * 19349663
			if not _grid.has(key):
				continue
			for entity in _grid[key]:
				if is_instance_valid(entity) and pos.distance_squared_to(entity.global_position) < r_sq:
					result.append(entity)
	return result


func get_nearest(pos: Vector2, max_range: float = 999999.0) -> Node2D:
	var nearest: Node2D = null
	var nearest_dist_sq := max_range * max_range
	var cells_needed := int(ceil(max_range * INV_CELL))
	if cells_needed > 20:
		cells_needed = 20
	var cc := _cell_coord(pos)
	for dx in range(-cells_needed, cells_needed + 1):
		for dy in range(-cells_needed, cells_needed + 1):
			var key := (cc.x + dx) * 73856093 + (cc.y + dy) * 19349663
			if not _grid.has(key):
				continue
			for entity in _grid[key]:
				if not is_instance_valid(entity):
					continue
				var d_sq := pos.distance_squared_to(entity.global_position)
				if d_sq < nearest_dist_sq:
					nearest_dist_sq = d_sq
					nearest = entity
	return nearest


func clear() -> void:
	_grid.clear()
	_entity_cells.clear()
