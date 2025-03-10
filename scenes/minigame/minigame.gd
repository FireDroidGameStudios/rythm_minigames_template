class_name Minigame
extends Node2D


enum Type {
	UNDEFINED = -1,
	SINGLE_KEY,
	MULTI_KEY,
	CLICK,
}
enum HitPrecision {
	OK,
	GOOD,
	EXCELENT,
	PERFECT,
}


signal failed_hit
signal success_hit(ratios: Dictionary)
signal missed_hit(hit_object: HitObject)


var level: Level = null

var _is_enabled: bool = false


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


static func calculate_hit_precision(ratio: float) -> HitPrecision:
	if ratio >= 1.0:
		return HitPrecision.PERFECT
	elif ratio > 0.60:
		return HitPrecision.EXCELENT
	elif ratio > 0.25:
		return HitPrecision.GOOD
	return HitPrecision.OK


func spawn_hit_object(hit_object: HitObject) -> void:
	_on_spawn_hit_object(hit_object)


func is_enabled() -> bool:
	return _is_enabled


func enable() -> void:
	_is_enabled = true
	set_visible(true)


func disable() -> void:
	_is_enabled = false
	set_visible(false)


func get_minigame_type() -> Type:
	return _get_minigame_type()


func get_hit_score_popup(
	precision: HitPrecision, additional_args: Dictionary = {}
) -> ScorePopup:
	return _get_hit_score_popup(precision, additional_args)


func get_miss_score_popup(additional_args: Dictionary = {}) -> ScorePopup:
	return _get_miss_score_popup(additional_args)


func get_fail_score_popup(additional_args: Dictionary = {}) -> ScorePopup:
	return _get_fail_score_popup(additional_args)


# Overridable
func _get_hit_score_popup(
	precision: HitPrecision, additional_args: Dictionary = {}
) -> ScorePopup:
	const DEFAULT_SCENE: PackedScene = preload(
		"res://scenes/minigame/score/score_popup_text.tscn"
	)
	const DEFAULT_TEXT: Dictionary = {
		HitPrecision.OK: ["Ok", "Acceptable", "Meh!"],
		HitPrecision.GOOD: ["Good!", "Nice!", "Very Good!"],
		HitPrecision.EXCELENT: ["Excelent!", "Wow!", "Insane!"],
		HitPrecision.PERFECT: ["Perfect!", "Ultimate!", "Flawless!", "Absolute!"],
	}
	const DEFAULT_LABEL_SETTINGS: Dictionary = {
		HitPrecision.OK: ScorePopupText.DEFAULT_LABEL_SETTINGS_HIT_OK,
		HitPrecision.GOOD: ScorePopupText.DEFAULT_LABEL_SETTINGS_HIT_GOOD,
		HitPrecision.EXCELENT: ScorePopupText.DEFAULT_LABEL_SETTINGS_HIT_EXCELENT,
		HitPrecision.PERFECT: ScorePopupText.DEFAULT_LABEL_SETTINGS_HIT_PERFECT,
	}
	var popup: ScorePopup = DEFAULT_SCENE.instantiate()
	popup.set_text(DEFAULT_TEXT[precision].pick_random())
	popup.set_label_settings(DEFAULT_LABEL_SETTINGS[precision])
	return popup


# Overridable
func _get_miss_score_popup(additional_args: Dictionary = {}) -> ScorePopup:
	const DEFAULT_SCENE: PackedScene = preload(
		"res://scenes/minigame/score/score_popup_text.tscn"
	)
	var popup: ScorePopup = DEFAULT_SCENE.instantiate()
	popup.set_text(["Miss!", "Missed!", "Vanished!"].pick_random())
	popup.set_label_settings(ScorePopupText.DEFAULT_LABEL_SETTINGS_HIT_MISS)
	return popup


# Overridable
func _get_fail_score_popup(additional_args: Dictionary = {}) -> ScorePopup:
	const DEFAULT_SCENE: PackedScene = preload(
		"res://scenes/minigame/score/score_popup_text.tscn"
	)
	var popup: ScorePopup = DEFAULT_SCENE.instantiate()
	popup.set_text(["Fail!", "Failed!", "Oops", "Misclick??"].pick_random())
	popup.set_label_settings(ScorePopupText.DEFAULT_LABEL_SETTINGS_HIT_FAIL)
	return popup


func _on_spawn_hit_object(hit_object: HitObject) -> void:
	add_child(hit_object)


func _get_minigame_type() -> Type:
	return Type.UNDEFINED


func _get_transition_type_screen_scene() -> PackedScene:
	return null
