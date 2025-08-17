extends Path2D

@onready var path_follow = $PathFollow2D
@onready var damage_area = $hitbox

@export_group("Speed Settings")
@export var constant_acceleration := 150
@export var speed_curve : Curve = Curve.new()  # Create a new instance
@export var has_chains := true

var chain_resource = preload("res://saw/chain.tscn")

func _ready():

	if has_chains:
		for i in curve.point_count:
			var chain = chain_resource.instantiate()
			add_child(chain, false, Node.INTERNAL_MODE_FRONT)
			chain.position = curve.get_point_position(i)

func _physics_process(delta):
	var speed = constant_acceleration if not speed_curve else speed_curve.sample(path_follow.progress_ratio)
	path_follow.progress = path_follow.progress + speed * delta

func _on_hitbox_body_entered(body):
	if body.name == "Player":
		body.reset_position()
