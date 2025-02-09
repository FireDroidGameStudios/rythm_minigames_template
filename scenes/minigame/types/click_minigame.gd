class_name ClickMinigame
extends Minigame


@onready var hit_objects: Node2D = get_node("HitObjects")


func _get_minigame_type() -> Type:
	return Type.CLICK


func _on_spawn_hit_object(hit_object: HitObject) -> void:
	hit_objects.add_child(hit_object)
	hit_object.global_position = (hit_object as ClickableHitObject).spawn_position
