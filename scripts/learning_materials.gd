extends Node



func _on_lesson_1_pressed():
	get_tree().change_scene_to_file("res://scenes/lesson_1.tscn")


func _on_lesson_2_pressed():
	get_tree().change_scene_to_file("res://scenes/lesson_2.tscn")


func _on_lesson_3_pressed():
	get_tree().change_scene_to_file("res://scenes/lesson_3.tscn")


func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
