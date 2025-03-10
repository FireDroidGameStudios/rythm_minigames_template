class_name Level
extends Node


const MIN_HIT_SCORE: float = 50.0
const MAX_HIT_SCORE: float = 100.0
const ULTRA_HIT_SCORE: float = 150.0
const COMBO_MULTIPLIER_INCREMENT: float = 0.1
const DEFAULT_COMBO_MULTIPLIER: float = 1.0
const MAX_COMBO_MULTIPLIER: float = 2.0
const COMBO_MULTIPLIER_COUNT_TO_MAX: float = (
	(MAX_COMBO_MULTIPLIER - DEFAULT_COMBO_MULTIPLIER) / float(COMBO_MULTIPLIER_INCREMENT)
)


signal finished


@export var _hit_objects_infos: Array[HitObjectInfo] = []
@export var _transition_infos: Array[MinigameTransitionInfo] = []

var _combo_multiplier: float = 1.0
var _current_combo: int = 0
var _max_combo: int = 0

var _current_minigame_index: int = 0
var _played_first_transition: bool = false
var _is_playing_transition: bool = false
var _score: Dictionary = {} # {minigame_index: {&"hit": [], &"miss": int, &"fail": int}, ...}

@onready var timeline: Timeline = get_node("Timeline")
@onready var music_player: AudioStreamPlayer = get_node("MusicPlayer")
@onready var minigames: Node = get_node("Minigames")
@onready var score_popups: Node = get_node("ScorePopups")
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
		minigame.missed_hit.connect(_on_minigame_missed_hit.bind(minigame))
		minigame.success_hit.connect(_on_minigame_success_hit.bind(minigame))
		minigame.failed_hit.connect(_on_minigame_failed_hit.bind(minigame))
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
	_is_playing_transition = true
	await FDCore.play_transition(
		func(): type_scene_root.add_child(type_screen), [], true
	)
	go_to_next_minigame()
	await get_tree().create_timer(transition.type_screen_duration).timeout
	await FDCore.play_transition(type_screen.queue_free, [], true)
	_is_playing_transition = false
	FDCore.log_message("Finished transition to next minigame!", "cyan")


func go_to_next_minigame() -> void:
	if _current_minigame_index + 1 >= minigames.get_child_count():
		finish()
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


func get_combo_multiplier() -> float:
	return _combo_multiplier


func get_max_combo() -> int:
	return _max_combo


func finish() -> void:
	finished.emit()
	_on_finished()


func spawn_score_popup(popup: ScorePopup, origin: Vector2) -> void:
	score_popups.add_child(popup)
	popup.global_position = origin
	popup.play()


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


# Overridable
func _calculate_score() -> float:
	var total_score: float = 0.0
	for score: Dictionary in _score.values():
		var hits_score: float = 0.0
		for hit_info: Dictionary in score.get(&"hit", []):
			var ratio: float = hit_info[&"ratio"]
			var is_perfect_hit: float = (
				hit_info[&"precision"] == Minigame.HitPrecision.PERFECT
			)
			if is_perfect_hit:
				hits_score += ratio * ULTRA_HIT_SCORE
			else:
				hits_score += cubic_interpolate(
					MIN_HIT_SCORE, MAX_HIT_SCORE, 0.5, 0.5, ratio
				)
		# <-- Here can handle hits_score for each minigame individually
		total_score += hits_score
	return total_score


# Overridable
func _handle_combo_change(old_combo: int, old_multiplier: float) -> void:
	FDCore.log_message(
		"Current combo: " + str(_current_combo) + "(max: " + str(_max_combo)
		+ ") | Combo multiplier: " + str(_combo_multiplier), "orange"
	)


# Overridable
func _on_finished() -> void:
	FDCore.log_message("Level: Level Finished!", "purple")
	FDCore.log_message("Level: Score: " + str(_score), "purple")
	FDCore.log_message(
		"Level: Total Score: " + str(_calculate_score()), "purple"
	)


func _set_current_combo(new_combo: int) -> void:
	var old_combo: int = _current_combo
	var old_multiplier: float = _combo_multiplier
	_current_combo = new_combo
	_max_combo = max(_max_combo, _current_combo)
	_combo_multiplier = clamp(
		remap(
			_current_combo, 0, COMBO_MULTIPLIER_COUNT_TO_MAX,
			DEFAULT_COMBO_MULTIPLIER, MAX_COMBO_MULTIPLIER
		),
		DEFAULT_COMBO_MULTIPLIER, MAX_COMBO_MULTIPLIER
	)
	if not old_combo == _current_combo:
		_handle_combo_change(old_combo, old_multiplier)


func _add_hits_to_score(ratios: Dictionary) -> void:
	if not _score.has(_current_minigame_index):
		_score[_current_minigame_index] = { &"hit": [], &"miss": 0, &"fail": 0 }
	_score[_current_minigame_index][&"hit"].append_array(ratios.values())
	_set_current_combo(_current_combo + 1)


func _add_miss_to_score() -> void:
	if not _score.has(_current_minigame_index):
		_score[_current_minigame_index] = { &"hit": [], &"miss": 0, &"fail": 0 }
	_score[_current_minigame_index][&"miss"] += 1
	_set_current_combo(0)


func _add_fail_to_score() -> void:
	if not _score.has(_current_minigame_index):
		_score[_current_minigame_index] = { &"hit": [], &"miss": 0, &"fail": 0 }
	_score[_current_minigame_index][&"fail"] += 1
	_set_current_combo(0)


func _on_minigame_missed_hit(hit_object: HitObject, minigame: Minigame) -> void:
	if not minigame.is_enabled() or _is_playing_transition:
		return
	FDCore.log_message("Missed hit!", "orange")
	_add_miss_to_score()
	spawn_score_popup(
		minigame.get_miss_score_popup(), hit_object.global_position # Experimental
	)
	remove_hit_object_from_timeline(hit_object, true)


func _on_minigame_success_hit(ratios: Dictionary, minigame: Minigame) -> void:
	if not minigame.is_enabled() or _is_playing_transition:
		return
	FDCore.log_message("Success hit! Hit count: " + str(ratios.size()), "green")
	_add_hits_to_score(ratios)
	for hit_object: HitObject in ratios.keys():
		var hit_info: Dictionary = ratios[hit_object]
		await spawn_score_popup(
			minigame.get_hit_score_popup(hit_info[&"precision"]),
			hit_object.global_position
		)
		remove_hit_object_from_timeline(hit_object, false)


func _on_minigame_failed_hit(minigame: Minigame) -> void:
	if not minigame.is_enabled() or _is_playing_transition:
		return
	FDCore.log_message("Failed hit!", "red")
	spawn_score_popup(minigame.get_fail_score_popup(), Vector2(0, 0)) # Experimental
	_add_fail_to_score()


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
	_is_playing_transition = true
	await get_tree().create_timer(
		initial_transition_info.type_screen_duration
	).timeout
	FDCore.log_message("Finished type_screen timer!", "cyan")
	FDCore.set_default_transition(timeline.get_transition(0).transition)
	FDCore.log_message("Starting type_screen transition...", "cyan")
	await FDCore.play_transition(func(): type_screen.queue_free(), [], true)
	_is_playing_transition = false
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
