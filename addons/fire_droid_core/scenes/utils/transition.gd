@tool
class_name Transition
extends Control
## An util class that simplifies the creation of transitions.
##
## This class is a simplified base-class to create custom transitions compatible
## with FDCore.[br]


signal started(status: Status)
signal finished(status: Status)

enum Status { IN, OUT }


@export_group("Transition In")
## Trans type of tween when appearing. See [enum Tween.TransitionType].
@export var trans_type_in: Tween.TransitionType = Tween.TRANS_LINEAR
## Ease type of tween when appearing. See [enum Tween.EaseType].
@export var ease_type_in: Tween.EaseType = Tween.EASE_IN
## Duration of transition when appearing.
@export_range(0.0, 5.0, 0.01, "or_greater") var duration_in: float = 1.2

@export_group("Transition Out")
## Trans type of tween when disappearing. See [enum Tween.TransitionType].
@export var trans_type_out: Tween.TransitionType = Tween.TRANS_LINEAR
## Ease type of tween when disappearing. See [enum Tween.EaseType].
@export var ease_type_out: Tween.EaseType = Tween.EASE_IN
## Duration of transition when disappearing.
@export_range(0.0, 5.0, 0.01, "or_greater") var duration_out: float = 1.2

@export_group("")
@export var _status: Status = Status.IN:
	set = set_forced_status
@export var _preview_animation: bool = false:
	set = _run_preview_animation

var _thereshold: float = 0.0:
	set(value):
		_thereshold = value
		_on_transition_step(_thereshold)

var _tweener: Tween = null


func _enter_tree() -> void:
	await get_tree().process_frame
	set_anchors_preset(PRESET_FULL_RECT)
	offset_left = 0
	offset_right = 0
	offset_bottom = 0
	offset_top = 0


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func play(custom: Dictionary) -> void:
	if _status == Status.IN:
		await play_in(custom)
	elif _status == Status.OUT:
		await play_out(custom)
	else:
		FDCore.warning("Attempt to play a transition with invalid status")


func play_in(custom: Dictionary) -> void:
	_set_custom(custom)
	_status = Status.IN
	started.emit(Status.IN)
	await _tween_thereshold(1.0, duration_in, ease_type_in, trans_type_in)
	_status = Status.OUT
	finished.emit(Status.IN)


func play_out(custom: Dictionary) -> void:
	_set_custom(custom)
	_status = Status.OUT
	started.emit(Status.IN)
	await _tween_thereshold(0.0, duration_out, ease_type_out, trans_type_out)
	_status = Status.IN
	finished.emit(Status.OUT)


func set_forced_status(new_status: Status) -> void:
	if _tweener:
		_tweener.stop()
		_tweener = null
	_status = new_status
	if _status == Status.IN:
		_thereshold = 0.0
	elif _status == Status.OUT:
		_thereshold = 1.0


func _on_transition_step(thereshold: float) -> void:
	pass


func _set_custom(custom: Dictionary) -> void:
	for property: StringName in custom.keys():
		if property == null: # Get only StringNames
			continue
		set(property, custom[property])


func _tween_thereshold(
	target_thereshold: float, duration: float,
	ease_type: Tween.EaseType, trans_type: Tween.TransitionType
) -> void:
	if _tweener:
		_tweener.stop()
	_tweener = get_tree().create_tween()
	_tweener.set_ease(ease_type)
	_tweener.set_trans(trans_type)
	_tweener.tween_property(self, "_thereshold", target_thereshold, duration)
	await _tweener.finished


func _run_preview_animation(_var: bool) -> void:
	_preview_animation = false
	if not Engine.is_editor_hint():
		return
	set_forced_status(_status)
	if _status == Status.IN:
		await _tween_thereshold(1.0, duration_in, ease_type_in, trans_type_in)
	elif _status == Status.OUT:
		await _tween_thereshold(0.0, duration_out, ease_type_out, trans_type_out)
