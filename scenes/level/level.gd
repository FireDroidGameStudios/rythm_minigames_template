class_name Level
extends Node


signal finished_minigames


@export var _hit_objects_infos: Array[HitObjectInfo] = []

var _current_minigame_index: int = 0

@onready var timeline: Timeline = get_node("Timeline")
@onready var audio_player: AudioStreamPlayer = get_node("AudioStreamPlayer")
@onready var minigames: Node = get_node("Minigames")


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func start() -> void:
	pass


func current_minigame() -> Minigame:
	if _current_minigame_index >= minigames.get_child_count():
		return null
	return minigames.get_child(_current_minigame_index)


func go_to_next_minigame() -> void:
	if _current_minigame_index + 1 >= minigames.get_child_count():
		finished_minigames.emit()
		return
	FDCore.set_default_transition(
		minigames.get_child(_current_minigame_index + 1).get_transition()
	)
	await FDCore.play_transition(
		_change_to_minigame, [_current_minigame_index + 1], true
	)
	_current_minigame_index += 1


func _change_to_minigame(index: int) -> void:
	for minigame: Minigame in minigames.get_children():
		minigame.disable()
	minigames.get_child(index).enable()
