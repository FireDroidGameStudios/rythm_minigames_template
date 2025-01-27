class_name ActionButton
extends Button
## Basic button capable of triggering actions on a parent [ActionHUD].
##
## Use this button instead of built-in [Button] to communicate with [FDCore]
## singleton.[br][br]This button node must be inside the hierarchy of an [ActionHUD]
## node, and it must be setted in [member parent_hud].[br][br]
## When setted, the parent HUD from [member parent_hud] will trigger an action
## every signal emission from thisaction button, if an action has been specified.
## [br][br]To specify an action for the action button, change values of
## [member action_on_pressed], [member action_on_release], [member action_on_button_down],
## [member action_on_button_up], [member action_on_toggled_true]
## and [member action_on_toggled_false].[br][br]Leave a value empty to ignore it's
## button signal and don't trigger action to that signal.


@export var parent_hud: ActionHUD = null

@export_group("Actions")
## Will trigger this action when button is pressed. Leave empty to ignore.
@export var action_on_pressed: StringName = &""
## Will trigger this action when button is released. Leave empty to ignore.
@export var action_on_release: StringName = &""
## Will trigger this action when button is pressed down. Leave empty to ignore.
@export var action_on_button_down: StringName = &""
## Will trigger this action when button is pressed up. Leave empty to ignore.
@export var action_on_button_up: StringName = &""
## Will trigger this action when button toggle state is set to true (only if
## [member toggle_mode] is enabled). Leave empty to ignore.
@export var action_on_toggled_true: StringName = &""
## Will trigger this action when button toggle state is set to true (only if
## [member toggle_mode] is enabled). Leave empty to ignore.
@export var action_on_toggled_false: StringName = &""


func _ready() -> void:
	_connect_signals()


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func _connect_signals() -> void:
	if not parent_hud:
		return
	button_down.connect(parent_hud.trigger_action.bind(action_on_button_down))
	button_up.connect(parent_hud.trigger_action.bind(action_on_button_up))
	pressed.connect(parent_hud.trigger_action.bind(action_on_pressed))


func _trigger_action_on_toggled(toggled_on: bool) -> void:
	if not parent_hud:
		return
	if toggled_on:
		if not action_on_toggled_true.is_empty():
			parent_hud.trigger_action(action_on_toggled_true)
	else:
		if not action_on_toggled_false.is_empty():
			parent_hud.trigger_action(action_on_toggled_false)
