extends PlayerState

var jumping: bool = false


# If we get a message asking us to jump, we jump.
func enter(data: Dictionary = {}) -> void:
	jumping = false
	player.animation_node.travel("Jump")
	if data.has("jump"):
		player.velocity.y = player.max_jump_velocity
		jumping = true
		player.coyote_timer.stop()
		player.jump_buffer.stop()


func physics_update(delta: float) -> void:
	var x_input: float = player.get_xinput()
	
	if !is_equal_approx(x_input, 0.0):
		player.looking_direction = x_input
	
	player.velocity.x = player.speed * x_input
	
	player.velocity.y += player.gravity * delta
	player.velocity = player.move_and_slide(player.velocity, Vector2.UP)
	
	if player.is_on_floor():# Landing
		if is_equal_approx(player.velocity.x, 0.0):
			state_machine.change("Idle")
		else:
			state_machine.change("Walk")
	
	if jumping and player.velocity.y >= 0:
		jumping = false
	if jumping and !Input.is_action_pressed("jump") and player.velocity.y < player.min_jump_velocity:
		jumping = false
		player.velocity.y = player.min_jump_velocity
	if Input.is_action_just_pressed("jump"):
		player.jump_buffer.start()
	
