extends BossState


#var Tentacle = preload("res://src/Scenes/Level 3/Tentacle/Tentacle.tscn")
#var tentacles = []

#var tentacle_start_animation_time: float = 2.0
#
#var tentacle_attack_delay_time: float = 1.0
#var tentacle_attack_time: float = 1.25
#
#var tentacle_pull_back_time: float = 2.0
#var tentacle_pull_back_delay_time: float = 1.0

const Bullet = preload("res://src/Nodes/Environment/Projectiles/ArcedRockBullet/ArcedRockBullet.tscn")
const sfx = preload("res://Assets/Audio/SFX/you_will_never_be_japanesedistort.wav")
#onready var tween = $Tween

var state_time: float = 6.0
var state_time_left: float = 6.0

var number_of_attacks: int = 16
var parriable_amount: float = 15

var attack_delay: float
var shoot_timer: float = 0.0
var bullets = []


func _ready() -> void:
	pass # Replace with function body.


func enter(data: Dictionary = {}) -> void:
	if !is_instance_valid(boss):
		return
	if !is_instance_valid(boss.boss_entity):
		return
	
	
	boss.current_sfx = Audio.play_effect(sfx, 1.0, boss.boss_entity.global_position)
	if boss.boss_entity.health < boss.boss_entity.max_health / 2:
		number_of_attacks = 24
		parriable_amount = 23
		state_time = 8.0
		
	
	shoot_timer = 0
	state_time_left = state_time
	attack_delay = float(state_time) / float(number_of_attacks)
	
	bullets.clear()
	
	for i in number_of_attacks:
		var bullet = Bullet.instance()
		bullets.append(bullet)
	
	for i in parriable_amount:
		bullets[i].parriable = true
		
	bullets.shuffle()
	# AnimationPlayer play animation, open mouth
	
	#boss.boss_entity.health
	# if boss.health < 1000 ++count

#onready var state_machine = $StateMachine

#onready var current_path = top_bottom_right_side_path

#print("tentacle")

func physics_update(delta: float) -> void:
	shoot_timer += delta
	state_time_left -= delta
	while shoot_timer >= attack_delay:
		shoot_timer -= attack_delay
		var bullet = bullets.pop_front()
		if bullet:
			shoot(bullet)
	if state_time_left <= 0:
		state_machine.change("ChoosingAttack")


func shoot(bullet) -> void:
	if !is_instance_valid(boss):
		return
	if !is_instance_valid(boss.boss_entity):
		return
	var direction = boss.boss_entity.yapping_position.global_position.direction_to(boss.player.global_position)
	
	Events.emit_signal("bullet_created", bullet)
	
	if !bullet.is_inside_tree():
		return
	
	bullet.target_position = boss.player.global_position
	bullet.target_range = boss.boss_entity.yapping_position.global_position.distance_to(boss.player.global_position)
	bullet.global_position = boss.boss_entity.yapping_position.global_position
	bullet.launch(direction)


func exit() -> void:
	bullets.clear()
