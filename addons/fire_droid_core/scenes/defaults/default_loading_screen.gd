extends FDLoadingScreen


var _text_dot_count: int = 0


func _process(delta: float) -> void:
	%LabelProgress.set_text(str(%TextureProgressBar.value) + '%')


func _on_started() -> void:
	%TextureProgressBar.set_value(0)
	%LabelProgress.set_text("0%")


func _on_finished(has_failures: bool) -> void:
	print("called _on_finished!")


func _on_failed() -> void:
	print("called _on_failed!")


func _on_progress_changed(progress: float) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(%TextureProgressBar, "value", int(progress * 100), 0.8)


func _on_timer_timeout() -> void:
	%LabelLoading.set_text("Loading" + ".".repeat(_text_dot_count))
	_text_dot_count = (_text_dot_count + 1) % 4 # Reset after 3 dots
