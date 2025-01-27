extends Node
## Core class to Fire-Droid Game Studios projects.
##
## This class is the core for projects of [b]Fire-Droid Game Studios[/b]. It
## includes the base project organization as folowing:
## [codeblock]
## ▪ FDCore
##     ▪ PermanentBackLayer
##     ▪ TemporaryLayer
##     ▪ PermanentForeLayer
##     ▪ TransitionLayer
##     ▪ ProjectManager
## [/codeblock]
##
## ▪ [code]TemporaryLayer[/code] is where the scene change occurs. This layer can
## only have one child at time, wich is changed every [method change_scene] or [method change_scene_to]
## call, and replaced by a new scene.[br][br]
##
## ▪ [code]PermanentBackLayer[/code] and [code]PermanentBackLayer[/code] are permanent
## layers, and all nodes added to them can only be removed manually. The difference
## between both is that the second overlays current scenes (useful for HUDs). Both can be
## used to keep nodes during scene changes. To add, remove, get or check if a permanent
## node exists, call [method add_permanent_node], [method remove_permanent_node],
## [method get_permanent_node] and [method has_permanent_node] respectively.[br][br]
##
## ▪ [code]TransitionLayer[/code] is the layer to play transitions during scene changes.
## This layer overlays all other layers.[br][br]
##
## ▪ [code]ProjectManager[/code] this is the main manager for a project. It must
## inherit from class [FDProjectManager], override property
## [member FDProjectManager.initial_scene] by calling [method FDProjectManager.set_initial_scene]
## inside it's [method Object._init] function, and override method
## [method FDProjectManager._on_action_triggered] (where all the handlers will work).
##
## [br][br]Every project must have a project manager, wich consists in a handler
## of triggered actions. It can manage screen changes and the flow of the project,
## calling functions based on received actions (see [FDProjectManager]).
## [br][br]To create it, inherit a new script from [FDProjectManager] and
## follow the steps on its parent class' documentation.[br][br]After created and,
## implemented, it must be specified in project settings.[br]
## To do it, go to [code]Project->Project Settings->FD Core->Project Manager[/code]
## and specify the project manager's path.[br][br]
## There is also a debug mode that can be enabled to prevent current scene to be
## replaced on run. Enable or disable it on
## [code]Project->Project Settings->FD Core->Enable Debug Mode[/code].


## Emitted when scene has been fully changed, after [method change_scene]
## and [method change_scene_to] calls.
signal scene_changed

## Emitted when a transition has finished after calling method [method play_transition].
signal transition_finished

## Error codes to detail the type of an error. See [method critical_error].
enum ErrorCodes {
	DEFAULT_ERROR, ## Default error for general purposes.
}

#const _TransitionScene = preload("res://addons/fire_droid_core/scenes/transitions/transition.tscn")

const DEFAULT_PROJECT_MANAGER_PATH: String = (
	"res://addons/fire_droid_core/scenes/defaults/default_project_manager.gd"
)
const DEFAULT_INTRO_PATHS: PackedStringArray = [
	"res://addons/fire_droid_core/scenes/logo_intro/godot_logo_intro.tscn",
	"res://addons/fire_droid_core/scenes/logo_intro/fire_droid_logo_intro.tscn"
]
const DEFAULT_INITIAL_SCENE_PATH: String = (
	"res://addons/fire_droid_core/scenes/defaults/main.tscn"
)

var default_transition: Transition = FadeTransition.new()
var _current_scene = null
var _permanent_nodes: Dictionary = {}
var _project_manager: FDProjectManager = null:
	set = _set_project_manager

@onready var _permanent_fore_layer = (
	get_node("PermanentForeLayer") if not is_debug_mode_enabled() else null
)
@onready var _temporary_layer = (
	get_node("TemporaryLayer") if not is_debug_mode_enabled() else null
)
@onready var _permanent_back_layer = (
	get_node("PermanentBackLayer") if not is_debug_mode_enabled() else null
)
@onready var _transition_layer = (
	get_node("TransitionLayer") if not is_debug_mode_enabled() else null
)


