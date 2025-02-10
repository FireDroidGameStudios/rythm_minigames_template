class_name ClickMinigame
extends Minigame


@onready var hit_objects: Node2D = get_node("HitObjects")


func _physics_process(_delta: float) -> void:
	_handle_input()


func _get_minigame_type() -> Type:
	return Type.CLICK


func _on_spawn_hit_object(hit_object: HitObject) -> void:
	hit_objects.add_child(hit_object)
	hit_object.global_position = (hit_object as ClickableHitObject).spawn_position


func _handle_input() -> void:
	var is_just_pressed: bool = Input.is_action_just_pressed(&"click_hit")
	if not is_just_pressed:
		return
	var hovered_objects: Array[HitObject] = []
	for object: ClickableHitObject in hit_objects.get_children():
		if object.is_mouse_over():
			hovered_objects.append(object)
	hovered_objects.sort_custom(func(a, b): return a.hit_time < b.hit_time)
	var clicked_object: ClickableHitObject = hovered_objects.pop_front()
	if not clicked_object:
		failed_hit.emit()
		return
	success_hit.emit({clicked_object: clicked_object.get_final_ratio()})
