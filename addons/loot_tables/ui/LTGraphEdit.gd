@tool
extends GraphEdit

func _ready():
	for t in range(0, 4):
		add_valid_left_disconnect_type(t)
		add_valid_connection_type(t, t)
