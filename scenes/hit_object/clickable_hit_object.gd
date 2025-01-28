class_name ClickableHitObject
extends HitObject


signal clicked(ratio: float)


## The radius of the clickable area that detects mouse click. If mouse click is
## detected, signal [signal clicked] is emitted with the ratio of click passed
## as parameter.
@export_range(0.0, 300.0, 0.1, "or_greater")
var clickable_radius: float = 0.0

## The tolerance to check if mouse click was perfect (center of HitObject).
## [br][br]Increase this value will make more easy to do a perfect click.
@export_range(0.0, 300.0, 0.1, "or_greater")
var perfect_click_tolerance: float = 0.0


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var is_just_pressed: bool = event.is_pressed() and not event.is_echo()
		if event.button_index == MOUSE_BUTTON_LEFT and is_just_pressed:
			var click_distance: float = max(0.0, (
				get_global_mouse_position().distance_to(global_position)
			) - perfect_click_tolerance)
			var calculated_radius: float = clickable_radius - perfect_click_tolerance
			if click_distance <= calculated_radius:
				var click_ratio: float = 0.0
				if not is_zero_approx(calculated_radius):
					click_ratio = 1.0 - (click_distance / calculated_radius)
				clicked.emit(click_ratio)
