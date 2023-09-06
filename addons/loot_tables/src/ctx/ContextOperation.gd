@tool
class_name LTContextOperation
extends Resource

func apply(ctx: Dictionary) -> Dictionary:
	return ctx.duplicate()

static func get_float_or_constant_or_default(ctx: Dictionary, key: String, default: float) -> float:
	if key.is_valid_float():
		return key.to_float()
	
	if ctx.has(key) && ctx[key] is float:
		return ctx[key]
	
	return default

static func get_float_or_default(ctx: Dictionary, key: String, default: float) -> float:
	if ctx.has(key) && ctx[key] is float:
		return ctx[key]
	
	return default
