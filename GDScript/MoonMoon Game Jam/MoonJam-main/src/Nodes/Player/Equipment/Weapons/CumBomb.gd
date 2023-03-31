extends Equipment


const CumBomb = preload("res://src/Nodes/Environment/Projectiles/CumBomb/CumBomb.tscn")

var cooldown: float = 0.5


func _init() -> void:
	self.id = 3
	self.name = "Cum Bomb"
	self.slot = SLOT.ATTACK
	self.gold = 1
	self.description = "Shoots a large ball of cum that explodes upon contact, dealing aoe damage."
	self.texture = load("res://Assets/Art/bomb.png")


func equip(player) -> void:
	# connect to dash state for example
	pass


func unequip(player) -> void:
	pass


func use(player) -> void:
	player.shooting_cooldown.start(cooldown)
	var bullet = CumBomb.instance()
	var direction = player.get_aiming_direction()
	
	Events.emit_signal("bullet_created", bullet)
	
	if !bullet.is_inside_tree():
		return
	# player bullet layer, enemy mask
	bullet.hitbox.set_collision_layer_bit(2, true)
	bullet.hitbox.set_collision_mask_bit(1, true)
	bullet.blast_area.set_collision_layer_bit(2, true)
	bullet.blast_area.set_collision_mask_bit(1, true)
	bullet.global_position = player.bullet_spawn_point.global_position
	bullet.launch(direction)
