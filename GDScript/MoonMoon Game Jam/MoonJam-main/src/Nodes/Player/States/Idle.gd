extends PlayerState


func enter(data: Dictionary = {}) -> void:
	player.velocity = Vector2.ZERO


func physics_update(delta: float) -> void:
	var x_input: float = player.get_xinput()
	
	if !is_equal_approx(x_input, 0.0):
		player.looking_direction = x_input
	
	if Input.is_action_pressed("shoot") and player.shooting_cooldown.is_stopped():
		player.shoot()
	
	if Input.is_action_just_pressed("special") and player.cum_stacks == player.max_cum_stacks:
		if player.special():
			return
		#state_machine.change("SpecialAbility")
		#return
	
	if Input.is_action_pressed("dash") and player.dash_cooldown.is_stopped():
		state_machine.change("Dash")
		return
	
	if !player.jump_buffer.is_stopped() and !Input.is_action_pressed("crouch"):
		state_machine.change("Air", {"jump": true})
		return
	if not player.is_on_floor():
		state_machine.change("Air")
		return
	
	if Input.is_action_pressed("lock"):
		x_input = 0.0
	
	player.velocity.y += player.get_gravity() * delta
	player.velocity = player.move_and_slide_with_snap(
		player.velocity, player.snap_vector, Vector2.UP, true, player.max_slides
	)
	#player.move_and_slide(player.velocity, Vector2.UP)
	
	
	if Input.is_action_pressed("crouch"):
		#player.hurtbox.scale.y = 0.5
		#player.sprite.scale.y = 0.5
		player.pivot.scale.y = 0.5
		if Input.is_action_pressed("jump"):
			var platform1 = player.ray1.get_collider()
			var platform2 = player.ray2.get_collider()
			if (platform1 and platform1 is OneWayPlatform) or (platform2 and platform2 is OneWayPlatform):
				player.position.y += 2
				state_machine.change("Air")
				return
	else:
		player.pivot.scale.y = 1
		#player.hurtbox.scale.y = 1
		#player.sprite.scale.y = 1
	
	
	if Input.is_action_just_pressed("jump"):
		state_machine.change("Air", {"jump": true})
	elif !is_equal_approx(x_input, 0.0):
		state_machine.change("Walk")


func exit() -> void:
	player.pivot.scale.y = 1
	#player.hurtbox.scale.y = 1
	#player.sprite.scale.y = 1
