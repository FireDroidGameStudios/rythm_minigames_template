class_name Minigame
extends Node2D


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


func disable() -> void:
	_is_enabled = false


func get_transition() -> Transition:
	return _get_transition()


func _get_transition() -> Transition:
	return DiamondsTransition.new()


func _on_spawn_hit_object(hit_object: HitObject) -> void:
	add_child(hit_object)
