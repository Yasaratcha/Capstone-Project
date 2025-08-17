extends AudioStreamPlayer

# Function to check if the correct label is triggered and play sound
func check_correct_label(is_correct_label: bool) -> void:
	if is_correct_label:
		play()
	else:
		stop()
