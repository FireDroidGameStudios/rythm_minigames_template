class_name FDProjectManager
extends Node
## A base class for a project manager of Fire-Droid Game Studios projects.
##
## This class works as a template, and all project managers compatible with FDCore
## must inherit from this.[br]There are two mandatory actions for a project
## manager creation:[br][br]
## 1. Set [member initial_scene]: this can be done by picking up the desired
## scene location at [code]ProjectSettings->FDCore->Initial Scene[/code];[br]
## 2. Implement [method _setup]: [b]Do not override the [method _ready]
## method![/b] Instead implement all initializations inside [method _setup];[br]
## 3. Override [method _on_action_triggered]: this method is the main handler for
## all triggered actions coming from FDCore. Override this to define interactions
## over the project.[br][br][b]Example:[/b]
## [codeblock]
## func _on_action_triggered(action: String, context: String = "") -> void:
##     match context:
##         "main_screen": _main_screen_handler(action)
##         "level": _level_handler(action)
##
## func _main_screen_handler(action: String) -> void:
##     match action:
##         "play": FDCore.change_screen("res://scenes/level.tscn")
##         "quit": get_tree().quit()
##
## func _level_handler(action: String) -> void:
##     match action:
##         "main_screen": FDCore.change_screen("res://scenes/main_screen.tscn")
##         "restart": FDCore.change_screen("res://scenes/level.tscn")
##         "quit": get_tree().quit()
## [/codeblock]


## This is the first scene that will be loaded after the logo intros animations.
## The scene is loaded at the initialization of [FDProjectManager], inside [FDCore].
## [br]The path of initial scene must be set in
## [code]ProjectSettings->FDCore->Initial Scene[/code].
var initial_scene: PackedScene = null


func _ready() -> void:
	_setup(ProjectSettings.get_setting("fd_core/project_manager_parameters", {}))
	pass


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


## This method can handle actions triggered by FDCore or an ActionHUD.
## [param action] is the action received, [param context] is an optional
## argument that can be used to distinguish actions with same name.[br][br]
## To change how this function handles actions, override [method _on_action_triggered].
func on_action_triggered(action: StringName, context: StringName = &"") -> void:
	_on_action_triggered(action, context)


func start_loading_with_screen(
	loading_screen_scene: PackedScene = null,
	override_transition_defaults: Dictionary = {},
	type_hint: String = "",
	use_subthread: bool = true,
	retry_limit: int = FDLoad.default_retry_limit,
	cache_mode: ResourceLoader.CacheMode = FDLoad.default_cache_mode
) -> void:
	var loading_screen: FDLoadingScreen = null
	if loading_screen_scene == null:
		loading_screen_scene = FDCore.get_default_loading_screen()
	loading_screen = loading_screen_scene.instantiate()
	await FDCore.change_scene_to(loading_screen)
	FDLoad.start()
	await loading_screen.finished


## This is an overridable method.[br][br]
## Use this method to setup project manager instead of using [method _ready]
## (overriding default FDProjectManager _ready method can cause unexpected
## behaviours).[br][br][param params] is a [Dictionary] containing custom
## parameters defined previously in Project Settings. To modify the dictionary,
## change the value of setting [code]"fd_core/project_manager_parameters"[/code].
func _setup(params: Dictionary) -> void:
	pass


## This is an overridable method.[br][br]
## This method can be used to handle actions triggered by FDCore or an ActionHUD.
## [param action] is the action received, [param context] is an optional
## argument that can be used to distinguish actions with same name.
## [codeblock]
## func _on_action_triggered(action: StringName, context: StringName = "") -> void:
##     match context:
##          &"main_screen": _main_screen_handler(action)
##          &"level": _level_handler(action)
##
## func _main_screen_handler(action: StringName) -> void:
##     match action:
##         &"play": FDCore.change_scene_to("res://scenes/first_level.gd")
##         &"load": SaveSystem.load_game()
##         &"quit": get_tree().quit() # Same action, different context
##
## func _level_handler(action: StringName) -> void:
##     match action:
##         &"pause": level.pause()
##         &"unpause": level.unpause()
##         &"quit": FDCore.change_scene_to("res://scenes/main_screen.gd") # Same action, different context
## [/codeblock]
func _on_action_triggered(action: StringName, context: StringName = &"") -> void:
	pass
