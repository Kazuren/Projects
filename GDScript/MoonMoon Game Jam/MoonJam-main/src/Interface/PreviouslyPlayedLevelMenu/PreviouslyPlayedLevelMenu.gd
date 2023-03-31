extends Control

signal continue_pressed
signal back_pressed

onready var continue_button = $Menu/MarginContainer/MarginContainer/ContinueButton
onready var back_button = $Menu/MarginContainer/MarginContainer/BackButton


onready var time_value = $Menu/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/TimeValue
onready var health_value = $Menu/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/HealthValue
onready var coins_value = $Menu/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer3/CoinsValue
onready var score_value = $Menu/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer4/ScoreValue
onready var level_name_label = $Menu/MarginContainer/VBoxContainer/LevelNameLabel


func _ready() -> void:
	continue_button.connect("pressed", self, "_on_ContinueButton_pressed")
	back_button.connect("pressed", self, "_on_BackButton_pressed")
	#if Input.get_connected_joypads().size() > 0:
	continue_button.grab_focus()
	
	continue_button.connect("mouse_entered", self, "_on_Button_mouse_entered", [continue_button])
	back_button.connect("mouse_entered", self, "_on_Button_mouse_entered", [back_button])
	#retry_button.toggle_mode = true
	#retry_button.pressed = true


func init(time: float, health: int, max_health: int, coins: int, max_coins: int, score: int, level_name: String) -> void:
	time_value.text = str(stepify(time, 0.01)) + str("s")
	health_value.text = str(health) + "/" + str(max_health)
	coins_value.text = str(coins) + "/" + str(max_coins)
	score_value.text = str(score)
	level_name_label.text = level_name


func _on_Button_mouse_entered(button) -> void:
	#if Input.get_connected_joypads().size() > 0:
	button.grab_focus()


func _on_ContinueButton_pressed() -> void:
	emit_signal("continue_pressed")


func _on_BackButton_pressed() -> void:
	emit_signal("back_pressed")
