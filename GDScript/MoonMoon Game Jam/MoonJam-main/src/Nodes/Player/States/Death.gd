extends PlayerState


func enter(data: Dictionary = {}) -> void:
	player.dead = true
	player.velocity = Vector2.ZERO


func physics_update(delta: float) -> void:
	player.velocity = player.move_and_slide_with_snap(
		player.velocity, player.snap_vector, Vector2.UP, true, player.max_slides
	)
	#player.velocity = player.move_and_slide(player.velocity, Vector2.UP)

