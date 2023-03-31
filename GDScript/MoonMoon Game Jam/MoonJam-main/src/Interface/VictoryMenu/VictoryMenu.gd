extends Control

signal continue_pressed

var sfx = preload("res://Assets/Audio/SFX/levelwin.wav")

onready var continue_button = $Menu/MarginContainer/MarginContainer/ContinueButton
onready var retry_button = $Menu/MarginContainer/MarginContainer/RetryButton


onready var time_value = $Menu/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/TimeValue
onready var health_value = $Menu/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/HealthValue
onready var coins_value = $Menu/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer3/CoinsValue
onready var score_value = $Menu/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer4/ScoreValue


func _ready() -> void:
	Audio.play_music(sfx)
	continue_button.connect("pressed", self, "_on_ContinueButton_pressed")
	retry_button.connect("pressed", self, "_on_RetryButton_pressed")
	#if Input.get_connected_joypads().size() > 0:
	continue_button.grab_focus()
	continue_button.connect("mouse_entered", self, "_on_Button_mouse_entered", [continue_button])
	retry_button.connect("mouse_entered", self, "_on_Button_mouse_entered", [retry_button])
	#retry_button.toggle_mode = true
	#retry_button.pressed = true


func init(time: float, health: int, max_health: int, coins: int, max_coins: int, score: int) -> void:
	time_value.text = str(stepify(time, 0.01)) + str("s")
	health_value.text = str(health) + "/" + str(max_health)
	coins_value.text = str(coins) + "/" + str(max_coins)
	score_value.text = str(score)



func _on_Button_mouse_entered(button) -> void:
	#if Input.get_connected_joypads().size() > 0:
	button.grab_focus()


func _on_ContinueButton_pressed() -> void:
	emit_signal("continue_pressed")
	#get_tree().paused = false
	#queue_free()
	#get_tree().change_scene("res://src/Interface/LevelSelectMenu/LevelSelectMenu.tscn")


func _on_RetryButton_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	queue_free()
