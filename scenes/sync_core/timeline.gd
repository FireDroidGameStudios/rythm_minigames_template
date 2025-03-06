class_name Timeline
extends Node


@export var audio_player: AudioStreamPlayer = null

## Sorted array of HitObjects. Sorting takes spawn_time as value to sort.
var _hit_objects: Array[HitObject] = []
var _transitions: Array[MinigameTransition] = []

@onready var level: Level = get_parent()


func _ready() -> void:
	set_process(false)
	set_physics_process(false)


func _process(delta: float) -> void:
	_handle_spawns()


func _physics_process(delta: float) -> void:
	pass


func start() -> void:
	_handle_transitions()
	if audio_player:
		audio_player.finished.connect(stop)
	set_process(true)


func stop() -> void:
	level.finish()
	set_process(false)


func get_current_time() -> float:
	if not audio_player:
		return 0.0
	return audio_player.get_playback_position()


func set_hit_objects(hit_objects: Array[HitObject]) -> void:
	_hit_objects = hit_objects
	_hit_objects.sort_custom(
		func(a, b): return a.get_spawn_time() < b.get_spawn_time()
	)
	for hit_object: HitObject in _hit_objects:
		hit_object.timeline = self
		#hit_object.reached_hit_time.connect(
			#func(object: HitObject): print(">> Hit: ", hit_object)
		#)


func set_transitions(transitions: Array[MinigameTransition]) -> void:
	_transitions = transitions
	_transitions.sort_custom(
		func(a, b): return a.start_time < b.start_time
	)
	for transition: MinigameTransition in _transitions:
		transition.timeline = self
		if is_zero_approx(transition.start_time):
			continue
		transition.reached_start_time.connect(level.transition_to_next_minigame)


func get_hit_objects() -> Array[HitObject]:
	return _hit_objects


func get_transitions() -> Array[MinigameTransition]:
	return _transitions


func add_hit_object(hit_object: HitObject) -> void:
	_insert_hit_object_sorted(hit_object)


func add_transition(transition: MinigameTransition) -> void:
	_insert_transition_sorted(transition)


func remove_hit_object(hit_object: HitObject, is_missed: bool) -> void:
	var found_index: int = _hit_objects.find(hit_object)
	if found_index == -1:
		return
	var found_object: HitObject = _hit_objects.pop_at(found_index)
	found_object.despawn(is_missed)


func remove_transition(transition) -> void:
	_transitions.erase(transition)


func get_hit_object(index: int) -> HitObject:
	if index >= _hit_objects.size() or index <= -_hit_objects.size():
		return null
	return _hit_objects[index]


func get_transition(index: int) -> MinigameTransition:
	return _transitions[index]


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
	var index = 0
	var spawn_time: float = hit_object.get_spawn_time()
	var aux_spawn_time: float = _hit_objects[index].get_spawn_time()
	while index < _hit_objects.size() and aux_spawn_time < spawn_time:
		index += 1
		aux_spawn_time = _hit_objects[index].get_spawn_time()
	_hit_objects.insert(index, hit_object)


func _handle_transitions() -> void:
	for transition: MinigameTransition in _transitions:
		level.transition_objects.add_child(transition)


func _insert_transition_sorted(transition: MinigameTransition) -> void:
	transition.timeline = self
	transition.reached_start_time.connect(level.transition_to_next_minigame)
	var index = 0
	var start_time: float = transition.start_time
	var aux_start_time: float = _transitions[index].start_time
	while index < _hit_objects.size() and aux_start_time < start_time:
		index += 1
		aux_start_time = _transitions[index].start_time
	_transitions.insert(index, transition)