func _init() -> void:
	if is_debug_mode_enabled():
		return

	# Permanent Back Layer
	var permanent_back_layer: Node = Node.new()
	permanent_back_layer.set_name("PermanentBackLayer")
	# Temporary Layer
	var temporary_layer: Node = Node.new()
	temporary_layer.set_name("TemporaryLayer")
	# Permanent Fore Layer
	var permanent_fore_layer: Node = Node.new()
	permanent_fore_layer.set_name("PermanentForeLayer")
	# Transition Layer
	var transition_layer: CanvasLayer = CanvasLayer.new()
	transition_layer.set_name("TransitionLayer")

	add_child(permanent_back_layer)
	add_child(temporary_layer)
	add_child(permanent_fore_layer)
	add_child(transition_layer)


func _ready() -> void:
	if is_debug_mode_enabled():
		return
	get_tree().current_scene.queue_free()	# Experimental
	get_tree().current_scene = self			# Experimental
	_setup_project_manager(
		StringName(ProjectSettings.get_setting(
			"fd_core/project_manager", DEFAULT_PROJECT_MANAGER_PATH
		))
	)
	await _initial_setup()


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass

## Return the default loading screen scene, defined in Project Settings. If no
## path is set, return the built-in default loading screen.
func get_default_loading_screen() -> PackedScene:
	const DEFAULT_LOADING_SCREEN: PackedScene = preload(
		"res://addons/fire_droid_core/scenes/defaults/default_loading_screen.tscn"
	)
	return (
		ProjectSettings.get_setting(
			"fd_core/default_loading_screen_path", DEFAULT_LOADING_SCREEN
		)
	)


## Checks if debug mode is enabled in Project Settings.
func is_debug_mode_enabled() -> bool:
	return (
		ProjectSettings.get_setting("fd_core/enable_debug_mode", false)
	)


func set_default_transition(transition: Transition) -> void:
	default_transition = transition
	log_message("Set default transition")


## Change current scene to [code]scene[/code], applying a transition. Default
## transition values can be overwritten by optional
## [code]override_transition_defaults[/code] values (as a [Dictionary]).
## [br][br][b]Example:[/b][codeblock]
##     # Without overriding transition values
## await change_scene_to(MainMenu.instantiate())
##
##     # Overriding transition value
## await change_scene_to(LevelScene.instantiate(), {&"color_1": Color.WHITE, &"duration_out": 0.8})
## [/codeblock]
func change_scene_to(scene: Node, override_transition_defaults: Dictionary = {}) -> void:
	log_message("Changing scene to " + str(scene))
	var transition: Transition = (
		default_transition.duplicate() if default_transition else FadeTransition.new()
	)
	_transition_layer.add_child(transition)
	if not _current_scene:
		transition.set_forced_status(Transition.Status.OUT)
	else:
		await transition.play(override_transition_defaults)
		clear_children(_temporary_layer)
	_temporary_layer.add_child(scene)
	_current_scene = scene
	log_message("Changed scene to " + str(_current_scene))
	await transition.play(override_transition_defaults)
	clear_children(_transition_layer)
	scene_changed.emit()


## Play a transition and call a method between transition's [code]IN[/code] and
## [code]OUT[/code] states. When transition fully appears, a method [param to_call]
## is called passing [param args] (optional) as arguments. To await [param to_call]
## execution, pass [param await_call] as [code]true[/code] (default is [code]false[/code].
## Default values of transition can be overwritten by
## setting [param override_transition_defaults] values, as a [Dictionary].
## [br][br][b]Example:[/b][codeblock]
## func _next_room(items: PackedStringArray, room_size: Vector2) -> void:
##     _room_number += 1
##     room.clear_items()
##     room.set_items(items)
##
## func _on_player_interacted_with_door() -> void:
##     await play_transition(
##         _next_room, [["Desk", "Candle", "Bed"], Vector2(5, 4)], false, {&"duration_out": 0.8}
##     )
## [/codeblock]
func play_transition(
	to_call: Callable, args: Array = [],
	await_call: bool = false, override_transition_defaults: Dictionary = {}
) -> void:
	log_message("Playing transition")
	var transition: Transition = (
		default_transition.duplicate() if default_transition else FadeTransition.new()
	)
	_transition_layer.add_child(transition)
	await transition.play(override_transition_defaults)
	if await_call:
		await to_call.callv(args)
	else:
		to_call.callv(args)
	await transition.play(override_transition_defaults)
	clear_children(_transition_layer)
	transition_finished.emit()


