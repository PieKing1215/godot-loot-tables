@tool
extends "BaseGraphNode.gd"

var loot_table: LootTable

func is_output_enabled() -> bool:
	return is_slot_enabled_right(0)

func set_output_enabled(enable: bool):
	set_slot_enabled_right(0, enable)
	%Out.visible = enable
	show_close = enable

func pools_in_port() -> int:
	return 0

func out_port() -> int:
	return 0
