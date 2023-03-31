extends Node

onready var music_player = $Music
var max_pitch: float = 1.1
var min_pitch: float = 0.9
var active_sfx: int = 0


func play_music(wav: Resource, position: float = 0.0):
	music_player.stream = wav
	music_player.play(position)
	return music_player


func get_current_music() -> AudioStream:
	if music_player.playing:
		return music_player.stream
	else:
		return null


func stop_music() -> float:
	var position = music_player.get_playback_position()
	music_player.stop()
	return position


func play_effect(wav: Resource, pitch_scale: float = 1.0, audio_position = null):
	 # If there are 64 or more simultaneous sounds playing we should skip
	if active_sfx >= 64:
		return null
	
	var audio_player
	var node
	if audio_position:
		audio_player = AudioStreamPlayer2D.new()
		node = Node2D.new()
		add_child(node)
		node.global_position = audio_position
		node.add_child(audio_player)
	else:
		audio_player = AudioStreamPlayer.new()
		add_child(audio_player)
	audio_player.bus = "Effects"
	audio_player.stream = wav
	var pitch = rand_range(min_pitch, max_pitch)
	audio_player.pitch_scale = pitch
	audio_player.play()
	active_sfx += 1
	audio_player.connect("finished", self, "_on_Audio_player_finished", [audio_player, node])
	audio_player.connect("tree_exiting", self, "_on_Audio_player_tree_exiting")
	return audio_player


func _on_Audio_player_finished(audio_player, node) -> void:
	audio_player.queue_free()
	if node:
		node.queue_free()


func _on_Audio_player_tree_exiting() -> void:
	active_sfx -= 1
