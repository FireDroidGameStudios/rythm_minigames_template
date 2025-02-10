class_name HitObject
extends Node2D


signal reached_hit_time(hit_object: HitObject)


## Time to [member ratio] reach the value of [member target_ratio]. Can define
## the speed of the HitObject and takes the level timeline as the time reference.
var hit_time: float = 0.0

## Ratio equivalent to time (in seconds) that the HitObject reaches [member hit_time].
## This must be a value between 0.0 and 1.0.
var target_ratio: float = 1.0

## Speed of ratio increase, measured in ratio/seconds. This property also affects
## spawn time (see [method get_spawn_time]).
var speed: float = 0.5


var timeline: Timeline = null


## Flag to quick check if HitObject has spawned. This flag must be set by Timeline
## when the object is spawned
var _has_spawned: bool = false

## Flag to quick check if HitObject has emitted hit signal.
var _has_notified_hit: bool = false


func _init(hit_time: float = 0.0, speed: float = 0.5) -> void:
	self.hit_time = hit_time
	self.speed = speed


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	_handle_signal_notify()


func _physics_process(_delta: float) -> void:
	pass


func _to_string() -> String:
	var string: String = "(HitTime:%.3f|Speed:%.3f|SpawnTime:%.3f)" % [
		hit_time, speed, get_spawn_time()
	]
	return string


## Despawn the object and free it. It is possible to customize despawn behaviour
## by overriding [method _on_despawn]. Parameter [param is_missed] allows to
## specify the reason of despawn (by a hit, when [param is_missed] is
## [code]false[/code], or when the player miss a hit, when [param is_missed]
## is [code]true[/code]).
func despawn(is_missed: bool) -> void:
	await _on_despawn(is_missed)
	queue_free()


## Sets the spawned flag. This is used by timeline to keep control of wich
## HitObjects have already spawned.
func spawn() -> void:
	_has_spawned = true


## Return the value of the spawned flag. This is used by timeline to keep
## control of wich HitObjects have already spawned.
func has_spawned() -> bool:
	return _has_spawned


## Return the current ratio of HitObject based on [param current_time] and
## [member hit_time].
func get_ratio() -> float:
	if not timeline:
		return 0.0
	return remap(
		timeline.get_current_time(),
		get_spawn_time(), hit_time, 0.0, target_ratio
	)


## Calculate and return the spawn time for this HitObject. The spawn time is
## the time moment (in seconds) that an HitObject can be spawned to reach the
## ratio [code]1.0[/code] at [member hit_time].
func get_spawn_time() -> float:
	return _get_spawn_time()


## [b]Overridable method.[/b][br][br]This method is called by [method despawn]
## and defines the behaviour of the HitObject during despawn, such as changing
## animation, emitting sound or any other custom action.[br][br]Parameter
## [param is_missed] allows to customize behaviour when the object is despawned
## by a hit (when [param is_missed] is [code]false[/code]) or when the player
## miss a hit (when [param is_missed] is [code]true[/code]).[br][br]Calling
## [method queue_free] inside this method may cause errors.
func _on_despawn(is_missed: bool) -> void:
	pass


func _get_spawn_time() -> float:
	if is_zero_approx(speed):
		return 0.0
	var spawn_time: float = hit_time - (target_ratio / speed)
	return max(spawn_time, 0.0)


func _handle_signal_notify() -> void:
	if not timeline or not _has_spawned or _has_notified_hit:
		return
	if timeline.get_current_time() >= hit_time:
		_has_notified_hit = true
		reached_hit_time.emit(self)
