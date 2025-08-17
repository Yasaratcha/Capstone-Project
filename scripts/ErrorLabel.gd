extends Label

@onready var timer = $Timer

# Function to show an error message
func show_error_message(message: String):
	text = message
	visible = true
	timer.start()

func _on_timer_timeout():
	visible = false
