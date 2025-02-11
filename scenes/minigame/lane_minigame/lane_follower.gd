class_name LaneFollower
extends PathFollow2D


@export_range(0.0, 1.0, 0.001, "or_greater") var speed: float = 0.5
@export var hit_object: LaneHitObject = null
@export var lane: HitLane = null
@export var level: Level = null

var _has_emitted_missed_signal: bool = false


func _init(hit_object: LaneHitObject, lane: HitLane, level: Level) -> void:
	rotates = false
	loop = false
	self.hit_object = hit_object
	self.lane = lane
	self.level = level


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if not hit_object or not level:
		return
	progress_ratio = hit_object.get_ratio()
	if progress_ratio >= 1.0 and not _has_emitted_missed_signal:
		_has_emitted_missed_signal = true
		hit_object.reached_full_ratio.emit()


func _physics_process(delta: float) -> void:
	pass
