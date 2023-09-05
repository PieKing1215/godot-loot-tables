@tool
extends PopupMenu

signal select_add_type(class_path: String)

var _types: Array[String] = []

func _plugin_ready():
	add_submenu_item("Add Entry", %AddSubMenu.name)
	
	var rp: EditorResourcePicker = EditorResourcePicker.new()
	rp.base_type = "PoolEntry"
	_types.assign(rp.get_allowed_types())
	_types.pop_front() # remove PoolEntry
	for t in _types:
		%AddSubMenu.add_item(t)

func _on_add_sub_menu_index_pressed(index):
	var _global_classes: Array[Dictionary] = ProjectSettings.get_global_class_list()
	for gc in _global_classes:
		if gc.class == _types[index]:
			select_add_type.emit(gc.path)
