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
		"question": "Add James Perez to the 'Employees' table in the employee_name column.",
		"answer": "INSERT INTO Employees (employee_name) VALUES ('James Perez');"
	},
	{
		"question": "How can you insert a new order with order_id = 2001 and total_amount = 150.00 into the 'Orders' table?",
		"answer": "INSERT INTO Orders (order_id, total_amount) VALUES (2001, 150.00);"
	},
	{
		"question": "Write a query to insert a new student into the 'Students' table with student_id = 123, student_name = 'Alice Smith', major = 'Computer Science', GPA = 3.5.",
		"answer": "INSERT INTO Students (student_id, student_name, major, GPA) VALUES (123, 'Alice Smith', 'Computer Science', 3.5);"
	},
	{
		"question": "Write an SQL query to insert a new employee into the Employees table with the following details: employee_id = 101, first_name = 'John', last_name = 'Doe', department = 'IT', salary = 70000.",
		"answer": "INSERT INTO Employees (employee_id, first_name, last_name, department, salary) VALUES (101, 'John', 'Doe', 'IT', 70000);"
	},
	{
		"question": "Write a query to add a new customer with customer_id = 10 and name = 'Jane Smith' into the 'Customers' table.",
		"answer": "INSERT INTO Customers (customer_id, name) VALUES (10, 'Jane Smith');"
	},
	{
		"question": "How do you insert a new product with product_id = 1, product_name = 'Notebook', and price = 5.00 into the 'Products' table?",
		"answer": "INSERT INTO Products (product_id, product_name, price) VALUES (1, 'Notebook', 5.00);"
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
		"INSERT INTO Employees (employee_name) VALUES ('James Perez');":
			return "Hint: Use 'INSERT INTO' to add data to the Employees table with one column."
		"INSERT INTO Orders (order_id, total_amount) VALUES (2001, 150.00);":
			return "Hint: Use 'INSERT INTO' with multiple column names to specify values."
		"INSERT INTO Students (student_id, student_name, major, GPA) VALUES (123, 'Alice Smith', 'Computer Science', 3.5);":
			return "Hint: Use 'INSERT INTO' to insert data into multiple columns including GPA."
		"INSERT INTO Employees (employee_id, first_name, last_name, department, salary) VALUES (101, 'John', 'Doe', 'IT', 70000);":
			return "Hint: Use 'INSERT INTO' with all relevant columns of the Employees table."
		"INSERT INTO Customers (customer_id, name) VALUES (10, 'Jane Smith');":
			return "Hint: Use 'INSERT INTO Customers' to insert customer data."
		"INSERT INTO Products (product_id, product_name, price) VALUES (1, 'Notebook', 5.00);":
			return "Hint: Use 'INSERT INTO Products' to add a product with its details."
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
