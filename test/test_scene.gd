extends Node2D


var hit_objects: Array[HitObject] = [
	HitObject.new(4.07, 0.8),
	HitObject.new(4.9, 0.8),
	HitObject.new(5.7, 0.8),
	HitObject.new(6.5, 0.8),
	HitObject.new(7.3, 0.8),
	HitObject.new(8.2, 0.8),
	HitObject.new(9.0, 0.8),
]

@onready var timeline: Timeline = get_node("Timeline")


func _ready() -> void:
	timeline.set_hit_objects(hit_objects)


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass
