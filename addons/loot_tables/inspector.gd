extends EditorInspectorPlugin

var InspectorEditButton = preload("res://addons/loot_tables/ui/InspectorEditButton.gd")

var plugin: EditorPlugin

func _can_handle(object):
	prints("_can_handle", object)
	return object is LootTable

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags, wide: bool):
	# We handle properties of type integer.
	if object is LootTable && name == "pools":
		var b: Button = Button.new()
		b.text = "Edit"
		b.pressed.connect(func():
			doit(object)
#			plugin.get_editor_interface().edit_resource(object)
#			plugin._edit(object)
#			plugin._make_visible(true)
			)
		add_custom_control(b)
		return false
	else:
		return false

func doit(table: LootTable):
	prints("doit", table)
	plugin.get_editor_interface().call_deferred("edit_resource", table)
