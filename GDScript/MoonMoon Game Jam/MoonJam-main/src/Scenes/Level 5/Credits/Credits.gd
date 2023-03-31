extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
const music = preload("res://Assets/Audio/Music/town.wav")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Audio.play_music(music)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
