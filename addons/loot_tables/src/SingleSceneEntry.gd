@tool
class_name SingleSceneEntry
extends PoolEntry

@export var scene: PackedScene

func _init(scene: PackedScene = null):
	self.scene = scene
	
func roll(_ctx: Dictionary = {}) -> Array[Resource]:
	return [scene]

func title() -> String:
	return "SingleSceneEntry"

func display_string(str_fn: Callable) -> String:
	return str_fn.call(scene)
