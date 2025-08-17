extends Node

@onready var heart_container = $"Pause canvas layer/CanvasLayer2/heart_container"
@onready var player = $"scene objects/Player"

@onready var starContainer = $StarRatingSystem/StarRatingControl/starContainer
@onready var Question = $"Pause canvas layer/CanvasLayer/Question"


# Called when the node enters the scene tree for the first time.
func _ready():
	heart_container.setMaxHearts(player.maxHealth)
	heart_container.updateHearts(player.currentHealth)
	player.healthChanged.connect(heart_container.updateHearts)
	
	starContainer.setMaxStars(Question.maxStars)
	starContainer.updateStars(Question.currentStar)
	Question.starChanged.connect(starContainer.updateStars)
