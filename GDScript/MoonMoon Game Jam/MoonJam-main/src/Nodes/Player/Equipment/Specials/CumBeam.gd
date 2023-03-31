extends Equipment

const sfx = preload("res://Assets/Audio/SFX/playerGodRay.wav")


var duration: float = 3.0
var time_left: float = 3.0


var dot_timer: float = 0.1
var time_since_dot: float = 0


func _init() -> void:
	self.id = 7
	self.name = "Cum Beam"
	self.slot = SLOT.SPECIAL
	self.gold = 2
	self.description = "Borpa fires a powerful vertical beam of cum, greatly damaging any enemy caught in its path"
	self.texture = load("res://Assets/Art/beam.png")


func equip(player) -> void:
	# connect to dash state for example
	pass


func unequip(player) -> void:
	pass


func use(player) -> void:
	pass


func enter(player, data: Dictionary = {}) -> void:
	Audio.play_effect(sfx, 1.0, player.global_position)
	#var special_ability = Globals.equipped_items[2]
	#special_ability.enter()
	#special_ability.physics_update()
	#special_ability.exit()
	time_left = 3.0
	
	player.get_tree().call_group("enemies", "disable")
	player.get_tree().call_group("spawn_points", "set_paused", true)
	
	player.cum_stacks = 0
	player.velocity = Vector2.ZERO
	player.hurtbox.set_deferred("monitoring", false)
	
	player.energy_beam_area.monitoring = true
	player.energy_beam_area.monitorable = true
	player.animation_player.play("EnergyBeam")



func exit(player) -> void:
	player.hurtbox.monitoring = true
	player.energy_beam_area.set_deferred("monitoring", false)
	player.energy_beam_area.set_deferred("monitorable", false)
	player.god_ray.visible = false
	player.energy_beam_area.visible = false
	player.get_tree().call_group("enemies", "enable")
	player.get_tree().call_group("spawn_points", "set_paused", false)


func physics_update(player, delta: float) -> void:
	time_left -= delta
	
#	if time_left <= 2.0:
#		time_since_dot += delta
#		if time_since_dot >= dot_timer:
#			time_since_dot -= dot_timer
#			#player.energy_beam_area.set_deferred("monitoring", false) 
#			#player.energy_beam_area.set_deferred("monitorable", false)
#			player.energy_beam_area.set_deferred("monitoring", true)
#			player.energy_beam_area.set_deferred("monitorable", true)
	
	
	if time_left <= 2.0 and !player.energy_beam_area.monitorable:
		pass
		#player.energy_beam_area.monitoring = true
		#player.energy_beam_area.monitorable = true
		#player.energy_beam_area.get_overlapping_areas()
		#player.energy_beam_area.set_deferred("monitorable", true)
	
	
	if time_left <= 0:
		if player.is_on_floor(): # Landing
			if is_equal_approx(player.velocity.x, 0.0):
				player.state_machine.change("Idle")
			else:
				player.state_machine.change("Walk")
			return
		else:
			player.state_machine.change("Air")


