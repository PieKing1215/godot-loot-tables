class_name LootTableEntry
extends PoolEntry

@export var loot_table: LootTable

func roll() -> Array[Resource]:
	return loot_table.roll()

func display_string(str_fn: Callable) -> String:
	return loot_table.display_string(str_fn)