extends CharacterBody2D

signal healthChanged

const SPEED = 250.0
const JUMP_VELOCITY = -400.0
@onready var sprite_2d = $Sprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Define the starting position variable
var start_position : Vector2

# Health of the player
@export var maxHealth = 3
@onready var currentHealth: int = maxHealth

# Damage cooldown to prevent multiple hits
var damage_cooldown = 0.1
var damage_timer = 0.0

func _ready():
	# Store the initial position of the player when the game starts
	start_position = position

func _physics_process(delta):
	# Animation
	if (velocity.x > 1 or velocity.x < -1):
		sprite_2d.animation = "running"
	else:
		sprite_2d.animation = "default"
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		sprite_2d.animation = "jumping"

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 20)

	move_and_slide()

	# Handle sprite flipping based on movement direction
	var is_left = velocity.x < 0
	sprite_2d.flip_h = is_left

	# Update damage timer
	if damage_timer > 0:
		damage_timer -= delta

# Function to reset the player position to the starting point
func reset_position():
	position = start_position
	
func _on_hurtbox_area_entered(area):
	if area.name == "hitbox" and damage_timer <= 0:
		currentHealth -= 1
		damage_timer = damage_cooldown  # Start cooldown timer
		healthChanged.emit(currentHealth)
		
		if currentHealth <= 0:
			get_node("../../Gameover").game_over()



