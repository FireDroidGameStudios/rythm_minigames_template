class_name Minigame
extends Node2D


enum Type {
	UNDEFINED = -1,
	SINGLE_KEY,
	MULTI_KEY,
	CLICK,
}


signal failed_hit
signal success_hit(ratios: Dictionary)
signal missed_hit(hit_object: HitObject)


var _is_enabled: bool = false


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


func spawn_hit_object(hit_object: HitObject) -> void:
	_on_spawn_hit_object(hit_object)


func enable() -> void:
	_is_enabled = true
	set_visible(true)


func disable() -> void:
	_is_enabled = false
	set_visible(false)


func get_transition() -> Transition:
	return _get_transition()


func get_type() -> Type:
	return _get_type()


func _get_transition() -> Transition:
	return DiamondsTransition.new()


func _on_spawn_hit_object(hit_object: HitObject) -> void:
	add_child(hit_object)


func _get_type() -> Type:
	return Type.UNDEFINED


func _get_transition_type_screen_scene() -> PackedScene:
	return null
