extends Enemy



func _ready() -> void:
	pass # Replace with function body.


func set_parriable(value: bool) -> void:
	parriable = value
	# parriable bit
	hurtbox.set_collision_layer_bit(9, true)


func _process(delta: float) -> void:
	if parriable:
		sprite.material.set_shader_param("active", true)
