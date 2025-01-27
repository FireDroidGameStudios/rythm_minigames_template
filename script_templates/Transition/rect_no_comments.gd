# meta-name: Transition with rects (color or texture, no comments)
# meta-description: Template to create custom transitions compatible with FDCore
# meta-default: true
# meta-space-indent: 4
@tool
#class_name NameTransition
extends Transition


#const CUSTOM_SHADER: Shader = (
	#preload("shader_path")
#)

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
	material = ShaderMaterial.new()
	#material.set_shader(CUSTOM_SHADER)
	material.set_shader(load("custom_shader_path"))
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
	trans_type_in = Tween.TRANS_CUBIC
	trans_type_out = Tween.TRANS_CUBIC
	ease_type_out = Tween.EASE_OUT


func _ready() -> void:
	_color_rect.set_visible(mode == Mode.COLOR)
	_texture_rect.set_visible(mode == Mode.TEXTURE)


func _process(_delta: float) -> void:
	_update_screen_size()


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
	material.set_shader_parameter("shader_progress_parameter", thereshold)


func _update_screen_size() -> void:
	var screen_size: Vector2i = get_viewport_rect().size
	material.set_shader_parameter("screen_width", screen_size.x)
	material.set_shader_parameter("screen_height", screen_size.y)
