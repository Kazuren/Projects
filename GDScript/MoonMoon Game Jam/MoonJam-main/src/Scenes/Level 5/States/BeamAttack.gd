extends BossState

const sfx = preload("res://Assets/Audio/SFX/im_not_fucking_balddistort.wav")
const Beam = preload("res://src/Scenes/Level 5/Beam/Beam.tscn")

var state_time: float = 3.0

var beams: int = 3
var activation_time: float = 0.65
var beam_duration: float = 1.0

var attack_delay: float
var shoot_timer: float = 0.0

var beam_count: int = 0
var last_beam
var finished: bool = false


func _ready() -> void:
	pass # Replace with function body.


func enter(data: Dictionary = {}) -> void:
	if !is_instance_valid(boss.boss_entity):
		return
	
	
	Audio.play_effect(sfx, 1.0, boss.boss_entity.global_position)
	
	if boss.boss_entity.health < boss.boss_entity.max_health / 2:
		activation_time = 0.55
		beams = 5
		state_time = 5.0
	
	finished = false
	shoot_timer = 0
	beam_count = 0
	boss.boss_entity.show_beam()
	attack_delay = float(state_time) / float(beams)
	# AnimationPlayer play animation, open mouth
	
	#boss.boss_entity.health
	# if boss.health < 1000 ++count


func physics_update(delta: float) -> void:
	shoot_timer += delta
	while shoot_timer >= attack_delay and beam_count < beams:
		shoot_timer -= attack_delay
		last_beam = create_beam()
		beam_count += 1
	
	if beam_count >= beams and !finished:
		finished = true
		last_beam.connect("tree_exited", self, "_on_last_beam_tree_exited", [], CONNECT_ONESHOT)
		#state_machine.change("ChoosingAttack") 


func create_beam() -> Node:
	var beam = Beam.instance()
	beam.activation_time = activation_time
	beam.duration = beam_duration
	add_child(beam)
	beam.global_position = boss.boss_entity.beam_position.global_position
	beam.aim(boss.player.global_position)
	return beam


func _on_last_beam_tree_exited() -> void:
	state_machine.change("ChoosingAttack") 


func exit() -> void:
	if !is_instance_valid(boss.boss_entity):
		return
	boss.boss_entity.hide_beam()
