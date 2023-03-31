extends Control


const LoadingScreen = preload("res://src/Interface/LoadingScreen/LoadingScreen.tscn")
const OptionsButton = preload("res://src/Interface/OptionsButton.tscn")
const PreviouslyPlayedLevelMenu = preload("res://src/Interface/PreviouslyPlayedLevelMenu/PreviouslyPlayedLevelMenu.tscn")

const MUSIC = preload("res://Assets/Audio/Music/main_menu/white_noise.wav")

var levels = [
	{
		"name": "Intro",
		"scene": "res://src/Scenes/_Intro/Intro.tscn",
		"progress": 0,
		"id": 0
	},
	{
		"name": "Corpaville",
		"scene": "res://src/Scenes/House/House.tscn",
		"progress": 1,
		"id": 1
	},
	{
		"name": "GIGA Factory Outer",
		"scene": "res://src/Scenes/Level 1/Level 1.tscn",
		"progress": 2,
		"id": 2
	},
	{
		"name": "GIGA Factory Inner",
		"scene": "res://src/Scenes/Level 2/Level 2.tscn",
		"progress": 3,
		"id": 3
	},
	{
		"name": "Galaxy",
		"scene": "res://src/Scenes/Level 3/Level 3.tscn",
		"progress": 4,
		"id": 4,
	},
	{
		"name": "GIGA MOON",
		"scene": "res://src/Scenes/Level 5/Boss 1.tscn",
		"progress": 5,
		"id": 5
	}
]

onready var button_container = $CenterContainer/VBoxContainer/ScrollContainer/ButtonContainer
onready var back_button = $CenterContainer/VBoxContainer/ScrollContainer/ButtonContainer/BackButton
onready var scroll_container = $CenterContainer/VBoxContainer/ScrollContainer


func _ready() -> void:
	Globals.from_retry = false
	
	#scroll_container.get_v_scrollbar().rect_scale.x = 0
	var game_interface = Interface.get_node("GameInterface")
	if game_interface.visible:
		game_interface.visible = false
	
	# if not playing main menu music, play main menu music
	if Audio.get_current_music() != MUSIC:
		Audio.play_music(MUSIC)
	
	for level in levels:
		var button = OptionsButton.instance()
		button_container.add_child(button)
		button.text = level.name
		button.disabled = Globals.progress < level.progress
		button.connect("pressed", self, "_on_LevelButton_pressed", [button, level])
		button.connect("mouse_entered", self, "_on_Button_mouse_entered", [button])
		button.connect("focus_entered", self, "_on_Button_focus_entered", [button])
	
	#back_button.raise()
	
	var buttons = button_container.get_children()
	for i in buttons.size():
		var button = buttons[i]
		var previous_button_index = posmod(i - 1, buttons.size())
		var previous_button = buttons[previous_button_index]
		
		var next_button_index = posmod(i + 1, buttons.size())
		var next_button = buttons[next_button_index]
		
		while next_button.disabled:
			next_button_index = posmod(next_button_index + 1, buttons.size())
			next_button = buttons[next_button_index]
		
		while previous_button.disabled:
			previous_button_index = posmod(previous_button_index - 1, buttons.size())
			previous_button = buttons[previous_button_index]
		
		button.focus_neighbour_bottom = buttons[next_button_index].get_path()
		button.focus_neighbour_top = buttons[previous_button_index].get_path()
	
	buttons[0].grab_focus()
	
	back_button.connect("pressed", self, "_on_BackButton_pressed")
	back_button.connect("mouse_entered", self, "_on_Button_mouse_entered", [back_button])


func _on_Button_mouse_entered(button) -> void:
	pass
	#button.grab_focus()


func _on_Button_focus_entered(button) -> void:
	scroll_container.scroll_vertical = button.rect_position.y


func _on_LevelButton_pressed(button, level) -> void:
	if Globals.level_stats.has(level.id):
		var stats = Globals.level_stats[level.id]
		var menu = PreviouslyPlayedLevelMenu.instance()
		Interface.add_child(menu)
		menu.init(
			stats.time, stats.hp, stats.max_hp,
			stats.coins, stats.max_coins,
			stats.score, level.name
		)
		menu.connect("continue_pressed", self, "load_scene", [button, level.scene])
		menu.connect("continue_pressed", menu, "queue_free")
		menu.connect("back_pressed", self, "_on_PreviouslyPlayedMenu_back_pressed", [menu, button])
	else:
		load_scene(button, level.scene)


func _on_PreviouslyPlayedMenu_back_pressed(menu, button) -> void:
	menu.queue_free()
	button.grab_focus()


func load_scene(button, scene) -> void:
	button.release_focus()
	var loading_screen = LoadingScreen.instance()
	Audio.stop_music()
	loading_screen.connect("loading_finished", self, "_on_loading_finished", [scene])
	Interface.add_child(loading_screen)


func _on_BackButton_pressed() -> void:
	var MainMenu = load("res://src/Interface/MainMenu/MainMenu.tscn")
	var main_menu = MainMenu.instance()
	Interface.add_child(main_menu)
	queue_free()


func _on_loading_finished(scene) -> void:
	queue_free()
	get_tree().change_scene(scene)
