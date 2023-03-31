extends Sprite

signal animation_finished

export var animation_speed_scale = 1

onready var animation_player = $AnimationPlayer


func _ready() -> void:
	animation_player.playback_speed = animation_speed_scale
	animation_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	animation_player.play("Death")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	emit_signal("animation_finished")
