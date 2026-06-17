extends Control

@onready var expression_label = $VBoxContainer/Expression
@onready var display = $VBoxContainer/Display

var current_number = "0"
var first_number = "0"
var operation = ""
var expression = ""
var waiting_for_second = false
var just_calculated = false

func _ready():
	for btn in $VBoxContainer/GridContainer.get_children():
		if btn is Button:
			btn.pressed.connect(_on_button_pressed.bind(btn.text))
	update_display()

func _on_button_pressed(btn_text):
	btn_text = btn_text.strip_edges()
	
	# Agar = ke baad number daba diya to naya calculation shuru
	if just_calculated and btn_text.is_valid_int():
		current_number = "0"
		expression = ""
		just_calculated = false
	
	match btn_text:
		"AC", "↻", "C":
			current_number = "0"
			first_number = "0"
			operation = ""
			expression = ""
			waiting_for_second = false
			just_calculated = false
		
		"⌫", "←", "Del":
			if current_number.length() > 1 and current_number != "Error":
				current_number = current_number.left(current_number.length() - 1)
			else:
				current_number = "0"
		
		"%":
			current_number = str(float(current_number) / 100)
		
		"/", "÷":
			set_operation("/")
		
		"x", "X", "×", "*":
			set_operation("x")
		
		"-":
			set_operation("-")
		
		"+":
			set_operation("+")
		
		"=":
			if operation != "":
				expression += current_number + "="
				calculate()
				operation = ""
				waiting_for_second = false
				just_calculated = true
		
		".":
			if not "." in current_number:
				current_number += "."
		
		"+/-", "±":
			current_number = str(float(current_number) * -1)
		
		_:
			# 0-9 number hai
			if current_number == "0" or current_number == "Error" or waiting_for_second:
				current_number = btn_text
				waiting_for_second = false
			else:
				current_number += btn_text
	
	update_display()

func set_operation(op):
	if operation != "" and waiting_for_second == false:
		calculate()
	
	first_number = current_number
	operation = op
	expression = first_number + op
	waiting_for_second = true
	current_number = "0"
	just_calculated = false

func calculate():
	if first_number == "" or current_number == "":
		return
	
	var num1 = float(first_number)
	var num2 = float(current_number)
	var result = 0.0
	
	match operation:
		"+":
			result = num1 + num2
		"-":
			result = num1 - num2
		"x":
			result = num1 * num2
		"/":
			if num2 == 0:
				current_number = "Error"
				expression = "Error"
				return
			result = num1 / num2
	
	# .0 hata do agar integer hai
	if result == floor(result):
		current_number = str(int(result))
	else:
		current_number = str(result)
	
	first_number = str(result)

func update_display():
	expression_label.text = expression
	display.text = current_number
