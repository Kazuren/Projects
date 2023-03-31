extends Main


onready var farmer_interaction = $FarmerInteraction
onready var farmer = $Farmer


func _ready() -> void:
	farmer_interaction.connect("dialogue_started", self, "_on_FarmerInteraction_dialogue_started")
	farmer_interaction.connect("interacted", self, "_on_FarmerInteraction_interacted")


func _on_FarmerInteraction_dialogue_started() -> void:
	farmer.label.percent_visible = 0
	farmer.animation_player.stop()


func _on_FarmerInteraction_interacted() -> void:
	farmer.animation_player.play("BeginDialogue")
