@tool
class_name ClickableHitObjectArea
extends Node2D


var _mouse_entered: bool = false

@onready var full_area: Area2D = get_node("FullArea")
@onready var collision_shape: CollisionShape2D = (
	get_node("FullArea/CollisionShape2D")
)
@onready var perfect_hit_area_visualizer: MeshInstance2D = (
	get_node("PerfectHitAreaVisualizer")
)


func _ready() -> void:
	_update_visualizer()
	if not Engine.is_editor_hint():
		perfect_hit_area_visualizer.queue_free()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_update_visualizer()


func _physics_process(_delta: float) -> void:
	pass


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if get_parent() is not ClickableHitObject:
		warnings.append("Parent Node must be a ClickableHitObject.")
	return warnings


## Return [code]true[/code] if the mouse is inside the clickable area, or
## [code]false[/code] if not.
func has_mouse_entered() -> bool:
	return _mouse_entered


func _update_visualizer() -> void:
	if not get_parent() is ClickableHitObject:
		return
	collision_shape.shape.radius = get_parent().clickable_radius
	if not Engine.is_editor_hint():
		return
	perfect_hit_area_visualizer.mesh.radius = (
		get_parent().perfect_click_tolerance
	)
	perfect_hit_area_visualizer.mesh.height = (
		get_parent().perfect_click_tolerance * 2
	)


func _on_full_area_mouse_entered() -> void:
	_mouse_entered = true


func _on_full_area_mouse_exited() -> void:
	_mouse_entered = false
