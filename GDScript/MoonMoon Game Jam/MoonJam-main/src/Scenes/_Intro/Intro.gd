extends Control

var text_time_to_read: float = 5.0
var time_required_for_max_text: float = 1.0

var time: float = 0


var text_index: int = 0
var when_to_swap_pictures: int = 3


var text = [
	"Borpa stands victorious. The Devil hath fallen at last.",
	"The Giga Cum Chalice of Hell is finally Borpa’s to claim as the real rightful owner.",
	"Borpa steps forth and hoists the Giga Cum Chalice of Hell up.",
	"There, before his own eyes, was the legendary chalice, majestic and magnificent.",
	"Borpa: At long last! The Giga Cum Chalice of Hell is mine! Now I will become more powerful than ever before!",
	"Borpa takes a large gulp from the chalice. He can already feel the Giga Cum of Hell reinvigorating and empowering his body.",
	"Surely this would be his swan song, the pinnacle of all his adventures…"
]


const music = preload("res://Assets/Audio/Music/devil_intro_35sec.wav")
const swap_texture = preload("res://src/Scenes/_Intro/fancycup1.png")

var ended: bool = false

onready var texture_rect = $MarginContainer/TextureRect
onready var label = $BlackBar2/MarginContainer/TextLabel


func _ready() -> void:
	Audio.play_music(music)
	# play music here
	label.text = text[text_index]
	label.percent_visible = 0
	var game_interface = Interface.get_node("GameInterface")
	if game_interface.visible:
		game_interface.visible = false


func _process(delta: float) -> void:
	if !ended:
		time += delta
		label.percent_visible = inverse_lerp(0, time_required_for_max_text, time)
		
		if time > text_time_to_read:
			time = 0
			text_index += 1
			if text_index == when_to_swap_pictures:
				texture_rect.texture = swap_texture
				texture_rect.modulate = Color(1.25, 1.25, 1.25)
			if text_index == text.size():
				end()
				return
			label.text = text[text_index]
			label.percent_visible = inverse_lerp(0, time_required_for_max_text, time)


func end() -> void:
	Globals.progress = 1 if 1 > Globals.progress else Globals.progress
	Globals.save_data()
	queue_free()
	get_tree().change_scene("res://src/Interface/LevelSelectMenu/LevelSelectMenu.tscn")




