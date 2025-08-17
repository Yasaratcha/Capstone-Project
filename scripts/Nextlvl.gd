# ProgressManager script to handle unlocking and checking levels
extends Node

# Array to store the unlock status for each level in each stage
# false = locked, true = unlocked
var level_unlocks = [
	[true, false, false, false, false],  # Stage 1 levels
	[false, false, false, false, false], # Stage 2 levels
	[false, false, false, false, false]  # Stage 3 levels
]

# Function to unlock the next level based on player's current progress
func unlock_next_level(stage: int, level: int):
	if stage >= 0 and stage < level_unlocks.size() and level >= 0 and level < level_unlocks[stage].size():
		# Check if the current level is complete, then unlock the next one
		if level < 4:
			level_unlocks[stage][level + 1] = true  # Unlock the next level in the current stage
		elif level == 4 and stage < 2:
			level_unlocks[stage + 1][0] = true  # Unlock the first level of the next stage

# Function to check if a level is unlocked
func is_level_unlocked(stage: int, level: int) -> bool:
	return level_unlocks[stage][level]

# Function to reset all level progress
func reset_progress():
	level_unlocks = [
		[true, false, false, false, false],  # Stage 1 levels
		[false, false, false, false, false], # Stage 2 levels
		[false, false, false, false, false]  # Stage 3 levels
	]

# Game logic to load the next level and check unlock status

func load_next_level():
	# Get the current scene's file path
	var current_scene_path: String = get_tree().current_scene.scene_file_path
	
	# Check if the current scene is from Stage 1 or any other stage
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

	# Unlock the next level based on the current level
	ProgressManager.unlock_next_level(current_stage - 1, current_level - 1)

	# Check if the next level is unlocked before loading it
	var next_stage = current_stage
	var next_level = current_level + 1

	# If current level is 5, move to the next stage
	if current_level == 5:
		next_stage += 1
		next_level = 1

	# Construct the path for the next level
	var next_scene_path = "res://levels/Stage-%d Level%d.tscn" % [next_stage, next_level]

	# Check if the next level is unlocked
	if ProgressManager.is_level_unlocked(next_stage - 1, next_level - 1):
		# Check if the next scene exists
		if ResourceLoader.exists(next_scene_path):
			# Load the next scene
			get_tree().change_scene_to_file(next_scene_path)
		else:
			print("Next scene does not exist: ", next_scene_path)
	else:
		print("Next level is locked.")
