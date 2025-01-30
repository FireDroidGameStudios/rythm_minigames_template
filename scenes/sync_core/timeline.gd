class_name Timeline
extends Node


@export var audio_player: AudioStreamPlayer = null

## Sorted array of HitObjects. Sorting takes spawn_time as value to sort.
var _hit_objects: Array[HitObject] = []

@onready var level: Level = get_parent()


func _ready() -> void:
	set_process(false)
	set_physics_process(false)


func _process(delta: float) -> void:
	_handle_spawns()


func _physics_process(delta: float) -> void:
	pass


func start() -> void:
	set_process(true)
	print("Starting timeline")


func get_current_time() -> float:
	if not audio_player:
		return 0.0
	return audio_player.get_playback_position()


func set_hit_objects(hit_objects: Array[HitObject]) -> void:
	_hit_objects = hit_objects
	_hit_objects.sort_custom(
		func(a, b): return a.get_spawn_time() < b.get_spawn_time()
	)
	_handle_timeline_refs()


func get_hit_objects() -> Array[HitObject]:
	return _hit_objects


func add_hit_object(hit_object: HitObject) -> void:
	_hit_objects.append(hit_object)


func get_hit_object(index: int) -> HitObject:
	if index >= _hit_objects.size() or index <= -_hit_objects.size():
		return null
	return _hit_objects[index]


func _handle_timeline_refs() -> void:
	for hit_object: HitObject in _hit_objects:
		hit_object.timeline = self
		hit_object.reached_hit_time.connect(
			func(object: HitObject): print(">> Hit: ", hit_object)
		)


func _handle_spawns() -> void:
	for hit_object: HitObject in _hit_objects:
		if hit_object.get_spawn_time() > get_current_time():
			return # Reached end of timeline time
		elif not hit_object.has_spawned():
			hit_object.spawn()
			var current_minigame: Minigame = level.current_minigame()
			if not current_minigame:
				FDCore.warning(
					"Timeline: Couldn't spawn HitObject because no minigame was set! "
				)
				return
			current_minigame.spawn_hit_object(hit_object)


func _insert_hit_object_sorted(hit_object: HitObject) -> void:
	hit_object.timeline = self
	hit_object.reached_hit_time.connect(
		func(object: HitObject): print(">> Hit: ", hit_object)
	)
	var index = 0
	var spawn_time: float = hit_object.get_spawn_time()
	var aux_spawn_time: float = _hit_objects[index].get_spawn_time()
	while index < _hit_objects.size() and aux_spawn_time < spawn_time:
		index += 1
		aux_spawn_time = _hit_objects[index].get_spawn_time()
	_hit_objects.insert(index, hit_object)
