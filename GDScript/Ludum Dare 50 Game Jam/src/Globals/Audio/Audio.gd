extends Node

onready var music_player = $Music
var max_pitch = 1.1
var min_pitch = 0.9

func play_music(wav: Resource):
	music_player.stream = wav
	music_player.play()


func stop_music():
	music_player.stop()


func play_effect(wav: Resource, pitch_scale: float = 1.0):
	 # If there are 32 or more simultaneous sounds playing we should skip
	if get_child_count() >= 32:
		return
	var audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.bus = "Effects"
	audio_player.stream = wav
	var pitch = rand_range(min_pitch, max_pitch)
	audio_player.pitch_scale = pitch
	audio_player.play()
	yield(audio_player, "finished")
	audio_player.queue_free()

