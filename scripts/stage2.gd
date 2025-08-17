extends Node

# Called when the scene is loaded
func _ready():
	_update_level_buttons()

# Update the level buttons based on the unlock status
func _update_level_buttons():
	for level in $Levels.get_children():
		var stage_level = _extract_stage_level_from_name(level.name)
		var stage = stage_level[0]
		var lvl = stage_level[1]

		# Check if the level is unlocked
		if ProgressManager.is_level_unlocked(stage - 1, lvl - 1):
			level.disabled = false
			level.set_meta("stage", stage)
			level.set_meta("level", lvl)
			level.connect('pressed', Callable(self, 'change_level').bind(level.name))
		else:
			level.disabled = true

# Helper function to extract stage and level from button name
func _extract_stage_level_from_name(button_name: String) -> Array:
	var level_start = button_name.find("level ") + 6
	var button_end = button_name.find(" button")
	var level = button_name.substr(level_start, button_end - level_start).to_int()
	return [2, level]  # This is Stage 2

# Handle the level button pressed signal
func change_level(lvl_no: String):
	var stage_level = _extract_stage_level_from_name(lvl_no)
	var stage = stage_level[0]
	var level = stage_level[1]

	# Update the ProgressManager with the current stage and level
	ProgressManager.set_current_stage_and_level(stage - 1, level - 1)  # <-- This line was added

	_load_level(stage - 1, level - 1)

# Load the level scene if it is unlocked
func _load_level(stage: int, level: int):
	var level_scene_path = "res://levels/Stage-%d Level%d.tscn" % [stage + 1, level + 1]
	if ProgressManager.is_level_unlocked(stage, level):
		get_tree().change_scene_to_file(level_scene_path)
	else:
		_show_locked_message()

# Show a message if the level is locked
func _show_locked_message():
	print("This level is locked.")

# This function gets called when a level is cleared
func on_level_cleared(stage: int, level: int):
	if stage == 1 and level == 4:  # If Stage 2 Level 5 is cleared
		ProgressManager.unlock_next_level(1, 4)  # Unlock Stage 3 Level 1

# Handle navigation button pressed functions
func _on_next_pressed():
	get_tree().change_scene_to_file("res://scenes/stage3.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/stage1.tscn")
