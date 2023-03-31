extends Control

const music = preload("res://Assets/Audio/Music/factory/FactoryThemeFinal.wav")

var text_time_to_read: float = 5.0
var time_required_for_max_text: float = 1.0

var time: float = 0


var text_index: int = 0
var when_to_swap_pictures: int = 0


var text = [
	"Borpa: At last! I’ve reached the control room!.",
	"Eddie: Good job young Borpa.",
	"Eddie: Now you just need to go to the computer, open the navigation software, and set your location to 69, 73, 420.",
	"Eddie: That’ll land you very close to the location of the Giga Cum Chalice of Hell 2.",
	"Eddie: The journey is not yet over.",
	"Eddie: Reaching the chalice itself from there will be a challenge in its own right.",
	"Eddie: Good luck young Borpa.",
]


var ended: bool = false

onready var texture_rect = $MarginContainer/TextureRect
onready var label = $BlackBar2/MarginContainer/TextLabel


func _ready() -> void:
	Audio.play_music(music)
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
			if text_index == text.size():
				end()
				return
			label.text = text[text_index]
			label.percent_visible = inverse_lerp(0, time_required_for_max_text, time)


func end() -> void:
	#Globals.progress = 1 if 1 > Globals.progress else Globals.progress
	#Globals.save_data()
	queue_free()
	get_tree().change_scene("res://src/Interface/LevelSelectMenu/LevelSelectMenu.tscn")






