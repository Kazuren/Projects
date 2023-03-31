extends Control


onready var exit_button = $CenterContainer/VBoxContainer/ExitButton


func _ready() -> void:
	if OS.has_feature('JavaScript'):
		exit_button.visible = false
	exit_button.connect("pressed", self, "_on_ExitButton_pressed")


func _on_ExitButton_pressed() -> void:
	get_tree().quit()
