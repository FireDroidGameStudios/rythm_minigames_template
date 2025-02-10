extends ClickableHitObject


@onready var ratio_visualizer: Sprite2D = get_node("RatioVisualizer")


func _on_despawn(is_missed: bool) -> void:
	super._on_despawn(is_missed)
	if not timeline:
		return
	var level: Level = timeline.get_parent()
	if not level:
		return
	level.play_sound_effect(preload("res://test/bubble_pop_04.wav"))


func _update_click_visualizer(ratio: float) -> void:
	ratio_visualizer.scale = Vector2.ONE * (1.0 - clamp(ratio, 0.0, 1.0))
