class_name Timeline
extends Node


@export var audio_player: AudioStreamPlayer = null

## Sorted array of HitObjects. Sorting takes spawn_time as value to sort.
var _hit_objects: Array[HitObject] = []


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func get_current_time() -> float:
	if not audio_player:
		return 0.0
	return audio_player.get_playback_position()


func set_hit_objects(hit_objects: Array[HitObject]) -> void:
	_hit_objects = hit_objects
	_hit_objects.sort_custom(
		func(a, b): return a.get_spawn_time() > b.get_spawn_time()
	)


func get_hit_objects() -> Array[HitObject]:
	return _hit_objects


func add_hit_object(hit_object: HitObject) -> void:
	_hit_objects.append(hit_object)


func get_hit_object(index: int) -> HitObject:
	if index >= _hit_objects.size() or index <= -_hit_objects.size():
		return null
	return _hit_objects[index]


func _insert_hit_object_sorted(hit_object: HitObject) -> void:
	var index = 0
	while (
		index < _hit_objects.size()
		and _hit_objects[index].get_spawn_time() < hit_object.get_spawn_time()
	):
		index += 1
	_hit_objects.insert(index, hit_object)
