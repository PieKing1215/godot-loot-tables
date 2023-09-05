@tool
extends Control

var _plugin: EditorPlugin
var _editing: LootTable

const LootTableGraphNode = preload("res://addons/loot_tables/ui/LootTableGraphNode.gd")
const PoolGraphNode = preload("res://addons/loot_tables/ui/PoolGraphNode.gd")
const PoolEntryGraphNode = preload("res://addons/loot_tables/ui/PoolEntryGraphNode.gd")

#var _graph_context_menu_scn: PackedScene = preload("res://addons/loot_tables/ui/graph_context_menu.tscn")

var _context_pos

func _ready():
	%GraphEdit.grab_click_focus()

func edit_table(lt: LootTable):
	%Label.text = lt.get_path()
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

func _add_lt_node(graph: GraphEdit, lt: LootTable, output: bool = false) -> GraphNode:
	var gn: LootTableGraphNode = LootTableGraphNode.new()
	gn.loot_table = lt
	gn.name = "LootTable"
	gn.title = "LootTable"
	graph.add_child(gn)
	
	if output:
		var out_label: Label = Label.new()
		out_label.text = "LootTable"
		out_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		gn.add_child(out_label)
		gn.set_slot_enabled_right(gn.get_child_count() - 1, true)
		
	var p_label: Label = Label.new()
	p_label.text = "Pools"
	gn.add_child(p_label)
	gn.set_slot_enabled_left(gn.get_child_count() - 1, true)
	
	for i in range(0, lt.pools.size()):
		var p: Pool = lt.pools[i]
		
		var pn: GraphNode = _add_pool_node(graph, p)
		
		graph.connect_node(pn.name, 0, gn.name, 0)
	
	return gn

func _add_pool_node(graph: GraphEdit, pool: Pool) -> GraphNode:
	var gn: PoolGraphNode = PoolGraphNode.new()
	gn.pool = pool
	gn.name = "Pool"
	gn.title = "Pool"
	graph.add_child(gn)
	
	var out_label: Label = Label.new()
	out_label.text = "Pool"
	out_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	gn.add_child(out_label)
	gn.set_slot_enabled_right(gn.get_child_count() - 1, true)
	
	var rolls_input: EditorSpinSlider = EditorSpinSlider.new()
	rolls_input.hide_slider = true
	rolls_input.min_value = 0
	rolls_input.max_value = 100
	rolls_input.step = 1
	rolls_input.allow_greater = true
	rolls_input.value = pool.rolls
	rolls_input.value_changed.connect(func(v): pool.rolls = v)
	gn.add_child(_wrap_with_label(rolls_input, "rolls"))
		
	var e_label: Label = Label.new()
	e_label.text = "Entries"
	gn.add_child(e_label)
	gn.set_slot_enabled_left(gn.get_child_count() - 1, true)
	
	for i in range(0, pool.entries.size()):
		var e: PoolEntry = pool.entries[i]
		
		var en: GraphNode = _add_entry_node(graph, e)
		
		graph.connect_node(en.name, 0, gn.name, 0)
	
	return gn

func _add_entry_node(graph: GraphEdit, entry: PoolEntry) -> GraphNode:
	var gn: PoolEntryGraphNode = PoolEntryGraphNode.new()
	gn.entry = entry
	gn.name = entry.title()
	gn.title = entry.title()
	graph.add_child(gn)
		
	var out_label: Label = Label.new()
	out_label.text = "PoolEntry"
	out_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	gn.add_child(out_label)
	gn.set_slot_enabled_right(0, true)
	
	var weight_input: EditorSpinSlider = EditorSpinSlider.new()
	weight_input.hide_slider = true
	weight_input.max_value = 1000.0
	weight_input.step = 0.05
	weight_input.allow_greater = true
	weight_input.value = entry.weight
	weight_input.value_changed.connect(func(v): entry.weight = v)
	gn.add_child(_wrap_with_label(weight_input, "weight"))
	
	for prop in entry.get_property_list():
		if prop.name != "weight" && prop.usage & PROPERTY_USAGE_EDITOR && prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			print(prop)
			if prop.type == TYPE_OBJECT && prop.hint == PROPERTY_HINT_RESOURCE_TYPE:
				var resource_picker: EditorResourcePicker = EditorResourcePicker.new()
				resource_picker.base_type = prop.hint_string
				resource_picker.edited_resource = entry.get(prop.name)
				resource_picker.resource_changed.connect(func(r): entry.set(prop.name, r))
				gn.add_child(_wrap_with_label(resource_picker, prop.name))
				
				if prop.hint_string == "PoolEntry":
					gn.set_slot_enabled_left(gn.get_child_count() - 1, true)
					var res: PoolEntry = entry.get(prop.name)
					if res != null && (res.resource_path.is_empty() || !res.resource_path.ends_with(".tres")):
						var res_gn: GraphNode = _add_entry_node(graph, res)
						graph.connect_node(res_gn.name, 0, gn.name, gn.get_connection_input_count() - 1)
				elif prop.hint_string == "LootTable":
					gn.set_slot_enabled_left(gn.get_child_count() - 1, true)
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
	
	return gn

func _wrap_with_label(inner: Control, label: String) -> Control:
	var hbox: HBoxContainer = HBoxContainer.new()
	var lbl: Label = Label.new()
	lbl.text = label
	hbox.add_child(lbl)
	hbox.add_child(inner)
	hbox.custom_minimum_size.x = 200
	inner.custom_minimum_size.x = 150
	inner.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
#	hbox.size_flags_horizontal = Control.SIZE
	return hbox

func _on_background_context_id_pressed(id):
	if id == 0: # add loot table
		var new: GraphNode = _add_lt_node(%GraphEdit, LootTable.new([]), true)
		new.position_offset = _context_pos
	elif id == 1: # add pool table
		var new: GraphNode = _add_pool_node(%GraphEdit, Pool.new(1, []))
		new.position_offset = _context_pos
