extends Node

# Array to store the unlock status for each level in each stage
var level_unlocks = [
	[true, false, false, false, false],  # Stage 1 levels
	[false, false, false, false, false], # Stage 2 levels
	[false, false, false, false, false]  # Stage 3 levels
]

var current_stage = 0  # Track the current stage (starting from 0, which is Stage 1)
var current_level = 0  # Track the current level (starting from 0, which is Level 1)

# Define the save file path (works for both Android and desktop)
var save_file_path = "user://progress.save"  # Use user:// for cross-platform compatibility

# Function to unlock the next level based on the current stage and level
func unlock_next_level(stage: int, level: int):
	if stage >= 0 and stage < level_unlocks.size() and level >= 0 and level < level_unlocks[stage].size():
		if level < 4:
			level_unlocks[stage][level + 1] = true  # Unlock next level in the current stage
			print("Next level unlocked: Stage %d Level %d" % [stage + 1, level + 2])
		elif level == 4 and stage < 2:
			level_unlocks[stage + 1][0] = true  # Unlock first level of the next stage
			print("Stage %d Level 1 unlocked!" % [stage + 2])
		_save_progress()  # Save progress when a new level is unlocked

# Function to check if a level is unlocked
func is_level_unlocked(stage: int, level: int) -> bool:
	return level_unlocks[stage][level]

# Function to reset the progress to Stage 1 Level 1
func reset_progress():
	current_stage = 0
	current_level = 0
	_save_progress()  # Save progress after resetting
	print("Progress reset to Stage 1 Level 1")

# Function to set the current stage and level when a level is selected
func set_current_stage_and_level(stage: int, level: int):
	current_stage = stage
	current_level = level
	_save_progress()  # Save progress when setting the current level
	print("Progress set to Stage %d Level %d" % [stage + 1, level + 1])

# Function to save progress to a file
func _save_progress():
	var save_data = {
		"level_unlocks": level_unlocks,
		"current_stage": current_stage,
		"current_level": current_level
	}

	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data)  # Use static call to convert the data to JSON format
		file.store_string(json_string)  # Save the JSON string to the file
		file.close()
		print("Progress saved successfully.")
	else:
		print("Failed to open file for saving.")

# Function to load progress from a file
func _load_progress():
	# Check if the file exists before attempting to open
	if not FileAccess.file_exists(save_file_path):
		print("Save file does not exist. Starting with default progress.")
		return

	var file = FileAccess.open(save_file_path, FileAccess.READ)
	if file:
		var file_content = file.get_as_text()
		var json = JSON.new()  # Create an instance of JSON
		
		# parse() returns an integer error code
		var parse_result = json.parse(file_content)

		# Check if the parsing was successful by checking the error code
		if parse_result != OK:  # Check if the parsing was successful
			print("Error parsing JSON: ", parse_result)  # Debug info
			file.close()
			return
		
		# If parsing is successful, we can access the result
		var result = json.get_data()  # Get the parsed data
		
		# Ensure that the result contains the required data
		if typeof(result) == TYPE_DICTIONARY and result.has("level_unlocks") and result.has("current_stage") and result.has("current_level"):
			level_unlocks = result["level_unlocks"]
			current_stage = result["current_stage"]
			current_level = result["current_level"]
			print("Progress loaded successfully.")
		else:
			print("Save file does not contain required keys or has an invalid format.")
		
		file.close()
	else:
		print("Unable to open save file for reading.")
