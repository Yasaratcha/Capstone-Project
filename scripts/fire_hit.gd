extends State

func enter():
	object.animated_sprite2d.play("hit")

func physics_process(_delta):
	if not object.animated_sprite2d.is_playing():
		change_state("on")
