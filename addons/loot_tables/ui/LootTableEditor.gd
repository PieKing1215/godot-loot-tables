@tool
class_name _LT_LootTableEditor
extends Control

var plugin: EditorPlugin:
	set(p):
		plugin = p
		%BackgroundContext._plugin_ready()

var _editing: LootTable

const LootTableGraphNode = preload("res://addons/loot_tables/ui/LootTableGraphNode.gd")
var loot_table_graph_node_scn: PackedScene = preload("res://addons/loot_tables/ui/loot_table_graph_node.tscn")
const PoolGraphNode = preload("res://addons/loot_tables/ui/PoolGraphNode.gd")
var pool_graph_node_scn: PackedScene = preload("res://addons/loot_tables/ui/pool_graph_node.tscn")
const PoolEntryGraphNode = preload("res://addons/loot_tables/ui/PoolEntryGraphNode.gd")
var pool_entry_graph_node_scn: PackedScene = preload("res://addons/loot_tables/ui/pool_entry_graph_node.tscn")

const EntryEditorResourcePicker = preload("res://addons/loot_tables/ui/EntryEditorResourcePicker.gd")

#var _graph_context_menu_scn: PackedScene = preload("res://addons/loot_tables/ui/graph_context_menu.tscn")

var _context_pos

enum Type {
	Unknown,
	LootTable,
	Pool,
	PoolEntry,
}

var _type_colors: Array[Color] = [
	Color.WHITE,
	Color.hex(0x80d4ffff),
	Color.hex(0xdb80ffff),
	Color.hex(0xffa880ff),
]

func _ready():
	%GraphEdit.grab_click_focus()

func edit_table(lt: LootTable):
	%Editing.text = lt.get_path()
	%GraphEdit.clear_connections()
	for c in %GraphEdit.get_children():
		c.free()
	
	await get_tree().process_frame
	
	_add_lt_node(%GraphEdit, lt)
	
	await get_tree().process_frame
	
	%GraphEdit.arrange_nodes()

func show_background_context(pos: Vector2):
	%BackgroundContext.position = Vector2i(%GraphEdit.get_screen_position()) + Vector2i(pos)
	_context_pos = (%GraphEdit.get_local_mouse_position() + %GraphEdit.scroll_offset) / %GraphEdit.zoom
	%BackgroundContext.show()

func _add_lt_node(graph: GraphEdit, lt: LootTable, output: bool = false) -> LootTableGraphNode:
	var gn: LootTableGraphNode = loot_table_graph_node_scn.instantiate()
	gn.set_output_enabled(output)
	gn.loot_table = lt
	graph.add_child(gn)
	
	for i in range(0, lt.pools.size()):
		var p: Pool = lt.pools[i]
		
		var pn: GraphNode = _add_pool_node(graph, p)
		
		graph.connect_node(pn.name, 0, gn.name, gn.pools_in_port())
	
	return gn

func _add_pool_node(graph: GraphEdit, pool: Pool) -> PoolGraphNode:
	var gn: PoolGraphNode = pool_graph_node_scn.instantiate()
	gn.pool = pool
	graph.add_child(gn)
	
	for i in range(0, pool.entries.size()):
		var e: PoolEntry = pool.entries[i]
		
		var en: GraphNode = _add_entry_node(graph, e)
		
		graph.connect_node(en.name, 0, gn.name, gn.entries_in_port())
	
	return gn

func _add_blank_entry_node(graph: GraphEdit) -> GraphNode:
	var gn: GraphNode = GraphNode.new()
	gn.name = "BlankEntry"
	gn.title = "BlankEntry"
	graph.add_child(gn)
	
	var resource_picker: EntryEditorResourcePicker = EntryEditorResourcePicker.new()
	resource_picker.base_type = "PoolEntry"
	resource_picker.resource_changed.connect(
		func(r):
			var en: PoolEntryGraphNode = _add_entry_node(graph, r)
			en.position_offset = gn.position_offset
			gn.queue_free()
	)

	gn.add_child(_wrap_with_label(resource_picker, "Pick Type:"))
	
	return gn

func _add_entry_node(graph: GraphEdit, entry: PoolEntry) -> PoolEntryGraphNode:
	var gn: PoolEntryGraphNode = pool_entry_graph_node_scn.instantiate()
	gn.entry = entry
	gn.title = entry.title()
	graph.add_child(gn)
	
	var props: Array[Dictionary] = entry.get_property_list()
	props.sort_custom(func(a, b): return (a.type == TYPE_OBJECT && a.hint == PROPERTY_HINT_RESOURCE_TYPE) || a.name == "weight_mult_ctx_id")
	for prop in props:
		if prop.name != "weight" && prop.usage & PROPERTY_USAGE_EDITOR && prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
