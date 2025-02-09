extends ClickableHitObject


func _on_despawn(is_missed: bool) -> void:
	super._on_despawn(is_missed)
	if not timeline:
		return
	var level: Level = timeline.get_parent()
	if not level:
		return
	level.play_sound_effect(preload("res://test/bubble_pop_04.wav"))
