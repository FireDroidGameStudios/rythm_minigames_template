class_name ScorePopup
extends Node2D


func play() -> void:
	await _play()
	queue_free()


# Overridable
func _play() -> void:
	var opacity_tween: Tween = get_tree().create_tween()
	opacity_tween.tween_property(self, "modulate:a", 1.0, 0.3).from(0.0)
	var position_tween: Tween = get_tree().create_tween()
	position_tween.set_trans(Tween.TRANS_CUBIC)
	randomize()
	position_tween.tween_property(
		self, "global_position",
		global_position + Vector2(
			randi_range(20, 70) * [1, -1].pick_random(),
			-randi_range(20, 70)
		), 1.2
	)
	await opacity_tween.finished
	await get_tree().create_timer(0.4).timeout
	opacity_tween = get_tree().create_tween()
	opacity_tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await opacity_tween.finished
