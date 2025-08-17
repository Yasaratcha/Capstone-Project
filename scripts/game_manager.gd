extends Node


# Dictionary to track collected fruits and answered questions
var collected_fruits = []
var answered_questions = {}

func is_fruit_collected(fruit_id: int) -> bool:
	return fruit_id in collected_fruits

func add_point(fruit_id: int):
	collected_fruits.append(fruit_id)

func are_all_fruits_collected() -> bool:
	return collected_fruits.size() == 3  # Assuming there are 3 fruits in total

func mark_question_answered(fruit_id: int):
	answered_questions[fruit_id] = true

func are_all_questions_answered() -> bool:
	return answered_questions.size() == 3  # Ensure all questions for the 3 fruits are answered

func get_current_stars() -> int:
	return get_node("/root/Node/Pause canvas layer/CanvasLayer/Question").currentStar

# Centralized check and trigger function
func check_and_trigger_star_rating():
	# Check if all fruits are collected and all questions are answered
	if are_all_fruits_collected() and are_all_questions_answered():
		# Trigger the StarRatingSystem
		var star_rating_system_node = get_node("/root/Node/StarRatingSystem/StarRatingControl")
		if star_rating_system_node:
			# Pass the current star count to the star rating system
			star_rating_system_node.star_rating_system(get_current_stars())

# New function to reset collected fruits and answered questions
func reset_fruits():
	# Clear the collected fruits and reset answered questions
	collected_fruits.clear()
	answered_questions.clear()
