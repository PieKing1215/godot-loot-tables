@tool
class_name UniquePool
extends Pool

func _do_rolls(roll_ct: int, ctx: Dictionary = {}) -> Array[Resource]:
	var res: Array[Resource] = []
	
	# UniquePool is a variant of Pool that avoids duplicates unless necessary
	var avail_entries: Array[PoolEntry] = []
	
	for r in range(roll_ct):
		# add all to available if none left
		if avail_entries.is_empty():
			avail_entries.append_array(_entries())
		
		# select an available entry
		var ent: PoolEntry = _roll_entry(avail_entries, ctx)
		
		if ent != null:
			# remove this entry from available
			avail_entries.erase(ent)
			res.append_array(ent.roll(ctx))
	return res

func title() -> String:
	return "UniquePool"
