extends FDProjectManager


func _init() -> void:
	initial_scene = preload("res://addons/fire_droid_core/scenes/defaults/main.tscn")


func _setup(params: Dictionary) -> void:
	pass


func _on_action_triggered(action: StringName, context: StringName = &"") -> void:
	pass
