extends Label

@onready var timer = $Timer
@onready var audio_player = $CorrectSfx  # Reference to the AudioStreamPlayer node

func correct_result(message: String, detail: String):
	# Display the message and set the label to visible
	text = message + " " + detail
	visible = true
	timer.start()
	
	# Play the sound only if the label is currently visible
	if visible:
		audio_player.play()  # Play the sound effect when the correct result is shown

func _on_timer_timeout():
	# Hide the label and stop any sounds after the timer ends
	visible = false
	audio_player.stop()
