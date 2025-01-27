@tool
class_name FadeTransition
extends Transition


enum Mode { COLOR, TEXTURE }

@export var mode: Mode = Mode.COLOR:
	set = set_mode
@export var color: Color = Color(0, 0, 0):
	set = set_color
@export var texture: Texture = null:
	set = set_texture
@onready var _color_rect: ColorRect = get_node("ColorRect")
@onready var _texture_rect: TextureRect = get_node("TextureRect")


func _init() -> void:
	if not has_node("ColorRect"):
		_color_rect = ColorRect.new()
		_color_rect.set_color(color)
		_color_rect.set_name("ColorRect")
		add_child(_color_rect)
		_color_rect.set_anchors_preset(PRESET_FULL_RECT)
	if not has_node("TextureRect"):
		_texture_rect = TextureRect.new()
		_texture_rect.set_texture(texture)
		_texture_rect.set_name("TextureRect")
		add_child(_texture_rect)
		_texture_rect.set_anchors_preset(PRESET_FULL_RECT)


func set_mode(new_mode: Mode) -> void:
	mode = new_mode
	if _color_rect:
		_color_rect.set_visible(mode == Mode.COLOR)
	if _texture_rect:
		_texture_rect.set_visible(mode == Mode.TEXTURE)


func set_color(new_color: Color) -> void:
	color = new_color
	if _color_rect:
		_color_rect.set_color(color)


func set_texture(new_texture: Texture) -> void:
	texture = new_texture
	if _texture_rect:
		_texture_rect.set_texture(new_texture)


func _on_transition_step(thereshold: float) -> void:
	modulate.a = _thereshold
