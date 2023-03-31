extends Main


const MUSIC = preload("res://Assets/Music/lab_reset2.wav")


func _ready() -> void:
	Audio.play_music(MUSIC)
