extends Control

var text_time_to_read: float = 5.0
var time_required_for_max_text: float = 1.0

var time: float = 0


var text_index: int = 0
var when_to_swap_pictures: int = 0


var text = [
	"Borpa: This is it!? This is the Giga Cum Chalice of Hell 2!? This sad dingy cup!?",
	"Eddie: I’m afraid so young Borpa.",
	"Narrator: Borpa takes a sip from the chalice.",
	"Borpa: This isn’t even cum! This is just spoiled milk!",
	"I can’t believe this! What a waste of a journey!",
	"What a travesty of a reward!"
]


var ended: bool = false

onready var texture_rect = $MarginContainer/TextureRect
onready var label = $BlackBar2/MarginContainer/TextLabel


func _ready() -> void:
	Audio.stop_music()
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
	Globals.progress = 1 if 1 > Globals.progress else Globals.progress
	Globals.save_data()
	queue_free()
	get_tree().change_scene("res://src/Scenes/Level 5/Credits/Credits.tscn")




