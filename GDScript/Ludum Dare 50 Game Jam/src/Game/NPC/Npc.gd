extends Node

var talked: bool = false

onready var dialogue_begin_node = $DialogueBegin
onready var label = $Label
onready var animation_player = $AnimationPlayer


func _ready():
	label.percent_visible = 0
	dialogue_begin_node.connect("body_entered", self, "_on_DialogCircle_body_entered")


func _on_DialogCircle_body_entered(body: Node) -> void:
	if body is Player and !talked:
		talked = true
		animation_player.play("BeginDialogue")
