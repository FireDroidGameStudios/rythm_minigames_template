@tool
class_name LaneHitArea
extends Node2D


signal hit_missed
signal hit_succeeded(hit_info: Dictionary)


enum AreaShape {
	CIRCLE,
	RECTANGLE,
}

@export var shape: AreaShape = AreaShape.RECTANGLE:
	set = set_shape
@export_range(0, 10, 1, "or_greater") var lane_index: int = 0
@export var input_action: StringName = &""

var _touching_objects: Array[LaneHitObject] = []

var _circle_shape_radius: float = 10.0:
	set = set_circle_shape_radius
var _rectangle_shape_size: Vector2 = Vector2(20.0, 20.0):
	set = set_rectangle_shape_size
var _perfect_hit_circle_shape_radius: float = 10.0:
	set = set_perfect_hit_circle_shape_radius
var _perfect_hit_rectangle_shape_size: Vector2 = Vector2(20.0, 20.0):
	set = set_perfect_hit_rectangle_shape_size

@onready var full_area: Area2D = get_node("FullArea")
@onready var full_area_collision_shape: CollisionShape2D = (
	get_node("FullArea/CollisionShape2D")
)
@onready var perfect_hit_area_visualizer: MeshInstance2D = (
	get_node("PerfectHitAreaVisualizer")
)


func _ready() -> void:
	_update_area_shapes(true)


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		_handle_input()


func _property_can_revert(property: StringName) -> bool:
	if (
		property == &"_circle_shape_radius"
		or property == &"_perfect_hit_circle_shape_radius"
		or property == &"_rectangle_shape_size"
		or property == &"_perfect_hit_rectangle_shape_size"
	):
		return true
	return false


func _property_get_revert(property: StringName) -> Variant:
	if property == &"_circle_shape_radius":
		return 20.0
	elif property == &"_perfect_hit_circle_shape_radius":
		return 10.0
	elif property == &"_rectangle_shape_size":
		return Vector2(20, 20)
	elif property == &"_perfect_hit_rectangle_shape_size":
		return Vector2(10, 10)
	return null


func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	if shape == AreaShape.CIRCLE:
		property_list.append({
			&"name": "_circle_shape_radius",
			&"type": TYPE_FLOAT,
			&"usage": PROPERTY_USAGE_DEFAULT,
		})
		property_list.append({
			&"name": "_perfect_hit_circle_shape_radius",
			&"type": TYPE_FLOAT,
			&"usage": PROPERTY_USAGE_DEFAULT,
		})
	elif shape == AreaShape.RECTANGLE:
		property_list.append({
			&"name": "_rectangle_shape_size",
			&"type": TYPE_VECTOR2,
			&"usage": PROPERTY_USAGE_DEFAULT,
		})
		property_list.append({
			&"name": "_perfect_hit_rectangle_shape_size",
			&"type": TYPE_VECTOR2,
			&"usage": PROPERTY_USAGE_DEFAULT,
		})
	return property_list


func set_shape(new_shape: AreaShape) -> void:
	shape = new_shape
	notify_property_list_changed()
	if is_node_ready():
		_update_area_shapes()


func set_circle_shape_radius(value: float) -> void:
	_circle_shape_radius = value
	_perfect_hit_circle_shape_radius = clamp(
		_perfect_hit_circle_shape_radius, 0.0, _circle_shape_radius
	)
	_update_area_shapes()


func set_perfect_hit_circle_shape_radius(value: float) -> void:
	_perfect_hit_circle_shape_radius = clamp(
		value, 0.0, _circle_shape_radius
	)
	_update_perfect_hit_area_shape()


func set_rectangle_shape_size(value: Vector2) -> void:
	_rectangle_shape_size = value
	_perfect_hit_rectangle_shape_size = _perfect_hit_rectangle_shape_size.clamp(
		Vector2.ZERO, _rectangle_shape_size
	)
	_update_area_shapes()


func set_perfect_hit_rectangle_shape_size(value: Vector2) -> void:
	_perfect_hit_rectangle_shape_size = (
		value.clamp(Vector2.ZERO, _rectangle_shape_size)
	)
	_update_perfect_hit_area_shape()


func _handle_input() -> void:
	if Input.is_action_just_pressed(input_action):
		_on_hit_attempt()


