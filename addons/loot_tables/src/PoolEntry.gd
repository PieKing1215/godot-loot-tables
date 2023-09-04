class_name PoolEntry
extends Resource

@export var weight: float = 1.0

func roll() -> Array[Resource]:
	return []

func display_string(str_fn: Callable) -> String:
	return "?PoolEntry"
