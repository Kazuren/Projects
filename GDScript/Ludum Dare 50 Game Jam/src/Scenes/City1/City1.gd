extends Main


const MUSIC = preload("res://Assets/Music/city.wav")


func _ready() -> void:
	Audio.play_music(MUSIC)
