extends Equipment


const InvisibleFart = preload("res://src/Nodes/Environment/Projectiles/InvisibleFart/InvisibleFart.tscn")


func _init() -> void:
	self.id = 4
	self.name = "Deadly Fart"
	self.slot = SLOT.PASSIVE
	self.gold = 1
	self.description = "Makes your dash deadly."
	self.texture = load("res://Assets/Art/fart2.png")



func use(player) -> void:
	pass



func equip(player) -> void:
	player.state_machine.connect("state_entered", self, "_on_Player_state_entered", [player])
	player.state_machine.connect("state_exited", self, "_on_Player_state_exited", [player])
	# connect to dash state for example
	pass


func unequip(player) -> void:
	player.state_machine.disconnect("state_entered", self, "_on_Player_state_entered")
	player.state_machine.disconnect("state_exited", self, "_on_Player_state_exited")



func _on_Player_state_entered(state_name, player) -> void:
	if state_name == "Dash":
		var bullet = InvisibleFart.instance()
		var direction = Vector2(player.looking_direction, 0)
			
		Events.emit_signal("bullet_created", bullet)
			
		if !bullet.is_inside_tree():
			return
		# player bullet layer, enemy mask
		bullet.hitbox.set_collision_layer_bit(2, true)
		bullet.hitbox.set_collision_mask_bit(1, true)
		bullet.launch(direction)
		bullet.global_position = player.fart_position.global_position



func _on_Player_state_exited(state_name, player) -> void:
	if state_name == "Dash":
		pass
		#player.hurtbox.monitoring = true
		#player.hurtbox.set_deferred("monitorable", true)
