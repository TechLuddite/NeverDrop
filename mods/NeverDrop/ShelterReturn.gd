extends Node

const INDOOR_MASK := 512
const EDGE_MARGIN := 0.2
const RETURN_DELAY := 2.0
const SCAN_INTERVAL := 0.1

var game_data
var _map: Node3D
var _killbox: Node
var _areas: Array[Area3D] = []
var _volumes: Array[Dictionary] = []
var _placers: Array[Node] = []
var _tracked: Dictionary = {}
var _elapsed := 0.0
var _margin_shape := SphereShape3D.new()


func _ready() -> void:
	_margin_shape.radius = EDGE_MARGIN


func _physics_process(delta: float) -> void:
	_elapsed += delta
	if _elapsed < SCAN_INTERVAL:
		return
	var step := _elapsed
	_elapsed = 0.0
	if not _configure():
		return
	if game_data == null or game_data.freeze or game_data.isTransitioning or game_data.isDead:
		return
	_scan(step, false)


func before_save(target_shelter: String) -> void:
	# Transition has already changed GameData.currentMap at this point.
	if _configure() and _map.mapName == target_shelter:
		_scan(0.0, true)


func _configure() -> bool:
	var current := get_tree().root.get_node_or_null("Map") as Node3D
	if not is_instance_valid(_map) or current != _map:
		_map = current
		_areas.clear()
		_volumes.clear()
		_placers.clear()
		_tracked.clear()
		_killbox = null
	if _map == null or _map.is_queued_for_deletion() or _map.get("mapType") != "Shelter":
		return false
	if _areas.is_empty():
		for area in _map.find_children("*", "Area3D", true, false):
			if "type" not in area or area.type != "Indoor":
				continue
			_areas.append(area)
			for shape in area.get_children():
				if shape is CollisionShape3D and not shape.disabled:
					var planes := _shape_planes(shape.shape)
					if not planes.is_empty():
						_volumes.append({"shape": shape, "planes": planes})
		_placers.assign(_map.find_children("Placer", "", true, false))
		_killbox = _map.get_node_or_null("Killbox")
	return not _areas.is_empty() and not _volumes.is_empty() and is_instance_valid(_killbox) and _killbox.has_method("HandleItem") and "interface" in _killbox and is_instance_valid(_killbox.interface)


func _eligible(item: Node) -> bool:
	if not item is Pickup or item.is_queued_for_deletion() or item.freeze or not _map.is_ancestor_of(item):
		return false
	if item.slotData == null or item.slotData.itemData == null:
		return false
	if item.is_in_group("Furniture"):
		return false
	for placer in _placers:
		if is_instance_valid(placer) and "placable" in placer and placer.placable == item:
			return false
	return item.global_position.is_finite()


func _scan(step: float, saving: bool) -> void:
	var present: Dictionary = {}
	for item in get_tree().get_nodes_in_group("Item"):
		if not _eligible(item):
			continue
		var key := item.get_instance_id()
		present[key] = true
		var position: Vector3 = item.global_position
		var inside := _inside_geometry(position) if saving else _inside_physics(position)
		if inside:
			_tracked.erase(key)
			continue
		var outside_time: float = _tracked.get(key, 0.0) + step
		_tracked[key] = outside_time
		if saving or outside_time >= RETURN_DELAY:
			_killbox.HandleItem(item)
			_tracked.erase(key)
	for key in _tracked.keys():
		if not present.has(key):
			_tracked.erase(key)


func _inside_physics(position: Vector3) -> bool:
	var space := _map.get_world_3d().direct_space_state
	var point := PhysicsPointQueryParameters3D.new()
	point.position = position
	point.collision_mask = INDOOR_MASK
	point.collide_with_areas = true
	point.collide_with_bodies = false
	for hit in space.intersect_point(point, 32):
		if hit.collider in _areas:
			return true
	# Allow a small margin for pickup origins resting against floors and walls.
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = _margin_shape
	query.transform = Transform3D(Basis.IDENTITY, position)
	query.collision_mask = INDOOR_MASK
	query.collide_with_areas = true
	query.collide_with_bodies = false
	for hit in space.intersect_shape(query, 32):
		if hit.collider in _areas:
			return true
	return false


func _inside_geometry(position: Vector3) -> bool:
	for volume in _volumes:
		var shape: CollisionShape3D = volume.shape
		if not is_instance_valid(shape) or shape.disabled:
			continue
		var inside := true
		for plane: Plane in volume.planes:
			var normal := (shape.global_basis.inverse().transposed() * plane.normal).normalized()
			var on_plane := shape.global_transform * (plane.normal * plane.d)
			if normal.dot(position - on_plane) > EDGE_MARGIN:
				inside = false
				break
		if inside:
			return true
	return false


func _shape_planes(shape: Shape3D) -> Array[Plane]:
	var points := PackedVector3Array()
	if shape is ConvexPolygonShape3D:
		points = shape.points
	elif shape is BoxShape3D:
		for x in [-1.0, 1.0]:
			for y in [-1.0, 1.0]:
				for z in [-1.0, 1.0]:
					points.append(shape.size * Vector3(x, y, z) / 2.0)
	var planes: Array[Plane] = []
	for a in range(points.size()):
		for b in range(a + 1, points.size()):
			for c in range(b + 1, points.size()):
				var normal := (points[b] - points[a]).cross(points[c] - points[a])
				if normal.length_squared() < 0.000001:
					continue
				var plane := Plane(normal.normalized(), points[a])
				var positive := false
				var negative := false
				for point in points:
					positive = positive or plane.distance_to(point) > 0.0001
					negative = negative or plane.distance_to(point) < -0.0001
				if positive and negative:
					continue
				if positive:
					plane = Plane(-plane.normal, -plane.d)
				var duplicate := false
				for existing in planes:
					if existing.normal.dot(plane.normal) > 0.9999 and absf(existing.d - plane.d) < 0.0001:
						duplicate = true
						break
				if not duplicate:
					planes.append(plane)
	return planes
