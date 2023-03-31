extends Control

const SettingsMenu = preload("res://src/Interface/SettingsMenu/SettingsMenu.tscn")
const MUSIC = preload("res://Assets/Audio/Music/main_menu/white_noise.wav")
const LoadingScreen = preload("res://src/Interface/LoadingScreen/LoadingScreen.tscn")
const LevelSelectMenu = preload("res://src/Interface/LevelSelectMenu/LevelSelectMenu.tscn")
#const ChooseNameMenu = preload("res://src/Interface/Menus/ChooseNameMenu/ChooseNameMenu.tscn")

onready var play = $CenterContainer/VBoxContainer/VBoxContainer/PlayButton
onready var settings = $CenterContainer/VBoxContainer/VBoxContainer/SettingsButton
onready var exit = $CenterContainer/VBoxContainer/VBoxContainer/ExitButton


func _ready() -> void:
	# if not playing main menu music, play main menu music
	if Audio.get_current_music() != MUSIC:
		Audio.play_music(MUSIC)
	#if Input.get_connected_joypads().size() > 0:
	play.grab_focus()
	
	play.connect("mouse_entered", self, "_on_Button_mouse_entered", [play])
	settings.connect("pressed", self, "_on_SettingsButton_pressed")
	exit.connect("pressed", self, "_on_ExitButton_pressed")
	
	play.connect("pressed", self, "_on_PlayButton_pressed")
	settings.connect("mouse_entered", self, "_on_Button_mouse_entered", [settings])
	exit.connect("mouse_entered", self, "_on_Button_mouse_entered", [exit])


func _on_Button_mouse_entered(button) -> void:
	#if Input.get_connected_joypads().size() > 0:
	button.grab_focus()



func _on_PlayButton_pressed() -> void:
	play.release_focus()
	var level_select_menu = LevelSelectMenu.instance()
	
	#var loading_screen = LoadingScreen.instance()
	#Audio.stop_music()
	#loading_screen.connect("loading_finished", self, "_on_loading_finished")
	Interface.add_child(level_select_menu)
	queue_free()
	#level_select_menu.connect("tree_exiting", self, "_on_LevelSelectMenu_tree_exiting")
	#level_select_menu.connect("level_loaded", self, "_on_LevelSelectMenu_level_loaded")
	
	# Transitioner.play_animation("Borpa loading")
	#ScreenFader.fade_in("1.0")
	#yield(Transitioner, "animation_finished")
	#get_tree().change_scene("res://src/Interface/Menus/ChooseNameMenu/ChooseNameMenu.tscn")


#func _on_loading_finished() -> void:
#	queue_free()
#	get_tree().change_scene("res://src/Scenes/Level 1/Level 1.tscn")


#func _on_LevelSelectMenu_tree_exiting() -> void:
#	play.grab_focus()
#
#
#func _on_LevelSelectMenu_level_loaded() -> void:
#	queue_free()


func _on_SettingsButton_pressed() -> void:
	var settings_menu = SettingsMenu.instance()
	Interface.add_child(settings_menu)
	settings_menu.connect("tree_exiting", self, "_on_SettingsMenu_tree_exiting")
	settings.release_focus()


func _on_ExitButton_pressed() -> void:
	get_tree().quit()


func _on_SettingsMenu_tree_exiting() -> void:
	#if Input.get_connected_joypads().size() > 0:
	settings.grab_focus()
