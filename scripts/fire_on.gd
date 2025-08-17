extends State

@onready var timer = $Timer

func enter():
	object.animated_sprite2d.play("on")
	object.hitbox.set_deferred("disabled", false)

func physics_process(_delta):
	if timer.is_stopped() && not object.step_area.has_overlapping_bodies():
		timer.start()

func exit():
	object.hitbox.set_deferred("disabled", true)

func _on_timer_timeout():
	change_state("off")
