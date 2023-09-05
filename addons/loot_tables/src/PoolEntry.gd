@tool
class_name PoolEntry
extends Resource

@export var weight: float = 1.0

func roll(ctx: Dictionary = {}) -> Array[Resource]:
	return []

func title() -> String:
	return "PoolEntry"

func display_string(str_fn: Callable) -> String:
	return "?PoolEntry"
