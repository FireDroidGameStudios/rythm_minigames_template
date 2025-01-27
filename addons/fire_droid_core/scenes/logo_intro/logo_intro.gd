@tool
extends Control


signal started
signal finished

@export var autoplay: bool = true
@export_range(-150.0, 150.0, 0.1, "or_greater", "or_less") var horizontal_margins: float = 0.0:
	set = _set_h_margins
@export_range(-150.0, 150.0, 0.1, "or_greater", "or_less") var vertical_margins: float = 0.0:
	set = _set_v_margins
@export var background_color: Color = Color.DIM_GRAY: ## Color of static background.
	set = _set_background_color

@export_group("Transition Overrides")
@export var transition_override_properties: Dictionary = {}

@export_group("Frames Options")
@export var frames: SpriteFrames: set = _set_frames ## Desired frames to be in the animation.
@export var auto_update_animation_frames: bool = false  ## Used only when editing logo intro
@export_range(1.0, 75.0, 0.1, "or_greater") var frame_rate: float = 60.0 ## Frame-rate of the animation.
@export_range(0.0, 5.0, 0.1, "or_greater") var initial_delay: float = 1.5
@export_range(0.0, 5.0, 0.1, "or_greater") var final_delay: float = 2.0

@export_group("Skip Options")
@export var can_be_skipped: bool = true
@export_range(0.0, 5.0, 0.1, "or_greater") var skip_lock_delay: float = 1.5
@export var skip_action: StringName = &"ui_cancel"

@export_group("Audio Options")
@export var audio_stream: AudioStream = null
@export_range(0.0, 5.0, 0.1, "or_greater") var audio_stream_delay: float = 0.0

var _can_skip: bool = false
var _has_been_skipped: bool = false

@onready var animation_player = get_node("AnimationPlayer")
@onready var audio_player = get_node("AudioStreamPlayer")
#region Timers
@onready var timer_start_animation = get_node("TimerStartAnimation")
@onready var timer_end_animation = get_node("TimerEndAnimation")
@onready var timer_play_sound = get_node("TimerPlaySound")
@onready var timer_skip_delay = get_node("TimerSkipDelay")
#endregion


func _ready() -> void:
	if not Engine.is_editor_hint():
		#timer_start_animation.timeout.connect(_start_animation)
		if not skip_action in InputMap.get_actions():
			FDCore.warning("Invalid skip_action on intro")
		animation_player.animation_finished.connect(_on_finished)
		animation_player.set_current_animation("default")
		animation_player.stop()
		if autoplay:
			play()


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action(skip_action) and _can_skip:
		if event.is_pressed() and not event.is_echo():
			skip()


func play() -> void:
	started.emit()
	if not animation_player:
		finished.emit()
		return

	# Initial Delay for animation
	if initial_delay > 0.0:
		timer_start_animation.start(initial_delay)
	else:
		_on_timer_start_animation_timeout()

	# Skip Lock Delay
	if skip_lock_delay > 0.0:
		_can_skip = false
		timer_skip_delay.start(skip_lock_delay)
	else:
		_on_timer_skip_delay_timeout()

	# Audio Stream Delay
	if audio_stream_delay > 0.0:
		timer_play_sound.start(audio_stream_delay)
	else:
		_on_timer_play_sound_timeout()


func skip() -> void:
	_has_been_skipped = true
	finished.emit()


func _set_background_color(new_color: Color) -> void:
	background_color = new_color
	$BackgroundColorRect.color = background_color


func _set_frames(new_frames: SpriteFrames) -> void:
	frames = new_frames
	if not auto_update_animation_frames:
		return
	FDCore.log_message(
		str(self) + ": Setting frames (count=%s)" % [str(new_frames.get_frame_count("default"))]
	)
	frames.changed.connect(_on_frames_changed)
	_update_animation()


func _set_h_margins(new_margins: float) -> void:
	horizontal_margins = new_margins
	$MarginContainer.set("theme_override_constants/margin_left", horizontal_margins)
	$MarginContainer.set("theme_override_constants/margin_right", horizontal_margins)


func _set_v_margins(new_margins: float) -> void:
	vertical_margins = new_margins
	$MarginContainer.set("theme_override_constants/margin_top", vertical_margins)
	$MarginContainer.set("theme_override_constants/margin_bottom", vertical_margins)


func _on_frames_changed() -> void:
	FDCore.log_message(
		str(self) + ": Frames changed! (count=%s)" % [str(frames.get_frame_count("default"))]
	)
	_update_animation()


func _update_animation() -> void:
	FDCore.log_message("Updating animation")
	var animation: Animation = $AnimationPlayer.get_animation("default")
	if animation == null:
		FDCore.log_message("Warning: Animation \"default\" doesn't exist! Creating it.", "yellow")
		animation = Animation.new()
	animation.clear()
	var anim_duration: float = (frames.get_frame_count("default") + 1) / frame_rate
	var frame_duration: float = anim_duration / (frames.get_frame_count("default") + 1)
	animation.set_length(anim_duration)
	var track_index: int = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "MarginContainer/TextureRect:texture")
	for i in frames.get_frame_count("default"):
		var frame_path = frames.get_frame_texture("default", i).resource_path
		var frame: CompressedTexture2D = load(frame_path)
		animation.track_insert_key(track_index, frame_duration * i, frame)
	var anim_library: AnimationLibrary = $AnimationPlayer.get_animation_library("")
	anim_library.add_animation("default", animation)


func _on_finished(_anim_name: String) -> void:
	if _has_been_skipped:
		finished.emit()
	else:
		timer_end_animation.start(final_delay)


func _on_timer_start_animation_timeout() -> void:
	animation_player.play("default")


func _on_timer_end_animation_timeout() -> void:
	FDCore.log_message(str(self) + ": Animation finished")
	finished.emit()


func _on_timer_play_sound_timeout() -> void:
	audio_player.play()


func _on_timer_skip_delay_timeout() -> void:
	_can_skip = true and can_be_skipped
