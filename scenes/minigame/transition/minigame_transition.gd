class_name MinigameTransition
extends Node


signal reached_start_time(transition: MinigameTransition)


var transition: Transition = null
var start_time: float = 0.0
var type_screen_duration: float = 0.0
var timeline: Timeline = null
var _has_notified_start: bool = false


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	_handle_signal_notify()


func _physics_process(delta: float) -> void:
	pass


func update_transition(info: MinigameTransitionInfo) -> void:
	start_time = info.start_time
	type_screen_duration = info.type_screen_duration
	var transition_scene = load(info.scene_path)
	if transition_scene == null:
		return
	transition = (transition_scene as PackedScene).instantiate()
	transition.duration_in = info.duration_in
	transition.ease_type_in = info.ease_type_in
	transition.trans_type_in = info.trans_type_in
	transition.duration_out = info.duration_out
	transition.ease_type_out = info.ease_type_out
	transition.trans_type_out = info.trans_type_out
	for arg: StringName in info.additional_args.keys():
		if not arg or arg.is_empty():
			continue
		transition.set(arg, info.additional_args.get(arg))


func _handle_signal_notify() -> void:
	if not timeline or _has_notified_start:
		return
	if timeline.get_current_time() >= start_time:
		_has_notified_start = true
		reached_start_time.emit(self)
