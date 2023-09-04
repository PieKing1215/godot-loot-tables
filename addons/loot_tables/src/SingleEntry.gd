class_name SingleEntry
extends PoolEntry

@export var resource: Resource

func roll() -> Array[Resource]:
	return [resource]

func display_string(str_fn: Callable) -> String:
	return str_fn.call(resource)
