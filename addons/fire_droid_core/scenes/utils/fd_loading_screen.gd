class_name FDLoadingScreen
extends Control


signal finished(has_failures: bool, aborted: bool)

@export var ending_delay: float = 0.0


func _enter_tree() -> void:
	FDLoad.started.connect(_handle_on_started)
	FDLoad.finished.connect(_handle_on_finished)
	FDLoad.failed.connect(_handle_on_failed)
	FDLoad.progress_changed.connect(_handle_on_progress_changed)


func _exit_tree() -> void:
	FDLoad.started.disconnect(_handle_on_started)
	FDLoad.finished.disconnect(_handle_on_finished)
	FDLoad.failed.disconnect(_handle_on_failed)
	FDLoad.progress_changed.disconnect(_handle_on_progress_changed)


func _handle_on_started() -> void:
	_on_started()


func _handle_on_finished(has_failures: bool) -> void:
	if not is_zero_approx(ending_delay):
		await get_tree().create_timer(ending_delay).timeout
	_on_finished(has_failures)
	finished.emit(has_failures, false)


func _handle_on_failed() -> void:
	if not is_zero_approx(ending_delay):
		await get_tree().create_timer(ending_delay).timeout
	_on_failed()
	finished.emit(true, true)


func _handle_on_progress_changed(progress: float) -> void:
	_on_progress_changed(progress)


func _on_started() -> void:
	pass


func _on_finished(has_failures: bool) -> void:
	pass


func _on_failed() -> void:
	pass


func _on_progress_changed(progress: float) -> void:
	pass