#			print(prop)
			if prop.type == TYPE_OBJECT && prop.hint == PROPERTY_HINT_RESOURCE_TYPE:
				var resource_picker: EditorResourcePicker = EditorResourcePicker.new()
				resource_picker.base_type = prop.hint_string
				resource_picker.edited_resource = entry.get(prop.name)
				resource_picker.resource_changed.connect(func(r): entry.set(prop.name, r))
				gn.add_child(_wrap_with_label(resource_picker, prop.name))
				
				if prop.hint_string == "PoolEntry":
					gn.set_slot_enabled_left(gn.get_child_count() - 1, true)
					gn.set_slot_type_left(gn.get_child_count() - 1, Type.PoolEntry)
					gn.set_slot_color_left(gn.get_child_count() - 1, _type_colors[Type.PoolEntry])
					gn.input_properties[gn.get_connection_input_count() - 1] = {
						"property_name": prop.name,
						"resource_picker": resource_picker,
					}
					
					resource_picker.resource_changed.connect(
						func(res):
							if res != null && (res.resource_path.is_empty() || !res.resource_path.ends_with(".tres")):
								for c in %GraphEdit.get_children():
									c.selected = true
									
								var res_gn: PoolEntryGraphNode = _add_entry_node(graph, res)
								graph.connect_node(res_gn.name, res_gn.out_port(), gn.name, gn.get_connection_input_count() - 1)
								
								for c in %GraphEdit.get_children():
									c.selected = !c.selected
								
								await get_tree().process_frame
								await get_tree().process_frame
								%GraphEdit.arrange_nodes()
					)
					
					var res: PoolEntry = entry.get(prop.name)
					if res != null && (res.resource_path.is_empty() || !res.resource_path.ends_with(".tres")):
						var res_gn: GraphNode = _add_entry_node(graph, res)
						graph.connect_node(res_gn.name, 0, gn.name, gn.get_connection_input_count() - 1)
				elif prop.hint_string == "LootTable":
					gn.set_slot_enabled_left(gn.get_child_count() - 1, true)
					gn.set_slot_type_left(gn.get_child_count() - 1, Type.LootTable)
					gn.set_slot_color_left(gn.get_child_count() - 1, _type_colors[Type.LootTable])
					gn.input_properties[gn.get_connection_input_count() - 1] = {
						"property_name": prop.name,
						"resource_picker": resource_picker,
					}
					
					resource_picker.resource_changed.connect(
						func(res):
							if res != null && (res.resource_path.is_empty() || !res.resource_path.ends_with(".tres")):
								for c in %GraphEdit.get_children():
									c.selected = true
									
								var res_gn: LootTableGraphNode = _add_lt_node(graph, res, true)
								graph.connect_node(res_gn.name, res_gn.out_port(), gn.name, gn.get_connection_input_count() - 1)
								
								for c in %GraphEdit.get_children():
									c.selected = !c.selected
								
								await get_tree().process_frame
								await get_tree().process_frame
								%GraphEdit.arrange_nodes()
					)
					
					var res: LootTable = entry.get(prop.name)
					if res != null && (res.resource_path.is_empty() || !res.resource_path.ends_with(".tres")):
						var res_gn: GraphNode = _add_lt_node(graph, res, true)
						graph.connect_node(res_gn.name, 0, gn.name, gn.get_connection_input_count() - 1)
			elif prop.type == TYPE_FLOAT:
				var float_input: EditorSpinSlider = EditorSpinSlider.new()
				float_input.hide_slider = true
				
				float_input.allow_greater = true
				float_input.allow_lesser = true
				if prop.hint == PROPERTY_HINT_RANGE:
					float_input.hide_slider = false
					var split: PackedStringArray = prop.hint_string.split(",")
					print(split)
					float_input.allow_greater = false
					float_input.allow_lesser = false
					float_input.min_value = float(split[0])
					float_input.max_value = float(split[1])
					float_input.step = 0.001
					if split.size() >= 3:
						float_input.step = float(split[2])
						float_input.allow_greater = split.has("or_greater")
						float_input.allow_lesser = split.has("or_less")
				
				float_input.value = entry.get(prop.name)
				float_input.value_changed.connect(func(v): entry.set(prop.name, v))
				gn.add_child(_wrap_with_label(float_input, prop.name))
			elif prop.type == TYPE_INT:
				var int_input: EditorSpinSlider = EditorSpinSlider.new()
				int_input.hide_slider = true
				
				int_input.allow_greater = true
				int_input.allow_lesser = true
				if prop.hint == PROPERTY_HINT_RANGE:
					int_input.hide_slider = false
					var split: PackedStringArray = prop.hint_string.split(",")
					print(split)
					int_input.allow_greater = false
					int_input.allow_lesser = false
					int_input.min_value = float(split[0])
					int_input.max_value = float(split[1])
					int_input.step = 1
					if split.size() >= 3:
						int_input.step = float(split[2])
						int_input.allow_greater = split.has("or_greater")
						int_input.allow_lesser = split.has("or_less")
				
				int_input.value = entry.get(prop.name)
				int_input.value_changed.connect(func(v): entry.set(prop.name, v))
				gn.add_child(_wrap_with_label(int_input, prop.name))
			elif prop.type == TYPE_STRING:
				var string_input: LineEdit = LineEdit.new()
				var val = entry.get(prop.name)
				string_input.text = "" if val == null else val
				string_input.text_changed.connect(func(v): entry.set(prop.name, v))
				gn.add_child(_wrap_with_label(string_input, prop.name))
	
	return gn

