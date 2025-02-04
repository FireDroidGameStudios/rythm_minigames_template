class_name MinigameTransitionInfo
extends Resource


@export_range(0.0, 60.0, 0.01, "or_greater") var start_time: float = 0.0
@export_range(0.0, 3.0, 0.01, "or_greater") var type_screen_duration: float = 2.0
@export_file("*.gd") var scene_path: String = (
	"res://addons/fire_droid_core/scenes/transitions/diamonds_transition.gd"
)
@export var additional_args: Dictionary = {}

@export_group("Transition In")
## Trans type of tween when appearing. See [enum Tween.TransitionType].
@export var trans_type_in: Tween.TransitionType = Tween.TRANS_CUBIC
## Ease type of tween when appearing. See [enum Tween.EaseType].
@export var ease_type_in: Tween.EaseType = Tween.EASE_OUT
## Duration of transition when appearing.
@export_range(0.0, 1.0, 0.01, "or_greater") var duration_in: float = 0.5

@export_group("Transition Out")
## Trans type of tween when disappearing. See [enum Tween.TransitionType].
@export var trans_type_out: Tween.TransitionType = Tween.TRANS_CUBIC
## Ease type of tween when disappearing. See [enum Tween.EaseType].
@export var ease_type_out: Tween.EaseType = Tween.EASE_OUT
## Duration of transition when disappearing.
@export_range(0.0, 1.0, 0.01, "or_greater") var duration_out: float = 0.5
