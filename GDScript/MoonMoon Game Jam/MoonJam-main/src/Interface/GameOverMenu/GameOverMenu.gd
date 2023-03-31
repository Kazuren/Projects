extends Control

const sfx = preload("res://Assets/Audio/SFX/deathapplause.wav")


signal retry_pressed

onready var retry_button = $Menu/MarginContainer/RetryButton
onready var boss_percent_label = $Menu/MarginContainer/VBoxContainer/BossPercentLabel

func _ready() -> void:
	Audio.play_music(sfx)
	$AnimationPlayer.play("dedlole")
	yield($AnimationPlayer, "animation_finished")
	retry_button.connect("pressed", self, "_on_RetryButton_pressed")
	retry_button.visible = true
	#if Input.get_connected_joypads().size() > 0:
	retry_button.grab_focus()
	retry_button.connect("mouse_entered", self, "_on_Button_mouse_entered", [retry_button])
	#retry_button.toggle_mode = true
	#retry_button.pressed = true


func init(percent) -> void:
	boss_percent_label.visible = true
	if percent <= 1:
		percent = 0.00001
	boss_percent_label.text = "Boss health: " + str(percent) + "% left"


func _on_Button_mouse_entered(button) -> void:
	#if Input.get_connected_joypads().size() > 0:
	button.grab_focus()


func _on_RetryButton_pressed() -> void:
	emit_signal("retry_pressed")
	get_tree().paused = false
	get_tree().reload_current_scene()
	queue_free()
