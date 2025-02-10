class_name ClickableHitObject
extends HitObject


signal clicked(object: ClickableHitObject, ratio: float)


const CLICK_RATIO_WEIGHT: float = 1.0
const TIME_RATIO_WEIGHT: float = 1.0


## The radius of the clickable area that detects mouse click. If mouse click is
## detected, signal [signal clicked] is emitted with the ratio of click passed
## as parameter.
@export_range(0.0, 300.0, 0.1, "or_greater")
var clickable_radius: float = 40.0

## The tolerance to check if mouse click was perfect (center of HitObject).
## [br][br]Increase this value will make more easy to do a perfect click.
@export_range(0.0, 300.0, 0.1, "or_greater")
var perfect_click_tolerance: float = 20.0

var spawn_position: Vector2 = Vector2(0, 0)

@onready var clickable_area: ClickableHitObjectArea = (
	get_node("ClickableHitObjectArea")
)


func _init(
	hit_time: float = 0.0, speed: float = 0.5,
	clickable_radius: float = 0.0, perfect_click_tolerance: float = 0.0
) -> void:
	self.hit_time = hit_time
	self.speed = speed
	self.clickable_radius = clickable_radius
	self.perfect_click_tolerance = perfect_click_tolerance


func _ready() -> void:
	super._ready()


func _process(delta: float) -> void:
	super._process(delta)
	_update_click_visualizer(get_ratio())


func _to_string() -> String:
	var string: String = (
		"(HitTime:%.3f|Speed:%.3f|SpawnTime:%.3f|Radius:%.3f|Tolerance:%.3f)" % [
			hit_time, speed, get_spawn_time(),
			clickable_radius, perfect_click_tolerance
		]
	)
	return string


## Return the ratio value (between 0.0 and 1.0) for the distance to the mouse
## global position.
func get_mouse_ratio() -> float:
	var distance: float = global_position.distance_to(get_global_mouse_position())
	return clamp(
		remap(
			distance - perfect_click_tolerance,
			0.0, clickable_radius, 1.0, 0.0
		), 0.0, 1.0
	)


## Return the calculated ratio (between 0.0 and 1.0) applying the weights for
## mouse and time ratios.
func get_final_ratio() -> float:
	var mouse_ratio: float = get_mouse_ratio()
	var time_ratio: float = clamp(get_ratio(), 0.0, 1.0)
	var total_ratio: float = (
		(mouse_ratio * CLICK_RATIO_WEIGHT) + (time_ratio * TIME_RATIO_WEIGHT)
	) / (CLICK_RATIO_WEIGHT + TIME_RATIO_WEIGHT)
	return total_ratio


## Return [code]true[/code] if the mouse is inside the clickable area, or
## [code]false[/code] if not.[br][br]If there is no child of type
## [ClickableHitObjectArea] named [code]"ClickableHitObjectArea"[/code], this
## method returns [code]false[/code].
func is_mouse_over() -> bool:
	if not clickable_area:
		return false
	return clickable_area.has_mouse_entered()


## Call the overridable method [method _on_clicked] passing the [param ratio]
## as argument.
func trigger_click(ratio: float) -> void:
	await _on_clicked(ratio)


# Overridable
func _on_clicked(ratio: float) -> void:
	print("Clicked with ratio ", ratio)


# Overridable
func _update_click_visualizer(ratio: float) -> void:
	pass
