@tool
extends GraphNode

func _wrap_with_label(inner: Control, label: String, min_width: float = 200) -> Control:
	var hbox: HBoxContainer = HBoxContainer.new()
	var lbl: Label = Label.new()
	lbl.text = label
	hbox.add_child(lbl)
	hbox.add_child(inner)
	hbox.custom_minimum_size.x = min_width
	inner.custom_minimum_size.x = hbox.custom_minimum_size.x - 50
	inner.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
	return hbox
