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
		"question": "Find the average salary of all employees.",
		"answer": "SELECT AVG(salary) FROM Employees;"
	},
	{
		"question": "Retrieve the employee_name and salary of employees whose salaries are between $40,000 and $60,000.",
		"answer": "SELECT employee_name, salary FROM Employees WHERE salary BETWEEN 40000 AND 60000;"
	},
	{
		"question": "Get the minimum and maximum age from ‘Employees’ table.",
		"answer": "SELECT MIN(age), MAX(age) FROM Employees;"
	},
	{
		"question": "Display the first_name of employees who are in the IT department and have a salary greater than $40,000 from the “Employees” table.",
		"answer": "SELECT first_name FROM Employees WHERE department = 'IT' AND salary > 40000;"
	},
	{
		"question": "Write an SQL query to select all employees whose salary is not between 40,000 and 60,000.",
		"answer": "SELECT * FROM Employees WHERE salary NOT BETWEEN 40000 AND 60000;"
	},
	{
		"question": "Calculate the sum of discount given in the ‘Sales’ table.",
		"answer": "SELECT SUM(discount) FROM Sales;"
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
	$Panel/Send.pressed.connect(_on_send_pressed)
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

# Function to get the hint based on the current answer
func show_hint_result(answer: String) -> String:
	match answer:
		"SELECT AVG(salary) FROM Employees;":
			return "Hint: Use an aggregation function like AVG to calculate the average."
		"SELECT employee_name, salary FROM Employees WHERE salary BETWEEN 40000 AND 60000;":
			return "Hint: Use 'BETWEEN' to filter a range of values."
		"SELECT MIN(age), MAX(age) FROM Employees;":
			return "Hint: You can use 'MIN' and 'MAX' functions to get the smallest and largest values."
		"SELECT first_name FROM Employees WHERE department = 'IT' AND salary > 40000;":
			return "Hint: Use the 'LIKE' operator with a pattern to find names starting with a specific letter."
		"SELECT * FROM Employees WHERE salary NOT BETWEEN 40000 AND 60000;":
			return "Hint: Use 'NOT BETWEEN' to exclude a specific range of values."
		"SELECT SUM(discount) FROM Sales;":
			return "Hint: Use 'SUM()' to exclude specific values from the results."
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
