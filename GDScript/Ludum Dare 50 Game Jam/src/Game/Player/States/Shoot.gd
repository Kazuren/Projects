extends PlayerState

const Bullet = preload("res://src/Game/Player/Bullet.tscn")
const shoot_effect = preload("res://Assets/SFX/shoot.wav")


func enter(data: Dictionary = {}) -> void:
	player.animation_node.travel("Shoot")
	player.velocity = Vector2.ZERO
	player.shooting_buffer.stop()


func physics_update(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		player.shooting_buffer.start()


func change_state() -> void:
	if player.shooting_buffer.is_stopped():
		state_machine.change("Idle")
	else:
		state_machine.change("Shoot")


func shoot() -> void:
	Audio.play_effect(shoot_effect)
	var bullet = Bullet.instance()
	bullet.direction = Vector2(player.looking_direction, 0)
	if player.looking_direction < 0:
		bullet.position = player.bullet_spawn_point_flipped.global_position
	else:
		bullet.position = player.bullet_spawn_point.global_position
	player.get_parent().add_child(bullet)
