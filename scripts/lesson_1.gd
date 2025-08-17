extends Node2D

# Array to store the loaded images
var pages: Array[Texture] = []
# Current page index
var current_page: int = 0

# A reference to the TextureRect node where the image will be displayed
@onready var image_display: TextureRect = $TextureRect

# Load the images at the start
func _ready():
	# Load the images manually
	load_images()
	
	# Show the first page if images are loaded
	if pages.size() > 0:
		show_page(current_page)

# Load the images manually by specifying the file paths
func load_images():
	# List of image paths
	var img_paths = [
		"res://Learning Materials/Lesson1/Lesson-1-01.png",
		"res://Learning Materials/Lesson1/Lesson-1-02.png",
		"res://Learning Materials/Lesson1/Lesson-1-03.png",
		"res://Learning Materials/Lesson1/Lesson-1-04.png",
		"res://Learning Materials/Lesson1/Lesson-1-05.png",
		"res://Learning Materials/Lesson1/Lesson-1-06.png",
		"res://Learning Materials/Lesson1/Lesson-1-07.png",
		"res://Learning Materials/Lesson1/Lesson-1-08.png",
		"res://Learning Materials/Lesson1/Lesson-1-09.png",
		"res://Learning Materials/Lesson1/Lesson-1-10.png",
		"res://Learning Materials/Lesson1/Lesson-1-11.png",
		"res://Learning Materials/Lesson1/Lesson-1-12.png",
		"res://Learning Materials/Lesson1/Lesson-1-13.png",
		"res://Learning Materials/Lesson1/Lesson-1-14.png",
		"res://Learning Materials/Lesson1/Lesson-1-15.png",
		"res://Learning Materials/Lesson1/Lesson-1-16.png",
		"res://Learning Materials/Lesson1/Lesson-1-17.png",
		"res://Learning Materials/Lesson1/Lesson-1-18.png",
		"res://Learning Materials/Lesson1/Lesson-1-19.png",
		"res://Learning Materials/Lesson1/Lesson-1-20.png",
		"res://Learning Materials/Lesson1/Lesson-1-21.png",
		"res://Learning Materials/Lesson1/Lesson-1-22.png",
		"res://Learning Materials/Lesson1/Lesson-1-23.png",
		"res://Learning Materials/Lesson1/Lesson-1-24.png",
		"res://Learning Materials/Lesson1/Lesson-1-25.png",
		"res://Learning Materials/Lesson1/Lesson-1-26.png",
		"res://Learning Materials/Lesson1/Lesson-1-27.png",
		"res://Learning Materials/Lesson1/Lesson-1-28.png",
		"res://Learning Materials/Lesson1/Lesson-1-29.png",
		"res://Learning Materials/Lesson1/Lesson-1-30.png",
		"res://Learning Materials/Lesson1/Lesson-1-31.png",
		"res://Learning Materials/Lesson1/Lesson-1-32.png",
		"res://Learning Materials/Lesson1/Lesson-1-33.png",
		"res://Learning Materials/Lesson1/Lesson-1-34.png",
		"res://Learning Materials/Lesson1/Lesson-1-35.png"
	]

	# Iterate through the image paths and load them
	for img_path in img_paths:
		var img_texture = load(img_path)
		if img_texture:
			pages.append(img_texture)

# Function to display the current page
func show_page(index: int):
	if index >= 0 and index < pages.size():
		image_display.texture = pages[index]

# Function to go to the next page
func _on_next_page_pressed():
	if current_page < pages.size() - 1:
		current_page += 1
		show_page(current_page)

# Function to go to the previous page
func _on_previous_page_pressed():
	if current_page > 0:
		current_page -= 1
		show_page(current_page)

# Function to handle exit button
func _on_exit_pressed():
	get_tree().change_scene_to_file("res://scenes/learning_materials.tscn")