## Load a scene from [code]path[/code] and turn it the current scene, applying a transition.
## Default transition values can be overwritten by optional
## [code]override_transition_defaults[/code] values (as a [Dictionary]).
## [br][br][b]Example:[/b][codeblock]
##     # Without overriding transition values
## await change_scene_to("res://scenes/main_menu.tscn")
##
##     # Overriding transition values
## await change_scene_to("res://scenes/level_1.tscn", {&"color_1": Color.WHITE, &"duration_out": 0.8})
## [/codeblock]
func change_scene(path: String, override_transition_defaults: Dictionary = {}) -> void:
	log_message("Changing scene to path " + str(path))
	var packed_scene: PackedScene = load(path) as PackedScene
	if packed_scene == null:
		critical_error("Could not load scene located at <" + path + ">")
		return
	await change_scene_to(packed_scene.instantiate(), override_transition_defaults)


## Clear all children of [param node].
static func clear_children(node: Node) -> void:
	if node == null:
		return
	for child in node.get_children():
		child.queue_free()


## Print an error with code [param error_code], displaying a message given by
## [param message]. After printing the error, the program is terminated and return
## code [param exit_code] to system.
## [br][br][b]Example:[/b][codeblock]
## var important_file = load("res://important_file.txt")
## if important_file == null:
##     FDCore.critical_error("Missing important file. Cannot continue processing.")
##     return
## [/codeblock]
func critical_error(
	message: String, error_code: int = ErrorCodes.DEFAULT_ERROR, exit_code: int = 1
):
	log_message("Error (" + str(error_code) + "): " + message, "red")
	get_tree().quit(exit_code)


## Print [param message] prefixed with a timestamp of current time of printed message.[br]
## Optional argument [param color] can be provided to change message color.[br][br]
## [b]Available color values:[b] [code]black[/code], [code]red[/code], [code]green[/code],
## [code]yellow[/code], [code]blue[/code], [code]magenta[/code], [code]pink[/code],
## [code]purple[/code], [code]cyan[/code], [code]white[/code],
## [code]orange[/code], [code]gray[/code].
## [codeblock]
##     # Print message "[21:06:39]: Player reached a new checkpoint." colored yellow
## FDCore.log_message("Player reached a new checkpoint.", "yellow")
## [/codeblock]
static func log_message(message: String, color: String = "gray") -> void:
	var timestamp: String = Time.get_time_string_from_system()
	print_rich("[color=%s][%s]: %s[/color]" % [color, timestamp, message])


## Add [param node] as a permanent node with identifier [param id]. A permanent node
## can only be removed manually by calling [member remove_permanent_node].[br][br]
## If [param id] is already taken by another node, then [param node] is not added
## and [code]false[/code] is returned. Otherwise, [code]true[/code] is returned
## if [param node] has been successfully added as permanent node.[br][br]
## By default, the added node will overlap the current scene. To prevent it,
## set [param overlap_current_scene] to [code]false[/code].
## [br][br][b]Example:[/b][codeblock]
##     # Add a new Button overlapping current scene
## add_permanent_node(&"button", Button.new())
##
##     # Add a new Button behind current scene
## add_permanent_node(&"background", ForestBackground.instantiate(), false)
##
##     # Attempt to add a new Button with id "button", but it already exists
## print(add_permanent_node("button", Button.new())) # prints false
func add_permanent_node(id: StringName, node: Node, overlap_current_scene: bool = true) -> bool:
	if _permanent_nodes.has(id):
		return false
	_permanent_nodes[id] = node
	if overlap_current_scene:
		_permanent_fore_layer.add_child(node)
	else:
		_permanent_back_layer.add_child(node)
	return true


## Search and return the permanent node with identifier [param id]. If it doesn't
## exists, [code]null[/code] is returned.
func get_permanent_node(id: StringName) -> Node:
	if not has_permanent_node(id):
		return null
	return _permanent_nodes[id]


## Return [code]true[/code] if a permanent node with identifier [param id] exists,
## or [code]false[/code] if it doesn't.
func has_permanent_node(id: StringName) -> bool:
	return (id in _permanent_nodes.keys())


## Call a method of Project Manager, by passing the method's name [param method_name]
## and parameters as an array of values as [param args] (optional). If
## [param await_call] is [code]true[/code], the call will be awaited before returning.
func pmcall(method_name: StringName, args: Array = [], await_call: bool = false):
	if not _project_manager.has_method(method_name):
		warning("Project Manager has no method named " + method_name)
		return
	if await_call:
		return await _project_manager.callv(method_name, args)
	return _project_manager.callv(method_name, args)


