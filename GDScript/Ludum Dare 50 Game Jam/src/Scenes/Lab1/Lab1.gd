extends Main

const MUSIC = preload("res://Assets/Music/lab.wav")


func _ready() -> void:
	PlayerInfo.can_input = false
	ScreenFader.fade_out("1.0")
	yield(ScreenFader, "animation_finished")
	PlayerInfo.can_input = true
	get_tree().paused = true
	Audio.play_music(MUSIC)
	Events.emit_signal("game_paused")
	
	var dialog = Dialogic.start("Lab1")
	dialog.pause_mode = Node.PAUSE_MODE_PROCESS
	dialog.connect("timeline_end", self, "on_Dialog_timeline_end")
	add_child(dialog)


func on_Dialog_timeline_end(timeline_name):
	yield(get_tree(), "idle_frame")
	get_tree().paused = false
	Events.emit_signal("game_resumed")

