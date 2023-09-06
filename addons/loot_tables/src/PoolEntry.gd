@tool
class_name PoolEntry
extends Resource

@export var weight: float = 1.0
@export var weight_mult_ctx_id: String = ""

func calc_weight(ctx: Dictionary = {}) -> float:
	var w := weight
	if weight_mult_ctx_id != null && !weight_mult_ctx_id.is_empty():
		w *= LTContextOperation.get_float_or_default(ctx, weight_mult_ctx_id, 1.0)
	return w

func roll(ctx: Dictionary = {}) -> Array[Resource]:
	return []

func title() -> String:
	return "PoolEntry"

func display_string(str_fn: Callable) -> String:
	return "?PoolEntry"
