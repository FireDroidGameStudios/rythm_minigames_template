class_name Minigame
extends Node2D


enum Type {
	UNDEFINED = -1,
	SINGLE_KEY,
	MULTI_KEY,
	CLICK,
}
enum HitPrecision {
	OK,
	GOOD,
	EXCELENT,
	PERFECT,
}


signal failed_hit
signal success_hit(ratios: Dictionary)
signal missed_hit(hit_object: HitObject)


var level: Level = null

var _is_enabled: bool = false


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


static func calculate_hit_precision(ratio: float) -> HitPrecision:
	if ratio >= 1.0:
		return HitPrecision.PERFECT
	elif ratio > 0.60:
		return HitPrecision.EXCELENT
	elif ratio > 0.25:
		return HitPrecision.GOOD
	return HitPrecision.OK


func spawn_hit_object(hit_object: HitObject) -> void:
	_on_spawn_hit_object(hit_object)


func is_enabled() -> bool:
	return _is_enabled


func enable() -> void:
	_is_enabled = true
	set_visible(true)


func disable() -> void:
	_is_enabled = false
	set_visible(false)


func get_minigame_type() -> Type:
	return _get_minigame_type()


func _on_spawn_hit_object(hit_object: HitObject) -> void:
	add_child(hit_object)


func _get_minigame_type() -> Type:
	return Type.UNDEFINED


func _get_transition_type_screen_scene() -> PackedScene:
	return null
