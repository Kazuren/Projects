extends Main


const MUSIC = preload("res://Assets/Music/lab.wav")


func _ready() -> void:
	Audio.play_music(MUSIC)
