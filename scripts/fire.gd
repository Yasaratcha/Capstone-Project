extends StaticBody2D

@onready var finite_state_machine = $FiniteStateMachine
@onready var animated_sprite2d = $AnimatedSprite2D
@onready var step_area = $StepArea
@onready var hitbox = $hitbox/CollisionShape2D

func _ready():
	finite_state_machine.change_state("off")

func _physics_process(delta):
	finite_state_machine.physics_process(delta)

func _on_step_area_body_entered(_body):
	if finite_state_machine.current_state_name == "off":
		finite_state_machine.change_state("hit")


func _on_hitbox_body_entered(body):
	if body.name == "Player":
		body.reset_position()
