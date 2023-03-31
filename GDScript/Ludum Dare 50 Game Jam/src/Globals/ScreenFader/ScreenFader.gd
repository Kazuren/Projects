extends Node

signal animation_finished

var base_speed: float = 1

onready var animation_player = $AnimationPlayer
onready var label = $Label

func _ready() -> void:
	animation_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")


func fade_in(seconds: String = "1", text: String = "") -> void:
	var speed = base_speed * (2 * seconds.to_float())
	animation_player.playback_speed = 1 / speed
	animation_player.play("FadeIn")
	label.text = text


func fade_out(seconds: String = "1") -> void:
	label.text = ""
	var speed = base_speed * (2 * seconds.to_float())
	animation_player.playback_speed = 1 / speed
	animation_player.play("FadeOut")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	emit_signal("animation_finished")
	animation_player.playback_speed = 1.0
