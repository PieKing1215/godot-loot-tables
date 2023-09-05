@tool
class_name LootTableEntry
extends PoolEntry

@export var loot_table: LootTable

func roll(ctx: Dictionary = {}) -> Array[Resource]:
	return loot_table.roll(ctx)

func title() -> String:
	return "LootTableEntry"

func display_string(str_fn: Callable) -> String:
	return loot_table.display_string(str_fn)
