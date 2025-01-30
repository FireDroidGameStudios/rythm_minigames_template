class_name Level
extends Node


signal finished_minigames


@export var _hit_objects_infos: Array[HitObjectInfo] = []

var _current_minigame_index: int = 0

@onready var timeline: Timeline = get_node("Timeline")
@onready var audio_player: AudioStreamPlayer = get_node("AudioStreamPlayer")
@onready var minigames: Node = get_node("Minigames")


func _ready() -> void:
	start()
	pass


func _process(delta: float) -> void:
	$LabelTime.text = "Time: " + str(timeline.get_current_time()) + "s"


func _physics_process(delta: float) -> void:
	pass


func start() -> void:
	if minigames.get_child_count() == 0:
		FDCore.warning("Level: Could not start level because it has no minigames.")
		return
	for minigame: Minigame in minigames.get_children():
		minigame.level = self
	await _update_timeline_hit_objects()
	_current_minigame_index = 0
	_change_to_minigame(_current_minigame_index)
	audio_player.play()
	timeline.start()


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


func _update_timeline_hit_objects() -> void:
	var index: int = 0
	var hit_objects: Array[HitObject] = []
	hit_objects.resize(_hit_objects_infos.size())
	for info: HitObjectInfo in _hit_objects_infos:
		#var hit_object: LaneHitObject = LaneHitObject.new()
		print("Attempting to load \"" + info.scene_path + "\"")
		var loaded_object = load(info.scene_path)
		if loaded_object == null:
			FDCore.warning("Could not load scene \"" + info.scene_path + "\"")
			continue
		var hit_object = (loaded_object as PackedScene).instantiate()
		hit_object.hit_time = info.hit_time
		hit_object.speed = info.speed
		hit_object.lane_index = info.lane_index
		hit_objects[index] = hit_object
		index += 1
	print(hit_objects)
	timeline.set_hit_objects(hit_objects)
