@tool
class_name AudacityLabelParser
extends Node


const _MinigameMode: Dictionary = {
	"SK": HitObjectInfo.Type.LANE,
	"MK": HitObjectInfo.Type.LANE,
	"CLK": HitObjectInfo.Type.CLICK,
}


@export_multiline var label_file_content: String = ""
@export_file("*.tscn") var single_key_hit_object_scene_path: String = ""
@export_file("*.tscn") var multi_key_hit_object_scene_path: String = ""
@export_file("*.tscn") var click_hit_object_scene_path: String = ""
@export var generate_result: bool = false:
	set(value):
		_process_content()
@export var result: Array[HitObjectInfo] = []:
	set = _set_result

var _is_processing_file: bool = false


func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_free()


func _process_content() -> void:
	var line_index: int = 0
	var null_infos_count: int = 0
	var lines: PackedStringArray = label_file_content.split("\n")
	var result: Array[HitObjectInfo] = []
	result.resize(lines.size())
	for line: String in lines:
		var info: HitObjectInfo = _process_line(line, line_index)
		if info == null:
			FDCore.warning(
				"AudacityLabelParser: Error while processing content from line "
				+ str(line_index)
			)
			null_infos_count += 1
			continue
		result[line_index - null_infos_count] = info
		line_index += 1
	result = result.slice(0, result.size() - null_infos_count)
	_is_processing_file = true
	self.result = result
	_is_processing_file = false



func _process_line(line: String, index: int) -> HitObjectInfo:
	var splitted: PackedStringArray = line.replace("\"", "").split(" ")
	if not splitted.size() == 4:
		FDCore.warning(
			"AudacityLabelParser: Line Process: Line has more than 4 parameters!"
		)
		return null
	var info: HitObjectInfo = HitObjectInfo.new()
	info.hit_time = float(splitted[1])
	info.type = _MinigameMode.get(splitted[3],  HitObjectInfo.Type.UNDEFINED)
	info.lane_index = int(splitted[0].split("-", true, 2)[1])
	match splitted[3]:
		"SK": info.scene_path = single_key_hit_object_scene_path
		"MK": info.scene_path = multi_key_hit_object_scene_path
		"CLK": info.scene_path = click_hit_object_scene_path
	return info


func _set_result(value: Array[HitObjectInfo]) -> void:
	if not _is_processing_file:
		print_rich(
			"[color=yellow]"
			+ "AudacityLabelParser: Result is a read-only property!"
			+ "[/color]"
		)
		return
	result = value
