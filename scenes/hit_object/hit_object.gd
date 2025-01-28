class_name HitObject
extends Node2D


## Time to [member ratio] reach the value of [member target_ratio]. Can define
## the speed of the HitObject and takes the level timeline as the time reference.
var hit_time: float = 0.0

## Speed of ratio increase, measured in ratio/seconds. This property also affects
## spawn time (see [method get_spawn_time]).
var speed: float = 0.5


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


func _to_string() -> String:
	var string: String = "(HitTime:%.3f|Speed:%.3f|SpawnTime:%.3f)" % [
		hit_time, speed, get_spawn_time()
	]
	return string


## Return the current ratio of HitObject based on [param current_time] and
## [member hit_time].
func get_ratio(current_time: float) -> float:
	return remap(current_time, get_spawn_time(), hit_time, 0.0, 1.0)


## Calculate and return the spawn time for this HitObject. The spawn time is
## the time moment (in seconds) that an HitObject can be spawned to reach the
## ratio [code]1.0[/code] at [member hit_time].
func get_spawn_time() -> float:
	if is_zero_approx(speed):
		return 0.0
	var total_time: float = 1.0 / speed
	var spawn_time: float = hit_time - (total_time / speed)
	if spawn_time < 0.0:
		return 0.0
	return spawn_time
