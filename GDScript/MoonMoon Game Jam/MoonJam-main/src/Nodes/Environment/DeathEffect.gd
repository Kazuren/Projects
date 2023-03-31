extends Particles2D


func initialize(sprite: Texture, s: Vector2 = Vector2(1, 1)) -> void:
	var w = sprite.get_width() * s.x
	var h = sprite.get_height() * s.y
	
	process_material.set_shader_param("emission_box_extents",
		Vector3(w / 2.0, h / 2.0, 1)
	)
	process_material.set_shader_param("sprite", sprite)
	
	amount = max(1, (w * h) / 2)
	emitting = true


func _process(delta: float) -> void:
	if !emitting:
		queue_free()
