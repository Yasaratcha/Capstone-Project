extends Control

func _ready():
	self.hide()
	update_level_buttons()  # Update button visibility when the scene is ready

# Function to update the visibility of previous and next level buttons
func update_level_buttons():
	# Get the current stage and level from ProgressManager
	var current_stage = ProgressManager.current_stage
	var current_level = ProgressManager.current_level
	
	# Hide the "previouslvl" button if on Stage 1 Level 1
	if current_stage == 0 and current_level == 0:
		$Panel/Control2/previouslvl.hide()
	else:
		$Panel/Control2/previouslvl.show()

	# Hide the "nextlvl" button if on Stage 3 Level 5 (final level)
	if current_stage == 2 and current_level == 4:
		$Panel/Control3/nextlvl.hide()
	else:
		$Panel/Control3/nextlvl.show()

# Function triggered when the "Next Level" button is pressed
func _on_next_lvl_pressed():
	GameManager.reset_fruits()  # Reset the collected fruits
	get_tree().paused = false  # Unpause the game

	# Get the current stage and level from ProgressManager
	var current_stage = ProgressManager.current_stage
	var current_level = ProgressManager.current_level

	# Declare scene_path at the beginning, to be assigned later
	var scene_path = ""

	# Unlock the next level and transition
	if current_level < 4:  # If not at the last level of the current stage
		ProgressManager.unlock_next_level(current_stage, current_level)
		var next_level = current_level + 1
		scene_path = "res://levels/Stage-%d Level%d.tscn" % [current_stage + 1, next_level + 1]
		print("Loading next level:", scene_path)
		ProgressManager.current_level = next_level  # Update current level

	elif current_level == 4 and current_stage < 2:  # If on the last level of the stage, move to the next stage
		ProgressManager.unlock_next_level(current_stage, current_level)
		var next_stage = current_stage + 1
		scene_path = "res://levels/Stage-%d Level1.tscn" % [next_stage + 1]
		print("Loading next stage:", scene_path)
		ProgressManager.current_stage = next_stage  # Move to the next stage
		ProgressManager.current_level = 0  # Reset to the first level of the new stage

	else:
		print("No more levels to unlock or progress to.")
		return  # Exit if there's no level to load

	# Change scene to the next level
	var error = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		print("Failed to load scene:", scene_path)

	# Update the visibility of buttons after changing the level
	update_level_buttons()

# Star rating system logic
func star_rating_system(currentStar: int):
	var star_container = $starContainer
	star_container.updateStars(currentStar)
	
	if GameManager.are_all_fruits_collected() and GameManager.are_all_questions_answered():
		get_tree().paused = true
		self.show()  # Show the star rating system when conditions are met

# Updated function to handle the "Stage" button press
func _on_stage_button_pressed():
	GameManager.reset_fruits()  # Reset the collected fruits
	get_tree().paused = false
	
	# Set the stage and level in ProgressManager to Stage 1 Level 1 before changing scene
	ProgressManager.current_stage = 0
	ProgressManager.current_level = 0
	
	# Change the scene to Stage 1 Level 1
	get_tree().change_scene_to_file("res://scenes/stage1.tscn")
	
	# Use call_deferred to update level buttons after the scene is fully loaded
	call_deferred("update_level_buttons")

# Function triggered when the "Previous Level" button is pressed
func _on_previouslvl_pressed():
	GameManager.reset_fruits()  # Reset the collected fruits
	get_tree().paused = false
	Previouslvl.load_previous_level()  # Load the previous level

	# Update the visibility of buttons after changing the level
	update_level_buttons()
