@tool
class_name SignalActionTrigger
extends Node

## When specified parent's signal is emitted, an specified action is triggered.
##
## This node works as a signal receiver and action transmitter. When signal
## [member signal_to_connect] is emitted, action [member action_to_trigger] is
## triggered on [@].


## Optional context to distinguish action. If not empty, the context
## is triggered togheter with [member action_to_trigger].
@export var action_context: StringName = &""
## Signal to be connected to. When this signal is emitted, [member action_to_trigger]
## is triggered on [FDCore].
var signal_to_connect: StringName = &""
## Action to be triggered when [member signal_to_connect] is emmitted.
var action_to_trigger: StringName = &""


#func _init() -> void:
	#set_process_mode(Node.PROCESS_MODE_DISABLED)


func _ready() -> void:
	if not Engine.is_editor_hint():
		var parent = get_parent()
		if parent.has_signal(signal_to_connect):
			FDCore.log_message(
				"Connecting signal " + signal_to_connect + " from object "
				+ parent.name + " to action " + action_to_trigger,
				"gray"
			)
			var signal_args_count: int = _get_signal_arg_count(signal_to_connect)
			var callable: Callable = _trigger_action
			if signal_args_count > 0:
				callable = callable.unbind(signal_args_count)
			parent.connect(signal_to_connect, callable)
	pass


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func _get(property: StringName) -> Variant:
	match property:
		&"signal_to_connect":
			return signal_to_connect
		&"action_to_trigger":
			return action_to_trigger
	return null


func _set(property: StringName, value: Variant) -> bool:
	match property:
		&"signal_to_connect":
			signal_to_connect = value
			return true
		&"action_to_trigger":
			action_to_trigger = value
			return true
	return false


func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	properties.append({
		"name": &"signal_to_connect",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(_get_parent_signals()),
	})
	properties.append({
		"name": &"action_to_trigger",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,
	})
	return properties


func _property_get_revert(property: StringName) -> Variant:
	match property:
		&"signal_to_connect": return _get_parent_signals()[0]
		&"action_to_trigger": return &""
	return null


func _property_can_revert(property: StringName) -> bool:
	match property:
		&"signal_to_connect": return true
		&"action_to_trigger": return true
	return false


func _get_parent_signals() -> Array[StringName]:
	var signals_list: Array[Dictionary] = get_parent().get_signal_list()
	var signals_names: Array[StringName] = []
	for _signal in signals_list:
		signals_names.append(_signal.get(&"name"))
	return signals_names


func _get_signal_arg_count(signal_name: String) -> int:
	if not get_parent().has_signal(signal_name):
		return 0
	var signal_list: Array[Dictionary] = get_parent().get_signal_list()
	for _signal in signal_list:
		if _signal.get(&"name", null) == signal_name:
			return len(_signal.get(&"args", []))
	return 0

func _trigger_action() -> void:
	FDCore.trigger_action(action_to_trigger, action_context)
