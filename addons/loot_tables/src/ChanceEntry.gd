@tool
class_name ChanceEntry
extends PoolEntry

@export var base: PoolEntry = null
@export_range(0.0, 1.0) var chance: float = 0.5
@export var chance_mult_ctx_id: String = ""

func _init(chance: float = 0.5, base: PoolEntry = null):
	self.chance = chance
	self.base = base

func roll(ctx: Dictionary = {}) -> Array[Resource]:
	var ch := chance
	if chance_mult_ctx_id != null && !chance_mult_ctx_id.is_empty():
		ch *= LTContextOperation.get_float_or_default(ctx, chance_mult_ctx_id, 1.0)
		
	if ch >= 1.0 || (ch > 0.0 && randf() < ch):
		return base.roll(ctx)
	else:
		return []

func title() -> String:
	return "ChanceEntry"

func display_string(str_fn: Callable) -> String:
	return "%s%% %s" % [str(snapped(chance * 100, 0.01)), base.display_string(str_fn)]

