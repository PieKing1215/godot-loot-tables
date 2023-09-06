@tool
class_name LootTable
extends Resource

@export var pools: Array[Pool] = []
@export var ctx_ops: Array[LTContextOperation] = []

func _init(pools: Array[Pool] = []):
	self.pools = pools

func roll(ctx: Dictionary = {}) -> Array[Resource]:
	for op in ctx_ops:
		ctx = op.apply(ctx)
	
	var res: Array[Resource] = []
	for p in pools:
		res.append_array(p.roll(ctx))
	return res

func display_string(str_fn: Callable) -> String:
	return " + ".join(pools.map(func(p: Pool): return p.display_string(str_fn)))

static func empty() -> LootTable:
	return LootTable.new([])
