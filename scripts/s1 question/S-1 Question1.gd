extends Control

@onready var ErrorLabel = $Panel/ErrorLabel
@onready var CorrectLabel = $Panel/CorrectLabel
@onready var WrongLabel = $Panel/WrongLabel
@onready var timer = $Timer  
@onready var HintLabel = $Panel/HintLabel  # Label to display the hint
@onready var HintTimer = $Panel/HintLabel/Timer  # Timer inside the HintLabel node

signal starChanged

var questions = [
	{
		"question": "Write an SQL query to find all employees from “Employees” table.",
		"answer": "SELECT * FROM Employees;"
	},
	{
		"question": "Write an SQL query to find the “first_name, and last_name” from “Customers” table.",
		"answer": "SELECT first_name, last_name FROM Customers;"
	},
	{
		"question": "You want to compile the list of email_address column from the “Users” table. How would you retrieve this?",
		"answer": "SELECT email_address FROM Users;"
	},
	{
		"question": "You have a “Subscriptions” table. How would you retrieve all from customer_name column?",
		"answer": "SELECT customer_name FROM Subscriptions;"
	},
	{
		"question": "How would you retrieve all the data from a table named “Orders”?",
		"answer": "SELECT * FROM Orders;"
	},
	{
		"question": "Write an SQL query to retrieve the product_name and price columns from a table named “Products.”",
		"answer": "SELECT product_name, price FROM Products;"
	}
]

var current_question = {}
var current_answer = ""
var current_fruit_id = -1

@export var maxStars = 3
var currentStar = 0
var answered_fruits = []
var is_correct_answer = false  # Add a flag to track if the answer is correct

# Flag to check if the star rating system is active
var is_star_rating_active = false

func _ready():
	self.visible = false
	starChanged.connect(get_node("/root/Node/StarRatingSystem/StarRatingControl").star_rating_system)

	# Connect the timer's timeout signal to a function
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true  # Ensure it's a one-shot timer (runs once then stops)

	HintTimer.timeout.connect(_on_hint_timer_timeout)  # Connect the HintTimer timeout signal

# Function to trigger star rating and keep the game paused
func trigger_star_rating():
	is_star_rating_active = true
	get_node("/root/Node/StarRatingSystem/StarRatingControl").visible = true

func _on_send_pressed():
	var user_input = $Panel/LineEdit.text

	if user_input.strip_edges() == "":
		show_error_message("Input cannot be empty!")
		return

	# Check if the user's input matches the correct answer
	if user_input.strip_edges() == current_answer.strip_edges():
		print("Correct answer!")
		currentStar += 1
		starChanged.emit(currentStar)
		show_correct_result("Correct answer!")
	
	else:
		print("Wrong answer!")
		show_wrong_result("Wrong answer!")
	

	# Mark the question as answered for the corresponding fruit
	GameManager.mark_question_answered(current_fruit_id)


	# Clear the LineEdit input field
	clear_input()

	# Start the timer to delay closing the panel by 2 seconds (whether correct or wrong)
	timer.start(2)  # Start the timer with a 2-second delay

	# After answering the question, check if all questions are answered and trigger the star rating system
	if GameManager.are_all_questions_answered():
		trigger_star_rating()

# Function to show the question scene
func show_question(fruit_id: int):
	current_fruit_id = fruit_id
	current_question = questions[randi() % questions.size()]
	current_answer = current_question["answer"]

	$Panel/Question.text = current_question["question"]
	self.visible = true
	
	# Only pause the game if the star rating system is not active
	if not is_star_rating_active:
		get_tree().paused = true

# Function to clear the LineEdit text
func clear_input():
	$Panel/LineEdit.text = ""

# Function to display the hint with SQL syntax based on the current question
func _on_hint_pressed():
	# Hide the question label and display the hint
	$Panel/Question.visible = false  # Hide the question label
	HintLabel.visible = true
	HintLabel.text = show_hint_result(current_answer)  # Display the relevant hint
	
	# Start the timer to hide the hint after 5 seconds
	HintTimer.start(5)

# Function triggered after the HintTimer times out
func _on_hint_timer_timeout():
	HintLabel.visible = false  # Hide the hint label
	$Panel/Question.visible = true  # Show the question panel again

# Function to get the SQL syntax hint based on the current question
func show_hint_result(answer: String) -> String:
	match answer:
		"SELECT * FROM Employees;":
			return "Hint: Use 'SELECT *' to retrieve all columns from the Employees table."
		"SELECT first_name, last_name FROM Employees;":
			return "Hint: Specify the columns (first_name, last_name) in the SELECT clause."
		"SELECT email_address FROM Users;":
			return "Hint: Use 'SELECT' with the 'email_address' column from the Users table."
		"SELECT customer_name FROM Subscriptions;":
			return "Hint: Use 'SELECT customer_name' from the Subscriptions table."
		"SELECT * FROM Orders;":
			return "Hint: Use 'SELECT *' to retrieve all columns from the Orders table."
		"SELECT product_name, price FROM Products;":
			return "Hint: Use 'SELECT product_name, price' from the Products table."
		_:
			return "No specific hint available for this query."

# Function to show an error message
func show_error_message(message: String):
	ErrorLabel.show_error_message(message)  # Call the ErrorLabel's method to handle the error display

# Function to display the correct result and trigger the CorrectLabel timer
func show_correct_result(message: String):
	CorrectLabel.correct_result(message, "")  # Calls the correct_result function in CorrectLabel

# Function to display the wrong result and trigger the WrongLabel timer
func show_wrong_result(message: String):
	WrongLabel.wrong_result(message, "")  # Calls the wrong_result function in WrongLabel

# Function triggered after the timer timeout to hide the panel
func _on_timer_timeout():
	self.visible = false  # Hide the question panel
	
	# Only unpause the game if the star rating system is not active
	if not is_star_rating_active:
		get_tree().paused = false
