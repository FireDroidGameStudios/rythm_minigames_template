class_name LaneMinigame
extends Minigame


var level: Level = null

@onready var lanes: Node2D = get_node("Lanes")
@onready var hit_areas: Node2D = get_node("HitAreas")


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


func _on_spawn_hit_object(hit_object: HitObject, args: Dictionary = {}) -> void:
	var lane_index: int = (hit_object as LaneHitObject).lane_index
	var lane: HitLane = lanes.get_child(lane_index)
	if not lane:
		FDCore.warning(
			"LaneMinigame: Lane with index "
			+ str(lane_index)
			+ "not found! Spawn aborted."
		)
		return
	var lane_follower: LaneFollower = LaneFollower.new(
		hit_object, lane, level
	)
	lane_follower.speed = hit_object.speed
	lane.add_child(lane_follower)
	hit_object.target_ratio = lane.hit_ratio
	lane_follower.add_child(hit_object)
