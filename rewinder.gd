extends Node

@export var rewind_duration: float = 3.0  # Duration to rewind in game time (seconds)
@export var rewind_resources: Array[RewindResource] = []
@export_range(0.5, 4, 0.5) var speed_scale: float = 1.0  # Speed multiplier for the rewind effect
signal done_rewinding

var rewinding: bool = false
var total_time_to_rewind: float = 0.0  # Total real time to rewind (adjusted by speed_scale)
var game_time_accumulated: float = 0.0
var real_time_accumulated: float = 0.0  # Total real time passed in the rewind process
var rewind_accumulator: float = 0.0  # Real-time accumulator for rewind progression

func _ready():
	# Initialize values
	total_time_to_rewind = rewind_duration * speed_scale
	print("Total time to rewind: ", total_time_to_rewind)  # Debug print

func _process(delta: float):
	if rewinding:
		compute_rewind(delta)
	else:
		update_rewind_values()

func update_rewind_values():
	# Loop through all the rewind resources and save the current values
	for rewind_resource in rewind_resources:
		var node = get_node_or_null(rewind_resource.node_path)
		if node:
			var value = node.get(rewind_resource.property_name)
			rewind_resource.add_value(value)

func compute_rewind(delta: float):
	# Accumulate the real time passed, accounting for the multiplier
	real_time_accumulated += delta
	print("Real time accumulated: ", real_time_accumulated)  # Debug print

	# Increase the rewind accumulator based on the speed_scale multiplier
	rewind_accumulator += speed_scale
	print("Rewind accumulator: ", rewind_accumulator)  # Debug print

	print("total_time_to_rewind: ", total_time_to_rewind)
	game_time_accumulated = real_time_accumulated * speed_scale
	
	print("game time accumulated: ", game_time_accumulated)

	# If we need to rewind, calculate the number of frames to pop based on the accumulator
	if rewind_accumulator >= 1.0:
		var frames_to_pop = int(rewind_accumulator)
		print("Frames to pop: ", frames_to_pop)  # Debug print
		
		

		# Make sure we don’t rewind too far (limit it to the desired rewind duration)
		if game_time_accumulated >= rewind_duration:
			stop_rewind()
			return

		# Pop values from the rewind resources
		for rewind_resource in rewind_resources:
			var node = get_node_or_null(rewind_resource.node_path)
			if node:
				for i in range(frames_to_pop):
					var last_value = rewind_resource.pop_value()
					if last_value != null:
						node.set(rewind_resource.property_name, last_value)

		# Subtract the number of frames popped from the accumulator
		rewind_accumulator -= frames_to_pop
		print("Rewind accumulator after popping: ", rewind_accumulator)  # Debug print

func rewind():
	rewinding = true
	real_time_accumulated = 0.0  # Reset real time accumulator
	rewind_accumulator = 0.0  # Reset the rewind accumulator
	print("Rewind started.")  # Debug print

func stop_rewind():
	rewinding = false
	done_rewinding.emit()
	print("Rewind stopped.")  # Debug print
