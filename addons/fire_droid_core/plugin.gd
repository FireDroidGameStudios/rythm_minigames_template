@tool
extends EditorPlugin


func _enter_tree() -> void:
	_update_custom_settings()
	add_autoload_singleton("FDCore", "res://addons/fire_droid_core/scenes/fd_core.gd")
	add_autoload_singleton("FDLoad", "res://addons/fire_droid_core/scenes/fd_load.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("FDCore")
	remove_autoload_singleton("FDLoad")


func _update_custom_settings() -> void:
	# Format -> "setting_name": "default_value"
	var custom_settings: Array[Dictionary] = [
		{
			"name": "fd_core/project_manager",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_FILE,
			"hint_string": "*.gd",
			"initial_value": "",
		},
		{
			"name": "fd_core/enable_debug_mode",
			"type": TYPE_BOOL,
			"initial_value": false,
		},
		{
			"name": "fd_core/intro_paths",
			"type": TYPE_ARRAY,
			"hint": PROPERTY_HINT_TYPE_STRING,
			"hint_string": (
				str(TYPE_STRING) + "/" + str(PROPERTY_HINT_FILE) + ":*.tscn"
			),
			"initial_value": [
				"res://addons/fire_droid_core/scenes/logo_intro/godot_logo_intro.tscn",
				"res://addons/fire_droid_core/scenes/logo_intro/fire_droid_logo_intro.tscn"
			],
		},
		{
			"name": "fd_core/default_loading_screen_path",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_FILE,
			"hint_string": "*.gd",
			"initial_value": "",
		},
		{
			"name": "fd_core/initial_scene",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_FILE,
			"hint_string": "*.tscn",
			"initial_value": "",
		},
		{
			"name": "fd_core/project_manager_parameters",
			"type": TYPE_DICTIONARY,
			"initial_value": {}
		},
	]
	for setting in custom_settings:
		var setting_name: String = setting.get("name")
		var initial_value = setting.get("initial_value")
		if not ProjectSettings.has_setting(setting_name):
			ProjectSettings.set_setting(setting_name, initial_value)
		ProjectSettings.add_property_info(setting)
		ProjectSettings.set_initial_value(setting_name, initial_value)
		print("Added custom setting: ", setting)
		print("Value: ", ProjectSettings.get_setting("fd_core/project_manager", "<undefined>"))
