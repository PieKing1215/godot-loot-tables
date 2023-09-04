class_name SingleSceneEntry
extends PoolEntry

@export var scene: PackedScene

func _init(scene: PackedScene = null):
	self.scene = scene
	
func roll() -> Array[Resource]:
	return [scene]

func display_string(str_fn: Callable) -> String:
	prints("SingleSceneEntry", scene.resource_path, str_fn.call(scene))
	return str_fn.call(scene)