func _on_background_context_id_pressed(id):
	if id == 0: # add loot table
		var new: GraphNode = _add_lt_node(%GraphEdit, LootTable.new([]), true)
		new.position_offset = _context_pos
	elif id == 1: # add pool
		var new: GraphNode = _add_pool_node(%GraphEdit, Pool.new(1, []))
		new.position_offset = _context_pos
#	elif id == 2: # add pool entry
#		var new: GraphNode = _add_blank_entry_node(%GraphEdit)
#		new.position_offset = _context_pos


func _on_graph_edit_connection_request(from_node: StringName, from_port, to_node: StringName, to_port):
	var fn: GraphNode = %GraphEdit.get_node(String(from_node))
	var tn: GraphNode = %GraphEdit.get_node(String(to_node))
	print("connect", fn, tn)
	if fn is PoolGraphNode && tn is LootTableGraphNode:
		tn.loot_table.pools.push_back(fn.pool)
		%GraphEdit.connect_node(from_node, from_port, to_node, to_port)
	elif fn is PoolEntryGraphNode && tn is PoolGraphNode:
		tn.pool.entries.push_back(fn.entry)
		%GraphEdit.connect_node(from_node, from_port, to_node, to_port)
	elif fn is LootTableGraphNode && tn is PoolEntryGraphNode:
		tn.set_input(to_port, fn.loot_table)
		%GraphEdit.connect_node(from_node, from_port, to_node, to_port)
	elif fn is PoolGraphNode && tn is PoolEntryGraphNode:
		tn.set_input(to_port, fn.loot_table)
		%GraphEdit.connect_node(from_node, from_port, to_node, to_port)
	elif fn is PoolEntryGraphNode && tn is PoolEntryGraphNode:
		tn.set_input(to_port, fn.entry)
		%GraphEdit.connect_node(from_node, from_port, to_node, to_port)


func _on_graph_edit_disconnection_request(from_node, from_port, to_node, to_port):
	var fn: GraphNode = %GraphEdit.get_node(String(from_node))
	var tn: GraphNode = %GraphEdit.get_node(String(to_node))
	if fn is PoolGraphNode && tn is LootTableGraphNode:
		tn.loot_table.pools.erase(fn.pool)
		%GraphEdit.disconnect_node(from_node, from_port, to_node, to_port)
	elif fn is PoolEntryGraphNode && tn is PoolGraphNode:
		tn.pool.entries.erase(fn.entry)
		%GraphEdit.disconnect_node(from_node, from_port, to_node, to_port)
	elif fn is LootTableGraphNode && tn is PoolEntryGraphNode:
		tn.set_input(to_port, null)
		%GraphEdit.disconnect_node(from_node, from_port, to_node, to_port)
	elif fn is PoolGraphNode && tn is PoolEntryGraphNode:
		tn.set_input(to_port, null)
		%GraphEdit.disconnect_node(from_node, from_port, to_node, to_port)
	elif fn is PoolEntryGraphNode && tn is PoolEntryGraphNode:
		tn.set_input(to_port, null)
		%GraphEdit.disconnect_node(from_node, from_port, to_node, to_port)

func _on_graph_edit_delete_nodes_request(nodes: Array[StringName]):
	prints("delete", nodes)
	for con in %GraphEdit.get_connection_list():
		if nodes.any(func(sn: StringName): return con.from == sn || con.to == sn):
			_on_graph_edit_disconnection_request(con.from, con.from_port, con.to, con.to_port)
	
	for sn in nodes:
		%GraphEdit.get_node(String(sn)).queue_free()

func _on_background_context_select_add_type(class_path):
	var inst: PoolEntry = load(class_path).new()
	var new: GraphNode = _add_entry_node(%GraphEdit, inst)
	new.position_offset = _context_pos


static func _wrap_with_label(inner: Control, label: String, min_width: float = 200) -> Control:
	var hbox: HBoxContainer = HBoxContainer.new()
	var lbl: Label = Label.new()
	lbl.text = label
	hbox.add_child(lbl)
	hbox.add_child(inner)
	hbox.custom_minimum_size.x = min_width
	inner.custom_minimum_size.x = hbox.custom_minimum_size.x - 50
	inner.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
	return hbox
