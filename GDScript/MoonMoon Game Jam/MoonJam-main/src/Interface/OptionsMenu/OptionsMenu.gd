extends Control

const SettingsMenu = preload("res://src/Interface/SettingsMenu/SettingsMenu.tscn")

var settings_open: bool = false


onready var resume_button = $Menu/MarginContainer/VBoxContainer/ResumeButton
onready var retry_button = $Menu/MarginContainer/VBoxContainer/RetryButton
onready var settings_button = $Menu/MarginContainer/VBoxContainer/SettingsButton
onready var level_select_button = $Menu/MarginContainer/VBoxContainer/LevelSelectButton


func _ready() -> void:
	#if Input.get_connected_joypads().size() > 0:
	resume_button.grab_focus()
		
	resume_button.connect("mouse_entered", self, "_on_Button_mouse_entered", [resume_button])
	retry_button.connect("mouse_entered", self, "_on_Button_mouse_entered", [retry_button])
	level_select_button.connect("mouse_entered", self, "_on_Button_mouse_entered", [level_select_button])
	settings_button.connect("mouse_entered", self, "_on_Button_mouse_entered", [settings_button])
	
	resume_button.connect("pressed", self, "_on_ResumeButton_pressed")
	retry_button.connect("pressed", self, "_on_RetryButton_pressed")
	level_select_button.connect("pressed", self, "_on_LevelSelectButton_pressed")
	settings_button.connect("pressed", self, "_on_SettingsButton_pressed")


func _on_Button_mouse_entered(button) -> void:
	#if Input.get_connected_joypads().size() > 0:
	button.grab_focus()


func _on_ResumeButton_pressed() -> void:
	queue_free()


func _on_RetryButton_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	queue_free()


func _on_LevelSelectButton_pressed() -> void:
	get_tree().paused = false
	queue_free()
	get_tree().change_scene("res://src/Interface/LevelSelectMenu/LevelSelectMenu.tscn")


func _on_SettingsButton_pressed() -> void:
	var settings_menu = SettingsMenu.instance()
	settings_open = true
	Interface.add_child(settings_menu)
	settings_menu.connect("tree_exiting", self, "_on_SettingsMenu_tree_exiting")
	settings_button.release_focus()


func _input(event: InputEvent) -> void:
	if settings_open:
		return
	
	if event.is_action_pressed("pause"):
		get_tree().set_input_as_handled()
		#get_tree().paused = false
		#Events.emit_signal("game_resumed")
		queue_free()


func _on_SettingsMenu_tree_exiting() -> void:
	settings_open = false
	#if Input.get_connected_joypads().size() > 0:
	settings_button.grab_focus()
