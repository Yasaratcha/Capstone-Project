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
		"question": "Write an SQL query to count the number of products in each category from “Products” table. List the category and the number of products in that category labeled as “ProductCount”.",
		"answer": "SELECT Category, COUNT(*) AS ProductCount FROM Products GROUP BY Category;"
	},
	{
		"question": "Write an SQL query to find all products whose names contain the word 'Gadget' from 'Products” table. List the ProductID and ProductName for these products.",
		"answer": "SELECT ProductID, ProductName FROM Products WHERE ProductName LIKE '%Gadget%';"
	},
	{
		"question": "Write a SQL query to adjust the price of products by adding $5 to each product's price. List the ProductID, ProductName, and Price labeled as NewPrice.",
		"answer": "SELECT ProductID, ProductName, Price + 5 AS NewPrice FROM Products;"
	},
	{
		"question": "You have a table named “Employees” that contains employee_id, first_name, and last_name and a table named “Departments” that contains department_id, employee_id, and department_name. Write an SQL query to list all employees along with their department names. If an employee is not assigned to a department, show NULL for the department name.",
		"answer": "SELECT Employees.employee_id, Employees.first_name, Employees.last_name, Departments.department_name FROM Employees LEFT JOIN Departments ON Employees.employee_id = Departments.employee_id;"
	},
	{
		"question": "Find the most expensive product in the Products table. Get the product_name and price. Limit to 5 in descending order.",
		"answer": "SELECT product_name, price FROM Products ORDER BY price DESC LIMIT 5;"
	},
	{
		"question": "Find employees whose salary is above the average salary. Get the employee_name and salary from “Employees” table.",
		"answer": "SELECT employee_name, salary FROM Employees WHERE salary > (SELECT AVG(salary) FROM Employees);"
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
		"SELECT Category, COUNT(*) AS ProductCount FROM Products GROUP BY Category;":
			return "Hint: Use 'COUNT' with 'GROUP BY' to group and count records based on a category."
		"SELECT ProductID, ProductName FROM Products WHERE ProductName LIKE '%Gadget%';":
			return "Hint: Use 'LIKE' to filter the name and get the products that start with gadgets"
		"SELECT ProductID, ProductName, Price + 5 AS NewPrice FROM Products;":
			return "Hint: Use arithmetic operators like '+' in the SELECT clause to modify values."
		"SELECT e1.employee_name AS employee, e2.employee_name AS manager FROM Employees e1 JOIN Employees e2 ON e1.manager_id = e2.employee_id;":
			return "Hint: To retrieve data from two tables and include all records from one table even if there’s no match in the other, consider using a type of JOIN that keeps unmatched records. Look for a JOIN that includes all rows from the first table."
		"SELECT product_name, price FROM Products LIMIT 1;":
			return "Hint: To find the highest-priced item, look for a way to order products by price and limit your results to just one item. Consider using a sorting function combined with a way to select only the top result."
		"SELECT employee_name, salary FROM Employees WHERE salary > (SELECT AVG(salary) FROM Employees);":
			return "Hint: Use a subquery with 'AVG' to compare each row's value against the average."
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
