extends Area2D

signal dialogue_started
signal interacted

export var dialog_timeline: String = ""
export var once: bool = true

var active: bool = false
var talked: bool = false

onready var input_key = $InputKey



func _ready():
	connect("body_entered", self, "_on_DialogCircle_body_entered")
	connect("body_exited", self, "_on_DialogCircle_body_exited")


func _process(delta: float) -> void:
	input_key.visible = active and !talked


func _unhandled_input(event: InputEvent) -> void:
	if get_node_or_null("DialogNode") == null:
		if event.is_action_pressed("interact") and active and !talked and visible:
			if once:
				talked = true
			Events.emit_signal("game_paused")
			emit_signal("dialogue_started")
			input_key.visible = false
			get_tree().paused = true
			
			var dialog = Dialogic.start(dialog_timeline)
			dialog.pause_mode = Node.PAUSE_MODE_PROCESS
			dialog.connect("timeline_end", self, "on_Dialog_timeline_end")
			add_child(dialog)


func on_Dialog_timeline_end(timeline_name):
	yield(get_tree(), "idle_frame")
	get_tree().paused = false
	emit_signal("interacted")
	Events.emit_signal("game_resumed")


func _on_DialogCircle_body_entered(body) -> void:
	if body is Player:
		active = true


func _on_DialogCircle_body_exited(body) -> void:
	if body is Player:
		active = false
