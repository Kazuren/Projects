extends Equipment



func _init() -> void:
	self.id = 5
	self.name = "Silent Fart"
	self.slot = SLOT.PASSIVE
	self.gold = 1
	self.description = "Borpa is immune to damage while dashing."
	self.texture = load("res://Assets/Art/fart1.png")


func equip(player) -> void:
	player.state_machine.connect("state_entered", self, "_on_Player_state_entered", [player])
	player.state_machine.connect("state_exited", self, "_on_Player_state_exited", [player])
	# connect to dash state for example
	pass


func unequip(player) -> void:
	player.state_machine.disconnect("state_entered", self, "_on_Player_state_entered")
	player.state_machine.disconnect("state_exited", self, "_on_Player_state_exited")


func use(player) -> void:
	pass



func _on_Player_state_entered(state_name, player) -> void:
	if state_name == "Dash":
		player.hurtbox.set_deferred("monitoring", false)
		player.hurtbox.set_deferred("monitorable", false)

func _on_Player_state_exited(state_name, player) -> void:
	if state_name == "Dash":
		player.hurtbox.monitoring = true
		player.hurtbox.set_deferred("monitorable", true)
