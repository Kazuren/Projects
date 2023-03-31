extends Equipment

const CumMissile = preload("res://src/Nodes/Environment/Projectiles/CumMissile/CumMissile.tscn")
var cooldown: float = 0.25


func _init() -> void:
	self.id = 2
	self.name = "Hunter Cum"
	self.slot = SLOT.ATTACK
	self.gold = 1
	self.description = "Cum bullets will seek out enemies within an area"
	self.texture = load("res://Assets/Art/Pellet.png")


func equip(player) -> void:
	# connect to dash state for example
	pass


func unequip(player) -> void:
	pass


func use(player) -> void:
	player.shooting_cooldown.start(cooldown)
	var bullet = CumMissile.instance()
	var direction = player.get_aiming_direction()
	
	Events.emit_signal("bullet_created", bullet)
	
	if !bullet.is_inside_tree():
		return
	# player bullet layer, enemy mask
	bullet.hitbox.set_collision_layer_bit(2, true)
	bullet.hitbox.set_collision_mask_bit(1, true)
	bullet.launch(direction)
	bullet.global_position = player.bullet_spawn_point.global_position

