class_name HitObjectInfo
extends Resource


enum Type {
	UNDEFINED = -1,
	LANE,
	CLICK,
}


@export_range(0.0, 60.0, 0.01, "or_greater") var hit_time: float = 0.0
@export_range(0.0, 1.0, 0.001, "or_greater") var speed: float = 0.5
@export var type: Type = Type.UNDEFINED
@export_file("*.tscn") var scene_path: String = ""
@export var lane_index: int = 0 # Only for LANE mode
@export var spawn_position: Vector2 = Vector2(0, 0) # Only for CLICK mode
