extends PlayerState


var duration: float = 0.15
var parry_duration: float = 0.15
var time: float = 0.0

const sfx = preload("res://Assets/Audio/SFX/playerParry.wav")


func enter(data: Dictionary = {}) -> void:
	time = 0.0
	
	player.hurtbox.set_deferred("monitoring", false)
	player.parry_cooldown.start()
	player.parry_timer.start(duration)
	player.parry_timer.connect("timeout", self, "_on_ParryTimer_timeout")
	
	player.parry_area.connect("area_entered", self, "_on_ParryArea_area_entered")
	player.parry_area.connect("body_entered", self, "_on_ParryArea_body_entered")
	player.parry_area.monitoring = true


func exit() -> void:
	player.sprite.rotation = 0
	player.parry_timer.disconnect("timeout", self, "_on_ParryTimer_timeout")
	player.parry_area.disconnect("area_entered", self, "_on_ParryArea_area_entered")
	player.parry_area.disconnect("body_entered", self, "_on_ParryArea_body_entered")
	player.parry_area.set_deferred("monitoring", false)
	
	if !player.hurtbox.monitoring:
		player.hurtbox.monitoring = true


func physics_update(delta: float) -> void:
	# if we want shooting
	#if Input.is_action_pressed("shoot") and player.shooting_cooldown.is_stopped():
	#	player.shoot()
	
	var x_input: float = player.get_xinput()
	
	if !is_equal_approx(x_input, 0.0):
		player.looking_direction = x_input
	
	if Input.is_action_just_pressed("special") and player.cum_stacks == player.max_cum_stacks:
		if player.special():
			return
	
	if Input.is_action_pressed("dash") and player.dash_cooldown.is_stopped():
		state_machine.change("Dash")
		return
	
	if Input.is_action_pressed("lock"):
		x_input = 0.0
	
	time += delta
	var t = time / duration
	
	if time > parry_duration:
		if !player.hurtbox.monitoring:
			player.hurtbox.monitoring = true
	
	player.sprite.rotation = TAU * t
	
	player.velocity.x = player.speed * x_input
	
	player.velocity.y += player.get_gravity() * delta
	player.velocity = player.move_and_slide_with_snap(
		player.velocity, player.snap_vector, Vector2.UP, true, player.max_slides
	)
	#player.move_and_slide(player.velocity, Vector2.UP)
	
	
	if Input.is_action_just_pressed("jump"):
		player.jump_buffer.start()
	
	if player.is_on_floor(): # Landing
		if is_equal_approx(player.velocity.x, 0.0):
			state_machine.change("Idle")
		else:
			state_machine.change("Walk")
		return


func _on_ParryArea_area_entered(area: Area2D) -> void:
	if time > parry_duration:
		return
	
	Audio.play_effect(sfx, 1.0, player.global_position)
	# sound effect here for successful parry
	# if we successfully parry, cooldown is reset
	player.parry_cooldown.stop()
	player.dash_cooldown.stop()
	if area.owner is Projectile:
		area.owner.queue_free()
		player.cum_stacks += 1
	
	# Jump after successful parry
	player.velocity.y = player.parry_jump_velocity
	# Freeze frames (2)
	Events.emit_signal("game_paused")
	get_tree().paused = true
	yield(get_tree().create_timer(0.033), "timeout")
	get_tree().paused = false
	Events.emit_signal("game_resumed")


func _on_ParryArea_body_entered(body: Node) -> void:
	if time > parry_duration:
		return
	
	Audio.play_effect(sfx, 1.0, player.global_position)
	# sound effect here for successful parry
	# if we successfully parry, cooldown is reset
	player.parry_cooldown.stop()
	player.dash_cooldown.stop()
	
	# Jump after successful parry
	player.velocity.y = player.parry_jump_velocity
	# Freeze frames (2)
	Events.emit_signal("game_paused")
	get_tree().paused = true
	yield(get_tree().create_timer(0.033), "timeout")
	get_tree().paused = false
	Events.emit_signal("game_resumed")
	print(body)


func _on_ParryTimer_timeout() -> void:
	if player.is_on_floor(): # Landing
		if is_equal_approx(player.velocity.x, 0.0):
			state_machine.change("Idle")
		else:
			state_machine.change("Walk")
		return
	else:
		state_machine.change("Air")
