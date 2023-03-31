extends Node


var player
var game_started: bool = false

func unpause_game():
	get_tree().paused = false
	Events.emit_signal("game_resumed")
