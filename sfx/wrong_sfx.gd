extends AudioStreamPlayer


# Function to check if the wrong label is triggered and play sound
func check_wrong_label(is_wrong_label: bool) -> void:
	if is_wrong_label:
		play()
	else:
		stop()
