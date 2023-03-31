extends Main


const MUSIC = preload("res://Assets/Music/home_and_countryside_reset_2.wav")

onready var dead_wife_dialogue = $DeadWifeDialogue
onready var dead_wife_interaction = $DeadWifeInteraction
onready var farmer_interaction = $FarmerInteraction
onready var farmer = $Farmer

var dead_wife_counter = 0


func _ready() -> void:
	Audio.stop_music()
	PlayerInfo.has_gun = true
	dead_wife_dialogue.connect("dialogue_finished", self, "_on_DeadWifeDialogue_finihed")
	dead_wife_interaction.connect("interacted", self, "_on_DeadWifeInteraction_interacted")
	farmer_interaction.connect("dialogue_started", self, "_on_FarmerInteraction_dialogue_started")
	farmer_interaction.connect("interacted", self, "_on_FarmerInteraction_interacted")


func _on_DeadWifeDialogue_finihed() -> void:
	Audio.play_music(MUSIC)


func _on_DeadWifeInteraction_interacted() -> void:
	dead_wife_counter += 1
	if dead_wife_counter > 4:
		dead_wife_interaction.dialog_timeline = "DeadWifeInteractionAfter5"
	elif dead_wife_counter > 2:
		dead_wife_interaction.dialog_timeline = "DeadWifeInteractionAfter3"


func _on_FarmerInteraction_dialogue_started() -> void:
	farmer.label.percent_visible = 0
	farmer.animation_player.stop()


func _on_FarmerInteraction_interacted() -> void:
	farmer.animation_player.play("BeginDialogue")
