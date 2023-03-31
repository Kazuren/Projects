extends BossState

const sfx = preload("res://Assets/Audio/SFX/MALDdistort.wav")


var Tentacle = preload("res://src/Scenes/Level 5/Tentacle/Tentacle.tscn")
var tentacles = []

var attack_texture = preload("res://src/Scenes/Level 5/headmanattacc.png")
var normal_texture = preload("res://src/Scenes/Level 5/headman2.png")

var tentacle_start_animation_time: float = 1.25

var tentacle_attack_delay_time: float = 0.75
var tentacle_attack_time: float = 0.75

var tentacle_pull_back_time: float = 1.0
var tentacle_pull_back_delay_time: float = 1.0
var horizontal_tentacle_count: int = 1
var vertical_tentacle_count: int = 4


onready var tween = $Tween


func _ready() -> void:
	pass # Replace with function body.


func enter(data: Dictionary = {}) -> void:
	if !is_instance_valid(boss):
		return
	if !is_instance_valid(boss.boss_entity):
		return
	
	boss.current_sfx = Audio.play_effect(sfx, 1.0, boss.boss_entity.global_position)
	if boss.boss_entity.health < boss.boss_entity.max_health / 2:
		tentacle_attack_time = 0.75
		tentacle_start_animation_time = 1.05
		tentacle_attack_delay_time = 0.55
		tentacle_pull_back_time = 1.0
		tentacle_pull_back_delay_time = 1.0
		horizontal_tentacle_count = 2
		vertical_tentacle_count = 8
	
	boss.boss_entity.sprite.texture = attack_texture
	# AnimationPlayer play animation, tentacles
	
	#boss.boss_entity.health
	# if boss.health < 1000 ++count
	
	var horizontal_left = boss.tentacle_positions.get_node("HorizontalLeft")
	var horizontal_right = boss.tentacle_positions.get_node("HorizontalRight")
	var vertical = boss.tentacle_positions.get_node("Vertical")
	var vertical2 = boss.tentacle_positions.get_node("Vertical2")
	
	
	if boss.current_path == boss.top_bottom_left_side_path:
		var rays = horizontal_left.get_children()
		for i in horizontal_tentacle_count:
			rays.shuffle()
			var ray = rays.pop_back()
			create_tentacle_in_ray(ray)
			#for ray in horizontal_left.get_children():
			#	tween.interpolate_property()
	elif boss.current_path == boss.top_bottom_right_side_path:
		var rays = horizontal_right.get_children()
		for i in horizontal_tentacle_count:
			rays.shuffle()
			var ray = rays.pop_back()
			create_tentacle_in_ray(ray)
	
	
	var rays = vertical.get_children()
	for i in vertical_tentacle_count / 2:
		rays.shuffle()
		var ray = rays.pop_back()
		create_tentacle_in_ray(ray)
	
	rays = vertical2.get_children()
	for i in vertical_tentacle_count / 2:
		rays.shuffle()
		var ray = rays.pop_back()
		create_tentacle_in_ray(ray)
	
	tween.start()
	tween.connect("tween_all_completed", self, "_on_start_completed", [], CONNECT_ONESHOT)

#onready var state_machine = $StateMachine

#onready var current_path = top_bottom_right_side_path

#print("tentacle")

func create_tentacle_in_ray(ray) -> void:
	if !is_instance_valid(boss):
		return
	if !is_instance_valid(boss.boss_entity):
		return
	var tentacle = Tentacle.instance()
	add_child(tentacle)
	tentacles.append(tentacle)
	tentacle.position = ray.global_position
	tentacle.direction = ray.cast_to.normalized()
	tentacle.look_at(tentacle.to_global(ray.cast_to))
	tween.interpolate_property(
		tentacle,
		"global_position", null, 
		tentacle.global_position + ray.cast_to, tentacle_start_animation_time
	)


func _on_start_completed() -> void:
	if !is_instance_valid(boss):
		return
	if !is_instance_valid(boss.boss_entity):
		return
	for tentacle in tentacles:
		
		var vertical = tentacle.direction == Vector2.DOWN
		var offset = 1080 if vertical else 1920
		# with bounce?
		# random delay?
		tween.interpolate_property(
			tentacle,
			"global_position", null,
			tentacle.global_position + tentacle.direction * (offset - 50),
			tentacle_attack_time, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT, tentacle_attack_delay_time
		)
	tween.start()
	tween.connect("tween_all_completed", self, "_on_strike_completed", [], CONNECT_ONESHOT)


func _on_strike_completed() -> void:
	if !is_instance_valid(boss):
		return
	if !is_instance_valid(boss.boss_entity):
		return
	for tentacle in tentacles:
		var vertical = tentacle.direction == Vector2.DOWN
		var offset = 1080 if vertical else 1920
		tween.interpolate_property(
			tentacle,
			"global_position", null,
			tentacle.global_position - tentacle.direction * (offset),
			tentacle_pull_back_time, Tween.TRANS_LINEAR, Tween.EASE_IN, tentacle_pull_back_delay_time
		)
	
	tween.start()
	tween.connect("tween_all_completed", self, "_on_attack_finished", [], CONNECT_ONESHOT)
	#var timer = boss.get_tree().create_timer(1.0)
	#timer.connect("timeout", self, "_on_strike_timer_completed")


func _on_attack_finished() -> void:
	state_machine.change("ChoosingAttack")


func exit() -> void:
	if !is_instance_valid(boss.boss_entity):
		return
	boss.boss_entity.sprite.texture = normal_texture
	for tentacle in tentacles:
		tentacle.queue_free()
	
	tentacles.clear()
