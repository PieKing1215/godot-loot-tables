@tool
extends PopupMenu

signal select_add_entry_type(class_path: String)
signal select_add_pool_type(class_path: String)

var _entry_types: Array[String] = []
var _pool_types: Array[String] = []

func _plugin_ready():
	# pools
	
	add_submenu_item("Add Pool", %AddPoolSubMenu.name)
	
	var rp2: EditorResourcePicker = EditorResourcePicker.new()
	rp2.base_type = "Pool"
	_pool_types.assign(rp2.get_allowed_types())
	for t in _pool_types:
		%AddPoolSubMenu.add_item(t)
	
	# entries
	
	add_submenu_item("Add Entry", %AddEntrySubMenu.name)
	
	var rp: EditorResourcePicker = EditorResourcePicker.new()
	rp.base_type = "PoolEntry"
	_entry_types.assign(rp.get_allowed_types())
	_entry_types.pop_front() # remove PoolEntry
	for t in _entry_types:
		%AddEntrySubMenu.add_item(t)

func _on_add_entry_sub_menu_index_pressed(index):
	var _global_classes: Array[Dictionary] = ProjectSettings.get_global_class_list()
	for gc in _global_classes:
		if gc.class == _entry_types[index]:
			select_add_entry_type.emit(gc.path)


func _on_add_pool_sub_menu_index_pressed(index):
	var _global_classes: Array[Dictionary] = ProjectSettings.get_global_class_list()
	for gc in _global_classes:
		if gc.class == _pool_types[index]:
			select_add_pool_type.emit(gc.path)
