extends PlayerState


func enter(data: Dictionary = {}) -> void:
	player.animation_node.travel("Idle")
	player.velocity = Vector2.ZERO


func physics_update(delta: float) -> void:
	if !player.jump_buffer.is_stopped():
		state_machine.change("Air", {"jump": true})
		return
	if not player.is_on_floor():
		state_machine.change("Air")
		return
	
	var x_input: float = player.get_xinput()
	
	player.velocity.y += player.gravity * delta
	player.velocity = player.move_and_slide(player.velocity, Vector2.UP)
	
	if Input.is_action_pressed("shoot") and PlayerInfo.has_gun:
		state_machine.change("Shoot")
	elif Input.is_action_just_pressed("jump"):
		state_machine.change("Air", {"jump": true})
	elif !is_equal_approx(x_input, 0.0):
		state_machine.change("Walk")
