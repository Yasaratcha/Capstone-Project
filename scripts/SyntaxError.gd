extends Label

@onready var timer = $Timer

func hint_result(message: String, detail: String):
	text = message + " " + detail
	visible = true
	timer.start()  # Start a 5-second timer for the hint

func _on_timer_timeout():
	visible = false  # Hide the hint after the timeout
