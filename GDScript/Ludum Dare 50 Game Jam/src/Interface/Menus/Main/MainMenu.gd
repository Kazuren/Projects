extends Control

const SettingsMenu = preload("res://src/Interface/Menus/Settings/Settings.tscn")
const MUSIC = preload("res://Assets/Music/title_screen.wav")
const ChooseNameMenu = preload("res://src/Interface/Menus/ChooseNameMenu/ChooseNameMenu.tscn")

onready var play = $CenterContainer/VBoxContainer2/VBoxContainer/PlayButton
onready var settings = $CenterContainer/VBoxContainer2/VBoxContainer/SettingsButton
onready var exit = $CenterContainer/VBoxContainer2/VBoxContainer/Exit


func _ready() -> void:
	Audio.play_music(MUSIC)
	play.connect("pressed", self, "_on_PlayButton_pressed")
	settings.connect("pressed", self, "_on_SettingsButton_pressed")
	exit.connect("pressed", self, "_on_ExitButton_pressed")
	if OS.has_feature('JavaScript'):
		exit.visible = false


func _on_PlayButton_pressed() -> void:
	ScreenFader.fade_in("1.0")
	yield(ScreenFader, "animation_finished")
	get_tree().change_scene("res://src/Interface/Menus/ChooseNameMenu/ChooseNameMenu.tscn")


func _on_SettingsButton_pressed() -> void:
	var settings_menu = SettingsMenu.instance()
	add_child(settings_menu)


func _on_ExitButton_pressed() -> void:
	get_tree().quit()
