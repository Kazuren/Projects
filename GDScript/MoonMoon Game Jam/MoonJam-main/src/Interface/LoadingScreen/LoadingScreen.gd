extends Control

signal loading_finished

onready var animation_player = $AnimationPlayer
onready var spin_timer = $SpinTimer
onready var label = $Label

var can_advance: bool = false


func _ready() -> void:
	animation_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	animation_player.play("Spin")
	spin_timer.start()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if !spin_timer.is_stopped() and anim_name == "Spin":
		animation_player.play("Spin")
	elif anim_name == "Spin":
		animation_player.play("FinishSpin")
	elif anim_name == "FinishSpin":
		yield(get_tree().create_timer(0.75), "timeout")
		animation_player.play("SpinBack")
	elif anim_name == "SpinBack":
		label.text = "Press any key to continue"
		can_advance = true
		animation_player.play("FlashLabel")
	elif anim_name == "CUMDETECTED":
		emit_signal("loading_finished")
		queue_free()


func _input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton) and can_advance:
		animation_player.play("CUMDETECTED")
		can_advance = false
		label.text = ""
