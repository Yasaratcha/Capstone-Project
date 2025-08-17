extends Panel

@onready var timer = $Timer

func _ready():
	get_tree().paused = true
	timer.start()

func _on_timer_timeout():
	get_tree().paused = false
	self.hide()
