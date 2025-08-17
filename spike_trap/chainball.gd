extends Node2D

@export_group("Length and Chain Settings")
@export var length := 7
@export var distance_between_chains := 12

@export_group("Path Settings")
@export var curve : Curve
@export var duration := 5.0
var elapsed = 0

@onready var damage_area = $Area2D/hitbox
@onready var _spike_chain = preload("res://spike_trap/spike_chain.tscn")

func _ready():
	damage_area.position = Vector2(0, (length - 1) * distance_between_chains)
	
	for i in range(length):
		var chain = _spike_chain.instantiate()
		add_child(chain, false, Node.INTERNAL_MODE_FRONT)
		chain.position = Vector2(0, i * distance_between_chains)
		
func _physics_process(delta):
	elapsed += delta
	if elapsed > duration:
		elapsed = fmod(elapsed, duration)
	rotation_degrees = curve.sample(elapsed / duration)

func _on_hitbox_body_entered(body):
	if body.name == "Player":
		body.reset_position()
