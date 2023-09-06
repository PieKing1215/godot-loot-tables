@tool
class_name LTContextOperation
extends Resource

func apply(ctx: Dictionary) -> Dictionary:
	return ctx.duplicate()

static func get_float_or_constant_or_default(ctx: Dictionary, key: String, default: float) -> float:
	if key.is_valid_float():
		return key.to_float()
	
	return get_float_or_default(ctx, key, default)

static func get_float_or_default(ctx: Dictionary, key: String, default: float) -> float:
	if ctx.has(key) && (ctx[key] is float || ctx[key] is int):
		return ctx[key]
	
	return default
