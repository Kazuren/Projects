extends Equipment

const SmallCumBullet = preload("res://src/Nodes/Environment/Projectiles/SmallCumBullet/SmallCumBullet.tscn")

var cooldown: float = 0.1
var angles: Array = [
	-11.25, 0, 11.25
]

func _init() -> void:
	self.id = 1
	self.name = "Cum Blaster"
	self.slot = SLOT.ATTACK
	self.gold = 1
	self.description = "Rapidly fires 3 short-range cum bullets."
	self.texture = load("res://Assets/Art/shotgunpellets.png")


func equip(player) -> void:
	# connect to dash state for example
	pass


func unequip(player) -> void:
	pass


func use(player) -> void:
	player.shooting_cooldown.start(cooldown)
	var bullets = [
		SmallCumBullet.instance(),
		SmallCumBullet.instance(),
		SmallCumBullet.instance()
	]
	
	for i in bullets.size():
		var bullet = bullets[i]
		Events.emit_signal("bullet_created", bullet)
		if !bullet.is_inside_tree():
			return
		
		
		var direction = player.get_aiming_direction()
		direction = direction.rotated(deg2rad(angles[i]))
		# player bullet layer, enemy mask
		bullet.hitbox.set_collision_layer_bit(2, true)
		bullet.hitbox.set_collision_mask_bit(1, true)
		bullet.launch(direction)
		bullet.global_position = player.bullet_spawn_point.global_position

