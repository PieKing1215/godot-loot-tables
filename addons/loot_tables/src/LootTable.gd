class_name LootTable
extends Resource

@export var pools: Array[Pool] = []

func _init(pools: Array[Pool] = []):
	self.pools = pools

func roll() -> Array[Resource]:
	var res: Array[Resource] = []
	for p in pools:
		res.append_array(p.roll())
	return res

func display_string(str_fn: Callable) -> String:
	return " + ".join(pools.map(func(p: Pool): return p.display_string(str_fn)))

static func empty() -> LootTable:
	return LootTable.new([])
