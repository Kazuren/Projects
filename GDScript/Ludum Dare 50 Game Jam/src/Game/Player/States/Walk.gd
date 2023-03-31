extends PlayerState


func enter(data: Dictionary = {}) -> void:
	player.animation_node.travel("Walk")


func physics_update(delta: float) -> void:
	if !player.jump_buffer.is_stopped():
		state_machine.change("Air", {"jump": true})
		return
	
	if not player.is_on_floor() and player.coyote_timer.is_stopped():
		state_machine.change("Air")
		return
	
	var x_input: float = player.get_xinput()
	
	if !is_equal_approx(x_input, 0.0):
		player.looking_direction = x_input
	
	player.velocity.x = player.speed * x_input
	if player.coyote_timer.is_stopped():
		player.velocity.y += player.gravity * delta
	var was_on_floor = player.is_on_floor()
	
	player.velocity = player.move_and_slide(player.velocity, Vector2.UP)
	
	if not player.is_on_floor() and was_on_floor:
		player.coyote_timer.start()
		player.velocity.y = 0
	
	if Input.is_action_pressed("shoot") and PlayerInfo.has_gun:
		state_machine.change("Shoot")
	elif Input.is_action_just_pressed("jump"):
		state_machine.change("Air", {"jump": true})
	elif is_equal_approx(x_input, 0.0):
		state_machine.change("Idle")
