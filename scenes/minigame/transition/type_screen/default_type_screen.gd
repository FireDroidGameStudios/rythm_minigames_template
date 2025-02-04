extends CanvasLayer


const SCALE_SPEED: float = 8.0
const SCALE_AMPLITUDE: float = 0.04

var time: float = 0.0


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	%Icon.scale = Vector2.ONE + Vector2.ONE * sin(time * SCALE_SPEED) * SCALE_AMPLITUDE
	time += delta


func _physics_process(delta: float) -> void:
	pass
