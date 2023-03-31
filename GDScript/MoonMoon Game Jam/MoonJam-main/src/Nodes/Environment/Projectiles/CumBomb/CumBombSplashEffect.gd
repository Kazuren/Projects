extends Particles2D



func _process(delta: float) -> void:
	if !emitting:
		queue_free()
