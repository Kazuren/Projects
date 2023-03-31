extends Main

const MUSIC = preload("res://Assets/Music/city_reset_3.wav")
var DummyDaughter = preload("res://src/Game/DummyDaughter/DummyDaughter.tscn")
var DialogueCircle = preload("res://src/Game/DialogueCircle/DialogueCircle.tscn")
onready var daughter = $Daughter
onready var dialogue_area = $DialogueArea
onready var car = $Car


func _ready() -> void:
	Audio.play_music(MUSIC)
	dialogue_area.connect("dialogue_started", self, "_on_DialogueArea_dialogue_started")
	dialogue_area.connect("dialogue_finished", self, "_on_DialogueArea_dialogue_finished")
	daughter.connect("death", self, "_on_Daughter_death")


func _on_DialogueArea_dialogue_started() -> void:
	Audio.stop_music()


func _on_DialogueArea_dialogue_finished() -> void:
	daughter.player = Globals.player
	daughter.invincible = false


func _on_Daughter_death() -> void:
	var dummy = DummyDaughter.instance()
	dummy.global_position = daughter.global_position
	dummy.animation_speed_scale = 0.5
	add_child_below_node(car, dummy)
	dummy.connect("animation_finished", self, "_on_DummyDaughter_animation_finished")
	var dialogue = DialogueCircle.instance()
	dialogue.dialog_timeline = "DeadDaughterInteraction"
	dialogue.once = false
	dialogue.position.y += 70
	dummy.call_deferred("add_child", dialogue)
	yield(dialogue, "ready")
	dialogue.input_key.rect_position.y = -70


func _on_DummyDaughter_animation_finished() -> void:
	Events.emit_signal("game_paused")
	get_tree().paused = true
	var dialog = Dialogic.start("CityDaughterDeath")
	dialog.pause_mode = Node.PAUSE_MODE_PROCESS
	dialog.connect("timeline_end", self, "on_Dialog_timeline_end")
	add_child(dialog)


func on_Dialog_timeline_end(timeline_name) -> void:
	yield(get_tree(), "idle_frame")
	get_tree().paused = false
	Events.emit_signal("game_resumed")
