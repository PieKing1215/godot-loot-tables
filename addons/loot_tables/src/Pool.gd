class_name Pool
extends Resource

@export var rolls: int = 1 # TODO: IntProvider
@export var entries: Array[PoolEntry] = []

func _init(rolls: int = 1, entries: Array[PoolEntry] = []):
	self.rolls = rolls
	self.entries = entries

func roll() -> Array[Resource]:
	var res: Array[Resource] = []
	for r in range(rolls):
		var ent: PoolEntry = _roll_entry(_entries())
		if ent != null:
			res.append_array(ent.roll())
	return res

# (in case I want to make this dynamic later)
func _entries() -> Array[PoolEntry]:
	return entries

func _roll_entry(ents: Array[PoolEntry]) -> PoolEntry:
	if ents.is_empty():
		return null
	
	# this weighted selection could be marginally optimized by binary searching if needed
	
	var total_weight: float = 0.0
	for e in ents:
		total_weight += e.weight
	
	var r = randf_range(0, total_weight)
	
	for e in ents:
		r -= e.weight
		if r <= 0.0:
			return e
	
	printerr("_roll_entry failed (?)")
	return null

func display_string(str_fn: Callable) -> String:
	var res := " OR ".join(entries.map(func(e: PoolEntry):
		if entries.size() > 1:
			return "%s [%sw]" % [e.display_string(str_fn), str(snapped(e.weight, 0.01))]
		
		return e.display_string(str_fn)
	))
	
	if entries.is_empty():
		return "nothing"
	
	if entries.size() > 1:
		res = "(%s)" % res
	
	if rolls != 1:
		res = "%dx %s" % [rolls, res]
	
	return res
