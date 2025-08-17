extends Label

@onready var timer = $Timer
@onready var audio_player = $WrongSfx  # Reference to the AudioStreamPlayer node

func wrong_result(message: String, detail: String):
	# Display the message and set the label to visible
	text = message + " " + detail
	visible = true
	timer.start()
	
	# Play the sound only if the label is currently visible
	if visible:
		audio_player.play()  # Play the sound effect when the wrong result is shown

func _on_timer_timeout():
	# Hide the label and stop any sounds after the timer ends
	visible = false
	audio_player.stop()
