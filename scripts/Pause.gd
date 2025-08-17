# PauseMenu.gd

extends Node

var is_paused = false
@onready var PauseMenu = $PauseMenu
@onready var settings = $settings
@onready var StarRatingSystem = $"../../StarRatingSystem/StarRatingControl"  # Ensure this path is correct

func _ready():
	PauseMenu.visible = false

func _on_settings_pressed():
	get_tree().paused = true
	PauseMenu.visible = true

func _on_resume_pressed():
	get_tree().paused = false
	PauseMenu.visible = false
	if StarRatingSystem:
		StarRatingSystem.update_level_buttons()  # Update buttons when resuming the game

func _on_restart_pressed():
	PauseMenu.visible = false
	get_tree().paused = false
	GameManager.reset_fruits()  # Reset the collected fruits
	get_tree().reload_current_scene()
	if StarRatingSystem:
		StarRatingSystem.update_level_buttons()  # Update buttons after restart

func _on_quit_pressed():
	PauseMenu.visible = false
	get_tree().paused = false
	GameManager.reset_fruits()  # Reset the collected fruit
	
	# Reset the current stage and level to Stage 1 Level 1
	ProgressManager.reset_progress()

	# Change the scene to Stage 1 Level 1 (adjust the path if needed)
	get_tree().change_scene_to_file("res://scenes/stage1.tscn")
	
	# Update level buttons after quitting
	if StarRatingSystem:
		StarRatingSystem.update_level_buttons()
