@tool
class_name ChanceEntry
extends PoolEntry

@export var base: PoolEntry = null
@export_range(0.0, 1.0) var chance: float = 0.5

func _init(chance: float = 0.5, base: PoolEntry = PoolEntry.new()):
	self.chance = chance
	self.base = base

func roll() -> Array[Resource]:
	if chance >= 1.0 || (chance > 0.0 && randf() < chance):
		return base.roll()
	else:
		return []

func title() -> String:
	return "ChanceEntry"

func display_string(str_fn: Callable) -> String:
	return "%s%% %s" % [str(snapped(chance * 100, 0.01)), base.display_string(str_fn)]

