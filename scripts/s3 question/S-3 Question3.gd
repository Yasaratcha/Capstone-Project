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
		"question": "You have two tables, “Customers” and “Orders”. The Customers table contains customer information, and the Orders table contains order details. You want to find the names of customers who have placed orders. Write an SQL query to retrieve the “customer_name” and “order_date” for customers who have placed orders. Use the “customer_id” column to join the Customers and Orders tables. (Include the complete table name).",
		"answer": "SELECT Customers.customer_name, Orders.order_date FROM Customers JOIN Orders ON Customers.customer_id = Orders.customer_id;"
	},
	{
		"question": "You have a 'Sales' table that records sales transactions with 'sale_amount'. Write a SQL query to calculate the total number of sales transactions using 'sale_id' and the total sales amount using 'sale_amount'. Ensure that the results are returned in a single row with columns labeled 'total_transactions' and 'total_sales'.",
		"answer": "SELECT COUNT(sale_id) AS total_transactions, SUM(sale_amount) AS total_sales FROM Sales;"
	},
	{
		"question": "You have a “Customers” table that contains customer information. Write a SQL query to find all customer_name whose names contain the substring ‘Smith’. Ensure that the results are sorted by “customer_name” in descending order. - change",
		"answer": "SELECT * FROM Customers WHERE customer_name LIKE '%Smith%' ORDER BY customer_name DESC;"
	},
	{
		"question": "Retrieve the employee_name from the Employees table along with the department_name from the Departments table. Use the “department_id” column to join the Employees and Departments tables. (Include the complete table name)",
		"answer": "SELECT Employees.employee_name, Departments.department_name FROM Employees JOIN Departments ON Employees.department_id = Departments.department_id;"
	},
	{
		"question": "List all customer_name from the Customers table and their order_id from the Orders table, including customers who have not placed any orders and orders that have no corresponding customers. Use the “customer_id” column to join the Customers and Orders tables. (Include the complete table name)",
		"answer": "SELECT Customers.customer_name, Orders.order_id FROM Customers FULL OUTER JOIN Orders ON Customers.customer_id = Orders.customer_id;"
	},
	{
		"question": "How do you retrieve a combined list of all 'employee_name' from the Employees table and 'customer_name' from the Customers table, assuming both columns have the same data type?",
		"answer": "SELECT employee_name FROM Employees UNION SELECT customer_name FROM Customers;"
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
		"SELECT Customers.customer_name, Orders.order_date FROM Customers JOIN Orders ON Customers.customer_id = Orders.customer_id;":
			return "Hint: Use 'JOIN' to combine rows from two tables based on a related column."
		"SELECT COUNT(sale_id) AS total_transactions, SUM(sale_amount) AS total_sales FROM Sales;":
			return "Hint: Use 'COUNT()' and 'SUM()' aggregation functions to get the total transactions and sales."
		"SELECT * FROM Customers WHERE customer_name LIKE '%Smith%' ORDER BY customer_name DESC;":
			return "Hint: Use 'LIKE' with wildcards '%' to find substrings and 'ORDER BY' to sort results."
		"SELECT Employees.employee_name, Departments.department_name FROM Employees JOIN Departments ON Employees.department_id = Departments.department_id;":
			return "Hint: Use 'JOIN' on the 'department_id' column to retrieve related employee and department data."
		"SELECT Customers.customer_name, Orders.order_id FROM Customers FULL OUTER JOIN Orders ON Customers.customer_id = Orders.customer_id;":
			return "Hint: Use 'FULL OUTER JOIN' to include all rows when there is a match in either table."
		"SELECT employee_name FROM Employees UNION SELECT customer_name FROM Customers;":
			return "Hint: Use 'UNION' to combine the results of two SELECT queries."
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
