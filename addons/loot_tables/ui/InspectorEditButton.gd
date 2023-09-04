extends EditorProperty

var button = Button.new()

func _init():
	add_child(button)
	add_focusable(button)
