class_name ScorePopupText
extends ScorePopup


const DEFAULT_LABEL_SETTINGS_HIT_OK: LabelSettings = preload(
	"res://scenes/minigame/score/default_label_settings/default_label_settings_hit_ok.tres"
)
const DEFAULT_LABEL_SETTINGS_HIT_GOOD: LabelSettings = preload(
	"res://scenes/minigame/score/default_label_settings/default_label_settings_hit_good.tres"
)
const DEFAULT_LABEL_SETTINGS_HIT_EXCELENT: LabelSettings = preload(
	"res://scenes/minigame/score/default_label_settings/default_label_settings_hit_excelent.tres"
)
const DEFAULT_LABEL_SETTINGS_HIT_PERFECT: LabelSettings = preload(
	"res://scenes/minigame/score/default_label_settings/default_label_settings_hit_perfect.tres"
)
const DEFAULT_LABEL_SETTINGS_HIT_FAIL: LabelSettings = preload(
	"res://scenes/minigame/score/default_label_settings/default_label_settings_fail.tres"
)
const DEFAULT_LABEL_SETTINGS_HIT_MISS: LabelSettings = preload(
	"res://scenes/minigame/score/default_label_settings/default_label_settings_miss.tres"
)


var text: String = "":
	set = set_text
var label_settings: LabelSettings = null:
	set = set_label_settings

@onready var label: Label = get_node("Label")


func _ready() -> void:
	label.set_text(text)
	label.label_settings = label_settings


func set_text(value: String) -> void:
	text = value
	if is_node_ready():
		label.set_text(value)


func set_label_settings(settings: LabelSettings) -> void:
	label_settings = settings
	if is_node_ready():
		label.label_settings = settings
