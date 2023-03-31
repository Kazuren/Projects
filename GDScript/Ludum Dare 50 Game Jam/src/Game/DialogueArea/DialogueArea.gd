extends Area2D

signal dialogue_started
signal dialogue_finished

export var dialog_timeline: String = ""
var talked: bool = false


func _ready():
	connect("body_entered", self, "_on_DialogueArea_body_entered")


func on_Dialog_timeline_end(timeline_name):
	yield(get_tree(), "idle_frame")
	get_tree().paused = false
	Events.emit_signal("game_resumed")
	emit_signal("dialogue_finished")


func _on_DialogueArea_body_entered(body) -> void:
	if body is Player and !talked:
		talked = true
		Events.emit_signal("game_paused")
		emit_signal("dialogue_started")
		get_tree().paused = true
		var dialog = Dialogic.start(dialog_timeline)
		dialog.pause_mode = Node.PAUSE_MODE_PROCESS
		dialog.connect("timeline_end", self, "on_Dialog_timeline_end")
		add_child(dialog)

