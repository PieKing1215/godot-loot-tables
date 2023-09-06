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
	add_child(_LT_LootTableEditor._wrap_with_label(rolls_input, "rolls", 100))
	
	var string_input: LineEdit = LineEdit.new()
	var val = pool.rolls_mult_ctx_id
	string_input.text = "" if val == null else val
	string_input.text_changed.connect(func(v): pool.rolls_mult_ctx_id = v)
	add_child(_LT_LootTableEditor._wrap_with_label(string_input, "rolls_mult_ctx_id"))

func entries_in_port() -> int:
	return 0

func out_port() -> int:
	return 0
