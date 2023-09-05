@tool
class_name SingleEntry
extends PoolEntry

@export var resource: Resource

func roll(_ctx: Dictionary = {}) -> Array[Resource]:
	return [resource]

func title() -> String:
	return "SingleEntry"

func display_string(str_fn: Callable) -> String:
	return str_fn.call(resource)
