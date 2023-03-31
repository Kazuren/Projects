extends PlayerState


func enter(data: Dictionary = {}) -> void:
	pass


func physics_update(delta: float) -> void:
	var x_input: float = player.get_xinput()
	
	if !is_equal_approx(x_input, 0.0):
		player.looking_direction = x_input
	
	
	if Input.is_action_pressed("shoot") and player.shooting_cooldown.is_stopped():
		player.shoot()
	
	
	if Input.is_action_just_pressed("special") and player.cum_stacks == player.max_cum_stacks:
		if player.special():
			return
	
	if Input.is_action_pressed("dash") and player.dash_cooldown.is_stopped():
		state_machine.change("Dash")
		return
	
	if !player.jump_buffer.is_stopped() and !Input.is_action_pressed("crouch"):
		state_machine.change("Air", {"jump": true})
		return
	
	if not player.is_on_floor() and player.coyote_timer.is_stopped():
		state_machine.change("Air")
		return
	
	if Input.is_action_pressed("lock"):
		x_input = 0.0
	
	player.velocity.x = player.speed * x_input
	if player.coyote_timer.is_stopped():
		player.velocity.y += player.get_gravity() * delta
	var was_on_floor = player.is_on_floor()
	
	player.velocity = player.move_and_slide_with_snap(
		player.velocity, player.snap_vector, Vector2.UP, true, player.max_slides
	)
	#player.velocity = player.move_and_slide(player.velocity, Vector2.UP)
	
	if not player.is_on_floor() and was_on_floor:
		player.coyote_timer.start()
		player.velocity.y = 0
	
	
	if Input.is_action_just_pressed("jump"):
		state_machine.change("Air", {"jump": true})
	elif is_equal_approx(x_input, 0.0):
		state_machine.change("Idle")
