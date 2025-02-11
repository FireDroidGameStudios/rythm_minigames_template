class_name LaneMinigame
extends Minigame


var _hit_areas_groups: Dictionary = {} # Grouped by input_action: {&"action": [area1, area2, ...]}

@onready var lanes: Node2D = get_node("Lanes")
@onready var hit_areas: Node2D = get_node("HitAreas")


func _ready() -> void:
	_setup_hit_areas()


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	_handle_input()


func _on_spawn_hit_object(hit_object: HitObject) -> void:
	var lane_index: int = (hit_object as LaneHitObject).lane_index
	var lane: HitLane = lanes.get_child(lane_index)
	if not lane:
		FDCore.warning(
			"LaneMinigame: Lane with index "
			+ str(lane_index)
			+ " not found! Spawn aborted."
		)
		return
	var lane_follower: LaneFollower = LaneFollower.new(
		hit_object, lane, level
	)
	lane_follower.speed = hit_object.speed
	lane.add_child(lane_follower)
	hit_object.target_ratio = lane.hit_ratio
	lane_follower.add_child(hit_object)
	hit_object.reached_full_ratio.connect(func(): missed_hit.emit(hit_object))


func _setup_hit_areas() -> void:
	for hit_area: LaneHitArea in hit_areas.get_children():
		if not _hit_areas_groups.has(hit_area.input_action):
			_hit_areas_groups[hit_area.input_action] = []
		_hit_areas_groups[hit_area.input_action].append(hit_area)


func _handle_input() -> void:
	for input_action: StringName in _hit_areas_groups.keys():
		if not Input.is_action_just_pressed(input_action):
			continue
		var detected_hits: Dictionary = {}
		for hit_area: LaneHitArea in _hit_areas_groups[input_action]:
			detected_hits.merge(hit_area.attempt_hit())
		if detected_hits.is_empty():
			failed_hit.emit()
			return
		success_hit.emit(detected_hits)
