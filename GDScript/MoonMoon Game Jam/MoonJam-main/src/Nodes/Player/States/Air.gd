extends PlayerState

var jumping: bool = false
var stalling: bool = false

# If we get a message asking us to jump, we jump.
func enter(data: Dictionary = {}) -> void:
	jumping = false
	if data.has("jump"):
		player.velocity.y = player.max_jump_velocity
		jumping = true
		stalling = false
		player.coyote_timer.stop()
		player.jump_buffer.stop()
	player.snap_vector = Vector2.ZERO


func exit() -> void:
	player.snap_vector = Vector2.DOWN * player.snap_length
	player.jump_stall_timer.stop()


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
	
	if Input.is_action_pressed("lock"):
		x_input = 0.0
	
	player.velocity.x = player.speed * x_input
	
	player.velocity.y += player.get_gravity() * delta
	player.velocity = player.move_and_slide_with_snap(
		player.velocity, player.snap_vector, Vector2.UP, true, player.max_slides
	)
	#player.velocity = player.move_and_slide(player.velocity, Vector2.UP)
	
	
	if player.is_on_floor():# Landing
		if is_equal_approx(player.velocity.x, 0.0):
			state_machine.change("Idle")
		else:
			state_machine.change("Walk")
		return
	
	
	if jumping and player.velocity.y >= 0 and player.jump_stall_timer.is_stopped() and Input.is_action_pressed("jump") and !stalling:
		player.jump_stall_timer.start(player.jump_stall_time)
		player.velocity.y = 0
		stalling = true
	
	
	if !Input.is_action_pressed("jump"):
		stalling = false
		player.jump_stall_timer.stop()
	
	
	if jumping and player.velocity.y >= 0 and !stalling:
		jumping = false
		player.jump_stall_timer.stop()
	
	
	if jumping and !Input.is_action_pressed("jump") and player.velocity.y < player.min_jump_velocity:
		jumping = false
		stalling = false
		player.jump_stall_timer.stop()
		player.velocity.y = player.min_jump_velocity
	
	
	if Input.is_action_just_pressed("jump"):
		player.jump_buffer.start()
		if player.parry_cooldown.is_stopped():
			state_machine.change("Parry")
	
