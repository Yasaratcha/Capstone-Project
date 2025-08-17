extends Area2D

@export var fruit_id: int

func _ready():
	# Check if this fruit has already been collected
	if GameManager.is_fruit_collected(fruit_id):
		queue_free()  # Remove the fruit from the scene

func _on_body_entered(body):
	if body.name == "Player":
		# Add points when the fruit is collected
		GameManager.add_point(fruit_id)
		
		# Show the question scene
		show_question_scene()

		# Remove the fruit when collected
		queue_free()

func show_question_scene():
	# Get the Question node using an absolute path
	var question_scene = get_node("/root/Node/Pause canvas layer/CanvasLayer/Question")
	
	# Ensure the node is valid and show it
	if question_scene and question_scene is Control:
		question_scene.show_question(fruit_id)
