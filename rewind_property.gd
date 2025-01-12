# res://RewindResource.gd
class_name RewindResource extends Resource

@export var node_path: NodePath
@export var property_name: String = ""
@export var time_saved: float = 15.0  # Max time to store in seconds
var values: Array = []
var frames_to_store: int = 0

func _init():
	frames_to_store = int(time_saved * Engine.physics_ticks_per_second)

func add_value(value):
	values.append(value)
	if values.size() > frames_to_store:
		values.pop_front()

func pop_value():
	return values.pop_back() if values.size() > 0 else null

func peek_last_value():
	return values[-1] if values.size() > 0 else null
