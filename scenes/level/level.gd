class_name Level
extends Node


signal finished_minigames


@export var _hit_objects_infos: Array[HitObjectInfo] = []
@export var _transition_infos: Array[MinigameTransitionInfo] = []

var _current_minigame_index: int = 0
var _played_first_transition: bool = false

@onready var timeline: Timeline = get_node("Timeline")
@onready var music_player: AudioStreamPlayer = get_node("MusicPlayer")
@onready var minigames: Node = get_node("Minigames")
@onready var sound_effects: Node = get_node("SoundEffects")
@onready var type_scene_root: Node = get_node("TypeSceneRoot")
@onready var transition_objects: Node = get_node("TransitionObjects")


func _ready() -> void:
	_set_to_initial_type_screen()
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
		minigame.missed_hit.connect(_on_minigame_missed_hit)
		minigame.success_hit.connect(_on_minigame_success_hit)
		minigame.failed_hit.connect(_on_minigame_failed_hit)
	await _update_timeline_hit_objects()
	await _update_timeline_transitions()
	_current_minigame_index = 0
	_change_to_minigame(_current_minigame_index)
	timeline.start()
	music_player.play()
	_initial_transition()


func current_minigame() -> Minigame:
	if _current_minigame_index >= minigames.get_child_count():
		return null
	return minigames.get_child(_current_minigame_index)


func transition_to_next_minigame() -> void:
	FDCore.log_message("Starting transition to next minigame...", "cyan")
	var transition: MinigameTransition = (
		timeline.get_transition(_current_minigame_index + 1)
	)
	FDCore.set_default_transition(transition.transition)
	var type_screen_scene: PackedScene = (
		_get_transition_type_scene(
			get_minigame(_current_minigame_index + 1).get_minigame_type()
		)
	)
	var type_screen: CanvasLayer = type_screen_scene.instantiate()
	await FDCore.play_transition(
		func(): type_scene_root.add_child(type_screen), [], true
	)
	go_to_next_minigame()
	await get_tree().create_timer(transition.type_screen_duration).timeout
	await FDCore.play_transition(type_screen.queue_free, [], true)
	FDCore.log_message("Finished transition to next minigame!", "cyan")


func go_to_next_minigame() -> void:
	if _current_minigame_index + 1 >= minigames.get_child_count():
		finished_minigames.emit()
		return
	_current_minigame_index += 1
	_change_to_minigame(_current_minigame_index)


func remove_hit_object_from_timeline(hit_object: HitObject, is_missed: bool) -> void:
	timeline.remove_hit_object(hit_object, is_missed)


func play_sound_effect(sound_effect: AudioStream) -> void:
	if not sound_effect:
		return
	var sound_player: AudioStreamPlayer = AudioStreamPlayer.new()
	sound_player.stream = sound_effect
	sound_effects.add_child(sound_player)
	sound_player.play()
	await sound_player.finished
	sound_effects.remove_child(sound_player)
	sound_player.queue_free()


func get_minigame(index: int) -> Minigame:
	return minigames.get_child(index)


# Overridable
func _get_transition_type_scene(type: Minigame.Type) -> PackedScene:
	var index: int = 0
	if _played_first_transition:
		index = _current_minigame_index + 1
	if (
		index > minigames.get_child_count()
		or index <= -minigames.get_child_count()
	):
		return null
	#match minigames.get_child(index).get_type():
	match type:
		Minigame.Type.UNDEFINED:
			return preload(
				"res://scenes/minigame/transition/type_screen/undefined_type_screen.tscn"
			)
		Minigame.Type.SINGLE_KEY:
			return preload(
				"res://scenes/minigame/transition/type_screen/single_key_type_screen.tscn"
			)
		Minigame.Type.MULTI_KEY:
			return preload(
				"res://scenes/minigame/transition/type_screen/multi_key_type_screen.tscn"
			)
		Minigame.Type.CLICK:
			return preload(
				"res://scenes/minigame/transition/type_screen/click_type_screen.tscn"
			)
		_: return null


func _on_minigame_missed_hit(hit_object: HitObject) -> void:
	FDCore.log_message("Missed hit!", "orange")
	# <-- Here must calculate score or storage miss to later calculation
	remove_hit_object_from_timeline(hit_object, true)


func _on_minigame_success_hit(ratios: Dictionary) -> void:
	FDCore.log_message("Success hit! Hit count: " + str(ratios.size()), "green")
	for hit_object: HitObject in ratios.keys():
		# <-- Here must calculate score or storage ratio to later calculation
		remove_hit_object_from_timeline(hit_object, false)


func _on_minigame_failed_hit() -> void:
	FDCore.log_message("Failed hit!", "red")
	# <-- Here must calculate score or storage fail to later calculation


func _change_to_minigame(index: int) -> void:
	for minigame: Minigame in minigames.get_children():
		minigame.disable()
	minigames.get_child(index).enable()
	FDCore.log_message(
		"Changing to minigame " + Minigame.Type.keys()[index]
		+ " with type " + str(minigames.get_child(index).get_minigame_type())
	)


func _set_to_initial_type_screen() -> void:
	var type_screen: CanvasLayer = (
		_get_transition_type_scene(
			get_minigame(0)._get_minigame_type()
		).instantiate()
	)
	type_scene_root.add_child(type_screen)


func _initial_transition() -> void:
	var type_screen: CanvasLayer = type_scene_root.get_child(0)
	var initial_transition_info: MinigameTransitionInfo = _transition_infos[0]
	FDCore.log_message("Starting type_screen timer...", "cyan")
	await get_tree().create_timer(
		initial_transition_info.type_screen_duration
	).timeout
	FDCore.log_message("Finished type_screen timer!", "cyan")
	FDCore.set_default_transition(timeline.get_transition(0).transition)
	FDCore.log_message("Starting type_screen transition...", "cyan")
	await FDCore.play_transition(func(): type_screen.queue_free(), [], true)
	FDCore.log_message("Finished type_screen transition!", "cyan")


func _update_timeline_hit_objects() -> void:
	FDCore.log_message("Updating Timeline HitObjects...", "cyan")
	var index: int = 0
	var hit_objects: Array[HitObject] = []
	hit_objects.resize(_hit_objects_infos.size())
	for info: HitObjectInfo in _hit_objects_infos:
		var loaded_object = load(info.scene_path)
		if loaded_object == null:
			FDCore.warning("Could not load scene \"" + info.scene_path + "\"")
			continue
		var hit_object = (loaded_object as PackedScene).instantiate()
		hit_object.hit_time = info.hit_time
		hit_object.speed = info.speed
		if info.type == HitObjectInfo.Type.LANE:
			hit_object.lane_index = info.lane_index
		elif info.type == HitObjectInfo.Type.CLICK:
			hit_object.spawn_position = info.spawn_position
		hit_objects[index] = hit_object
		index += 1
	timeline.set_hit_objects(hit_objects)
	FDCore.log_message(
		"Updated Timeline HitObjects! Found "
		+ str(hit_objects.size()) + " HitObjects.", "cyan"
	)


func _update_timeline_transitions() -> void:
	var index: int = 0
	var transitions: Array[MinigameTransition] = []
	transitions.resize(_transition_infos.size())
	for info: MinigameTransitionInfo in _transition_infos:
		var transition: MinigameTransition = MinigameTransition.new()
		transition.update_transition(info)
		transitions[index] = transition
		index += 1
	print(transitions)
	timeline.set_transitions(transitions)
