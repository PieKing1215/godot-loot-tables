@tool
extends EditorResourcePicker

func _set_create_options(menu_node):
	print(get_allowed_types())
	super(menu_node)
	if menu_node is PopupMenu:
		var popup: PopupMenu = menu_node
		for i in range(0, popup.item_count):
			print(popup.get_item_text(i))