## Return a reference to the current Project Manager.
func get_project_manager() -> FDProjectManager:
	return _project_manager


## Call a method of Current Scene, by passing the method's name [param method_name]
## and parameters as an array of values as [param args] (optional). If
## [param await_call] is [code]true[/code], the call will be awaited before returning.
func cscall(method_name: String, args: Array = [], await_call: bool = false):
	if _current_scene == null:
		warning("Current scene is null and no method can be called on it!")
		return
	elif not _current_scene.has_method(method_name):
		warning("Current scene has no method named " + method_name)
		return
	if await_call:
		return await _current_scene.callv(method_name, args)
	return _current_scene.callv(method_name, args)


## Return a reference to the current scene on TemporaryLayer.
func get_current_scene():
	return _current_scene


## Remove a permanent node with identifier [param id] from the PermanentLayer, or
## does nothing if it doesn't exist.[br][br]If [param delete_node] is
## [code]true[/code], also delete the node (by calling [method Node.queue_free]).
func remove_permanent_node(id: String, delete_node: bool = true) -> bool:
	if not _permanent_nodes.has(id):
		return false
	if delete_node:
		_permanent_nodes[id].queue_free()
	_permanent_nodes.erase(id)
	return true


## Trigger an action on current project manager. [param action] is the name of
## the action, and [param context] is an optional context to distinguish actions
## with same name.
## [br][br][b]Example:[/b][codeblock]
## if player.health <= 0:
##     FDCore.trigger_action("player_died", "level")
## [/codeblock]
func trigger_action(action: StringName, context: StringName = &"") -> void:
	if is_debug_mode_enabled():
		return
	log_message("Action triggered: <" + context + "#" + action + ">")
	if _project_manager == null:
		critical_error("Internal error")
		return
	_project_manager.on_action_triggered(action, context)

## Print a warning displaying a message given by [param message].
## [br][br][b]Example:[/b][codeblock]
## if not len(player.inventory) < player.InventorySlots:
##     warning("Player inventory is full!")
## [/codeblock]
func warning(message: String) -> void:
	log_message("Warning: " + message, "yellow")


func _initial_setup() -> void:
	var intro_paths: PackedStringArray = (
		ProjectSettings.get_setting("fd_core/intro_paths", DEFAULT_INTRO_PATHS)
	)
	var initial_scene_path: String = (
		ProjectSettings.get_setting("fd_core/initial_scene", "")
	)
	if initial_scene_path.is_empty():
		initial_scene_path = DEFAULT_INITIAL_SCENE_PATH
	elif not ResourceLoader.exists(initial_scene_path):
		critical_error("Invalid initial_scene")
		return
	FDLoad.add_to_queue(initial_scene_path)
	for intro_path: String in intro_paths:
		FDLoad.add_to_queue(intro_path)
	await _project_manager.start_loading_with_screen()
	if FDLoad.has_failures():
		critical_error(
			"Initial resources failed to load: "
			+ "\t> ".join(FDLoad.get_failure_paths())
		)
		return
	_project_manager.initial_scene = await FDLoad.get_loaded(initial_scene_path)
	for intro_path: String in intro_paths:
		var intro: Control = (await FDLoad.get_loaded(intro_path)).instantiate()
		await change_scene_to(intro, intro.transition_override_properties)
		await _current_scene.finished
	await change_scene_to(_project_manager.initial_scene.instantiate())


func _set_project_manager(new_value: FDProjectManager) -> void:
	if not _project_manager == null:
		warning("Attempting to set a new Project Manager, but it is already set!")
		return
	_project_manager = new_value


func _setup_project_manager(project_manager_path: String) -> void:
	FDCore.log_message(
		"Project Manager path: " + project_manager_path, "cyan"
	)
	if not project_manager_path.is_absolute_path():
		critical_error("Project Manager not defined!")
		return
	elif not FileAccess.file_exists(project_manager_path):
		critical_error("Invalid Project Manager path!")
		return
	var loaded_script: GDScript = load(project_manager_path)
	if loaded_script == null:
		critical_error("Invalid Project Manager path!")
		return
	_project_manager = loaded_script.new()
	_project_manager.set_name("ProjectManager")
	_project_manager.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(_project_manager)