func _on_hit_attempt() -> void:
	if _touching_objects.is_empty():
		hit_missed.emit()
		return
	var hit_info: Dictionary = {} # Key = HitObject | Value = hit_ratio
	for object: LaneHitObject in _touching_objects:
		hit_info[object] = _calculate_hit_ratio(object)
	hit_succeeded.emit(hit_info)


func _calculate_hit_ratio(hit_object: LaneHitObject) -> float:
	var distance: float = hit_object.global_position.distance_to(global_position)
	if shape == AreaShape.CIRCLE:
		return smoothstep(
			_circle_shape_radius,
			_perfect_hit_circle_shape_radius,
			distance
		)
	elif shape == AreaShape.RECTANGLE:
		var full_area_point: Vector2 = _get_closest_point_to_rectangle(
			_rectangle_shape_size, hit_object
		)
		var perfect_hit_point: Vector2 = _get_closest_point_to_rectangle(
			_perfect_hit_rectangle_shape_size, hit_object
		)
		var full_area_distance: float = global_position.distance_to(full_area_point)
		var perfect_distance: float = global_position.distance_to(perfect_hit_point)
		return remap(
			clamp(distance, perfect_distance, full_area_distance),
			global_position.distance_to(full_area_point),
			global_position.distance_to(perfect_hit_point),
			0.0, 1.0
		)
	return 0.0


func _get_closest_point_to_rectangle(size: Vector2, target: Node2D) -> Vector2:
	const SIDE_SEGMENTS_OFFSET: Array[Array] = [
		[Vector2(-1, -1), Vector2(1, -1)],
		[Vector2(1, -1), Vector2(1, 1)],
		[Vector2(1, 1), Vector2(-1, 1)],
		[Vector2(-1, 1), Vector2(-1, -1)],
	]
	for offset: PackedVector2Array in SIDE_SEGMENTS_OFFSET:
		var intersection = Geometry2D.segment_intersects_segment(
			global_position,
			global_position + target.global_position.normalized() * (size.x + size.y),
			global_position + (offset[0] * size / 2.0),
			global_position + (offset[1] * size / 2.0)
		)
		if intersection:
			return intersection
	return target.global_position


func _update_area_shapes(reset_shape: bool = false) -> void:
	_update_full_area_shape(reset_shape)
	_update_perfect_hit_area_shape(reset_shape)


func _update_full_area_shape(reset_shape: bool = false) -> void:
	if not is_node_ready():
		return
	var area_shape: Shape2D = full_area_collision_shape.get_shape()
	if shape == AreaShape.CIRCLE:
		if not area_shape is CircleShape2D or reset_shape:
			area_shape = CircleShape2D.new()
		area_shape.radius = _circle_shape_radius
	elif shape == AreaShape.RECTANGLE:
		if not area_shape is RectangleShape2D or reset_shape:
			area_shape = RectangleShape2D.new()
		area_shape.size = _rectangle_shape_size
	area_shape.resource_local_to_scene = true
	full_area_collision_shape.set_shape(area_shape)


func _update_perfect_hit_area_shape(reset_shape: bool = false) -> void:
	if not is_node_ready():
		return
	var mesh: Mesh = perfect_hit_area_visualizer.get_mesh()
	if shape == AreaShape.CIRCLE:
		if not mesh is SphereMesh or reset_shape:
			mesh = SphereMesh.new()
		mesh.radius = _perfect_hit_circle_shape_radius
		mesh.height = 2 * _perfect_hit_circle_shape_radius
	elif shape == AreaShape.RECTANGLE:
		if not mesh is QuadMesh or reset_shape:
			mesh = QuadMesh.new()
		mesh.size = _perfect_hit_rectangle_shape_size
	mesh.resource_local_to_scene = true
	perfect_hit_area_visualizer.set_mesh(mesh)


func _on_full_area_area_entered(area: Area2D) -> void:
	var object = area.get_parent()
	if object is LaneHitObject and object.lane_index == lane_index:
		_touching_objects.append(object)


func _on_full_area_area_exited(area: Area2D) -> void:
	var object = area.get_parent()
	if object is LaneHitObject and object.lane_index == lane_index:
		_touching_objects.erase(object)
