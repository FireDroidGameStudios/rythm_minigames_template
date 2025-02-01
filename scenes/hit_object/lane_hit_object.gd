class_name LaneHitObject
extends HitObject


@export var lane_index: int = 0


func _init(hit_time: float = 0.0, speed: float = 0.5, lane_index: int = 0) -> void:
	self.hit_time = hit_time
	self.speed = speed
	self.lane_index = lane_index


func _on_despawn(is_missed: bool) -> void:
	if get_parent() is LaneFollower:
		get_parent().queue_free()
