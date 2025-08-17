extends Node

func load_previous_level():
	# Get the current scene's file path
	var current_scene_path: String = get_tree().current_scene.scene_file_path
	
	# Check if the current scene is from Stage 1, 2, or 3
	var stage_1 = current_scene_path.find("Stage-1") != -1
	var stage_2 = current_scene_path.find("Stage-2") != -1
	var stage_3 = current_scene_path.find("Stage-3") != -1
	
	# Initialize default stage and level numbers
	var current_stage = 1
	var current_level = 1
	
	# Identify the current stage and level from the scene path
	if stage_1:
		current_stage = 1
	elif stage_2:
		current_stage = 2
	elif stage_3:
		current_stage = 3
	
	# Extract the level number from the path by looking for "Level" and the number after
	var level_start = current_scene_path.find("Level") + 5
	if level_start != -1:
		current_level = current_scene_path.substr(level_start, 1).to_int()

	# Check if the current level is 1
	if current_level == 1:
		# Move to the previous stage's level 5 if in stage 2 or 3
		if current_stage > 1:
			current_stage -= 1
			current_level = 5  # Assume each stage has 5 levels
		else:
			# If we're at the first stage, there is no previous level
			print("This is the first level of the first stage.")
			return
	else:
		# Otherwise, just move to the previous level
		current_level -= 1

	# Construct the path for the previous level
	var previous_scene_path = "res://levels/Stage-%d Level%d.tscn" % [current_stage, current_level]

	# Update ProgressManager's stage and level
	ProgressManager.current_stage = current_stage - 1  # Set to 0-based index
	ProgressManager.current_level = current_level - 1  # Set to 0-based index

	# Check if the previous scene exists
	if ResourceLoader.exists(previous_scene_path):
		# Load the previous scene
		print("Loading previous level:", previous_scene_path)
		get_tree().change_scene_to_file(previous_scene_path)
	else:
		print("Previous scene does not exist: ", previous_scene_path)
