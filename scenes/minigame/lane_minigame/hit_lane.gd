@tool
class_name HitLane
extends Path2D


const HIT_RATIO_VISUALIZER: PackedScene = (
	preload("res://scenes/minigame/lane_minigame/hit_ratio_visualizer.tscn")
)

@export_range(0.0, 1.0, 0.001, "or_greater") var hit_ratio: float = 0.7

var _hit_ratio_visualizer: PathFollow2D = null


func _ready() -> void:
	_hit_ratio_visualizer = null
	#if Engine.is_editor_hint():
		#_hit_ratio_visualizer = HIT_RATIO_VISUALIZER.instantiate()
		#add_child(_hit_ratio_visualizer)
	_hit_ratio_visualizer = HIT_RATIO_VISUALIZER.instantiate()	# DEBUG
	add_child(_hit_ratio_visualizer)							# DEBUG
	_hit_ratio_visualizer.progress_ratio = hit_ratio			# DEBUG


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_hit_ratio_visualizer.progress_ratio = hit_ratio


func _physics_process(delta: float) -> void:
	pass
