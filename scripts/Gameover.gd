extends CanvasLayer
#Hide the gameover scene
func _ready():
	self.hide()
# On pressed restart the game
func _on_retry_pressed():
	get_tree().paused = false #Collects all data/tree and unpause the game
	GameManager.reset_fruits()  # Reset the collected fruits
	get_tree().reload_current_scene()  # Restart the game
	# On pressed takes you to the main menu scene
func _on_mainmenu_pressed():
	get_tree().paused = false  #Collects all data/tree and sets paused as false
	GameManager.reset_fruits()  # Reset the collected fruits
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	#
func game_over():
	get_tree().paused = true  #Collects all data/tree and pauses the game
	self.show() #Shows the gameover scene
