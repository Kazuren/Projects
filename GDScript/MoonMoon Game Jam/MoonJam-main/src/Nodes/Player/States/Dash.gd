extends PlayerState

var duration: float = 0.3
var time_left: float = 0.3

const FartCloud = preload("res://src/Nodes/Player/FartCloud.tscn")
const sfx = preload("res://Assets/Audio/SFX/borpaBoost.wav")


func enter(data: Dictionary = {}) -> void:
	Audio.play_effect(sfx, 1.0, player.global_position)
	time_left = duration
	player.velocity.y = 0
	player.dash_cooldown.start()
	create_fart()


func exit() -> void:
	for fart in player.fart_position.get_children():
		var pos = fart.global_position
		fart.get_parent().remove_child(fart)
		get_tree().root.add_child(fart)
		fart.global_position = pos


func physics_update(delta: float) -> void:
	if Input.is_action_just_pressed("special") and player.cum_stacks == player.max_cum_stacks:
		if player.special():
			return
	
	
	var t = 1 - (time_left / duration)
	t = ease(t, 2)
	
	var speed = lerp(player.max_dash_speed, player.min_dash_speed, t)
	
	player.velocity.x = speed * player.looking_direction
	
	#player.velocity.y += player.get_gravity() * delta
	player.velocity = player.move_and_slide_with_snap(
		player.velocity, player.snap_vector, Vector2.UP, true, player.max_slides
	)
	#player.velocity = player.move_and_slide(player.velocity, Vector2.UP)
	
	if Input.is_action_just_pressed("jump") and !player.is_on_floor():
		player.jump_buffer.start()
		if player.parry_cooldown.is_stopped():
			state_machine.change("Parry")
			return
	
	time_left -= delta
	
	if time_left <= 0:
		if player.is_on_floor(): # Landing
			if is_equal_approx(player.velocity.x, 0.0):
				state_machine.change("Idle")
			else:
				state_machine.change("Walk")
			return
		else:
			state_machine.change("Air")
	


func create_fart() -> void:
	var fart = FartCloud.instance()
	fart.direction = Vector2(player.looking_direction, 0)
	fart.emitting = true
	#fart.lifetime = duration
	#get_tree().root.add_child(fart)
	player.fart_position.add_child(fart)
	#fart.global_position = player.fart_position.global_position
