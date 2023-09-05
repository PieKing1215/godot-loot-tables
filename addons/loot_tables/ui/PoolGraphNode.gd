@tool
extends "BaseGraphNode.gd"

var pool: Pool

func _ready():
	var rolls_input: EditorSpinSlider = EditorSpinSlider.new()
	rolls_input.hide_slider = true
	rolls_input.min_value = 0
	rolls_input.max_value = 100
	rolls_input.step = 1
	rolls_input.allow_greater = true
	rolls_input.value = pool.rolls
	rolls_input.value_changed.connect(func(v): pool.rolls = v)
	add_child(_wrap_with_label(rolls_input, "rolls", 100))

func entries_in_port() -> int:
	return 0

func out_port() -> int:
	return 0
