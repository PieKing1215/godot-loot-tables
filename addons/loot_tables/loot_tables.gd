@tool
extends EditorPlugin

var inspector_plugin

const MainPanel = preload("res://addons/loot_tables/ui/main_screen.tscn")

var main_panel_instance

func _enter_tree():
	inspector_plugin = preload("res://addons/loot_tables/inspector.gd").new()
	inspector_plugin.plugin = self
	add_inspector_plugin(inspector_plugin)
	main_panel_instance = MainPanel.instantiate()
	main_panel_instance.plugin = self
	get_editor_interface().get_editor_main_screen().add_child(main_panel_instance)
	_make_visible(false)

func _exit_tree():
	if inspector_plugin:
		remove_inspector_plugin(inspector_plugin)
	if main_panel_instance:
		main_panel_instance.queue_free()

func _handles(object):
#	prints("_handles", object, object.get_class(), object.get_script().get_path(), object is LootTable)
	return object is LootTable

func _edit(object):
#	prints("_edit", object)
	if object is LootTable:
		main_panel_instance.edit_table(object)

func _has_main_screen():
	return true

func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible

func _get_plugin_name():
	return "LootTable"

func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")
