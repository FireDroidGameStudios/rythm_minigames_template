extends FDProjectManager


const MAIN_SCREEN = preload("res://scenes/gui/main_screen.tscn")
const CREDITS_SCREEN = preload("res://scenes/gui/credits_screen.tscn")
const CATEGORIES_SCREEN = preload("res://scenes/gui/categories_screen.tscn")


func _setup(params: Dictionary) -> void:
	pass


func _on_action_triggered(action: StringName, context: StringName = &"") -> void:
	if context == &"main_screen":
		_handle_main_screen_action(action)
	elif context == &"credits_screen":
		_handle_credits_screen_action(action)
	elif context == &"categories_screen":
		_handle_categories_screen_action(action)


func _handle_main_screen_action(action: StringName) -> void:
	if action == &"play":
		var action_hud: ActionHUD = (
			(FDCore.get_current_scene() as Control).get_node_or_null("ActionHUD")
		)
		if action_hud:
			action_hud.play_animation()
		FDCore.change_scene_to(CATEGORIES_SCREEN.instantiate())
	elif action == &"credits":
		var action_hud: ActionHUD = (
			(FDCore.get_current_scene() as Control).get_node_or_null("ActionHUD")
		)
		if action_hud:
			action_hud.play_animation()
		FDCore.change_scene_to(CREDITS_SCREEN.instantiate())
	elif action == &"quit":
		get_tree().quit()


func _handle_credits_screen_action(action: StringName) -> void:
	if action == &"return":
		var action_hud: ActionHUD = (
			(FDCore.get_current_scene() as Control).get_node_or_null("ActionHUD")
		)
		if action_hud:
			action_hud.play_animation()
		FDCore.change_scene_to(MAIN_SCREEN.instantiate())


func _handle_categories_screen_action(action: StringName) -> void:
	if action == &"return":
		var action_hud: ActionHUD = (
			(FDCore.get_current_scene() as Control).get_node_or_null("ActionHUD")
		)
		if action_hud:
			action_hud.play_animation()
		FDCore.change_scene_to(MAIN_SCREEN.instantiate())
