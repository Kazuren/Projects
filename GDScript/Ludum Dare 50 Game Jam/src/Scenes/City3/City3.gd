extends Main


const MUSIC = preload("res://Assets/Music/city_reset_2.wav")

onready var enemy2 = $Enemy2
onready var enemy3 = $Enemy3


func _ready() -> void:
	Audio.play_music(MUSIC)
	enemy2.connect("hit", self, "_on_Enemy2_hit")


func _on_Enemy2_hit() -> void:
	enemy2.player = Globals.player
	enemy3.player = Globals.player
