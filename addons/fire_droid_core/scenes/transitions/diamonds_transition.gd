@tool
class_name DiamondsTransition
extends Transition


const DIAMONDS_SHADER: Shader = (
	preload("res://addons/fire_droid_core/shaders/transition_shaders/diamonds.gdshader")
)

enum Mode { COLOR, TEXTURE }

@export_range(0.01, 20.0, 0.01, "or_greater") var diamonds_size: float = 30.0:
	set = set_diamonds_size
@export var mode: Mode = Mode.COLOR:
	set = set_mode
@export var color: Color = Color(0, 0, 0):
	set = set_color
@export var texture: Texture = null:
	set = set_texture

@onready var _color_rect: ColorRect = get_node("ColorRect")
@onready var _texture_rect: TextureRect = get_node("TextureRect")


func _init() -> void:
	material = ShaderMaterial.new()
	material.set_shader(DIAMONDS_SHADER)
	if not has_node("ColorRect"):
		_color_rect = ColorRect.new()
		_color_rect.set_color(color)
		_color_rect.set_name("ColorRect")
		_color_rect.use_parent_material = true
		add_child(_color_rect)
		_color_rect.set_anchors_preset(PRESET_FULL_RECT)
	if not has_node("TextureRect"):
		_texture_rect = TextureRect.new()
		_texture_rect.set_texture(texture)
		_texture_rect.set_name("TextureRect")
		_texture_rect.use_parent_material = true
		add_child(_texture_rect)
		_texture_rect.set_anchors_preset(PRESET_FULL_RECT)


func set_diamonds_size(new_size: float) -> void:
	diamonds_size = new_size
	material.set_shader_parameter("diamond_pixel_size", diamonds_size)


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
	material.set_shader_parameter("progress", thereshold)
