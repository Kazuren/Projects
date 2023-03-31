extends Node2D

var activation_time: float = 0.5
var duration: float = 1.0


const sfx = preload("res://Assets/Audio/SFX/moon_beam.wav")

func _ready() -> void:
	var timer = get_tree().create_timer(activation_time, false)
	timer.connect("timeout", self, "_on_activation_timeout", [], CONNECT_ONESHOT)




func aim(pos: Vector2) -> void:
	look_at(pos)


func activate() -> void:
	pass


func _on_activation_timeout() -> void:
	var timer = get_tree().create_timer(duration, false)
	timer.connect("timeout", self, "_on_duration_ended")
	modulate = Color.white
	Audio.play_effect(sfx, 1.0)
	$Hitbox.set_deferred("monitoring", true)
	$Hitbox.set_deferred("monitorable", true)


func _on_duration_ended() -> void:
	queue_free()
