@tool
extends "BaseGraphNode.gd"

var entry: PoolEntry

var input_properties: Dictionary = {}

func _ready():
	var weight_input: EditorSpinSlider = EditorSpinSlider.new()
	weight_input.hide_slider = true
	weight_input.max_value = 1000.0
	weight_input.step = 0.05
	weight_input.allow_greater = true
	weight_input.value = entry.weight
	weight_input.value_changed.connect(func(v): entry.weight = v)
	add_child(_wrap_with_label(weight_input, "weight"))

func out_port() -> int:
	return 0

func set_input(port: int, res: Resource):
	entry.set(input_properties[port].property_name, res)
	input_properties[port].resource_picker.editable = res == null
	input_properties[port].resource_picker.edited_resource = res
