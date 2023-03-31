extends Equipment

const CumBullet: PackedScene = preload("res://src/Nodes/Environment/Projectiles/CumBullet/CumBullet.tscn")
const sfx = preload("res://Assets/Audio/SFX/playerGodRay.wav")


var available_angles = []

var duration: float = 3.0
var time_left: float = 3.0

var bullets = 50
var cooldown: float

var shoot_timer: float = 0.0


func _init() -> void:
	self.id = 6
	self.name = "Cumageddon"
	self.slot = SLOT.SPECIAL
	self.gold = 1
	self.description = "Shoots a lot of projectiles in the direction you're facing"
	self.texture = load("res://Assets/Art/specialattacc.png")


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
	available_angles.clear()
	time_left = 3.0
	
	cooldown = duration / float(bullets)
	
	var dir = Vector2(player.looking_direction, 0)
	var angle = dir.angle()
	for i in bullets:
		var t = float(i + 1) / float(bullets)
		t -= 0.5
		available_angles.append(
			deg2rad(75) * t + angle
		)
	
	available_angles.shuffle()
	
	
	player.get_tree().call_group("enemies", "disable")
	player.get_tree().call_group("spawn_points", "set_paused", true)
	
	player.cum_stacks = 0
	player.velocity = Vector2.ZERO
	player.hurtbox.set_deferred("monitoring", false)
	player.animation_player.play("SpecialAbility")


func _on_ShootCooldown_timeout(player) -> void:
	#player.shoot()
	
	var bullet = CumBullet.instance()
	var angle = available_angles.pop_back()
	var direction = Vector2(cos(angle), sin(angle))
	
	Events.emit_signal("bullet_created", bullet)
	
	if !bullet.is_inside_tree():
		return
	
	# player bullet layer, enemy mask
	bullet.hitbox.set_collision_layer_bit(2, true)
	bullet.hitbox.set_collision_mask_bit(1, true)
	bullet.launch(direction)
	bullet.global_position = player.bullet_spawn_point.global_position


func exit(player) -> void:
	available_angles.clear()
	player.hurtbox.monitoring = true
	player.god_ray.visible = false
	player.get_tree().call_group("enemies", "enable")
	player.get_tree().call_group("spawn_points", "set_paused", false)


func physics_update(player, delta: float) -> void:
	time_left -= delta
	
	shoot_timer += delta
	
	while shoot_timer >= cooldown:
		shoot_timer -= cooldown
		_on_ShootCooldown_timeout(player)
	
	if time_left <= 0:
		if player.is_on_floor(): # Landing
			if is_equal_approx(player.velocity.x, 0.0):
				player.state_machine.change("Idle")
			else:
				player.state_machine.change("Walk")
			return
		else:
			player.state_machine.change("Air")
