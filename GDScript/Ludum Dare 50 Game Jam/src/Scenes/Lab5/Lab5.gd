extends Main

const MUSIC = preload("res://Assets/Music/lab_reset3.wav")


func _ready() -> void:
	Audio.play_music(MUSIC)
#	yield(get_tree().create_timer(0.1), "timeout")
#	Events.emit_signal("game_paused")
#	get_tree().paused = true
#	var dialog = Dialogic.start("LabLastOne")
#	dialog.pause_mode = Node.PAUSE_MODE_PROCESS
#	dialog.connect("timeline_end", self, "on_Dialog_timeline_end")
#	add_child(dialog)

#
#func on_Dialog_timeline_end(timeline_name):
#	print("test")
#	yield(get_tree(), "idle_frame")
#	get_tree().paused = false
#	Events.emit_signal("game_resumed")

func _exit_tree() -> void:
	get_tree().paused = false
