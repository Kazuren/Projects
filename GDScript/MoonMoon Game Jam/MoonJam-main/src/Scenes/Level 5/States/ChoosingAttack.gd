extends BossState


var attacks = [
	"YappingAttack",
	"TentacleAttack",
	"BeamAttack"
]


var previous_attacks_chosen: Array = []
var attacks_done: int = 0

var wait_time_before_attack: float = 2.0


func _ready() -> void:
	pass


func switch_vertical_path() -> void:
	if boss.current_path == boss.top_bottom_right_side_path:
		if boss.boss_path.unit_offset == 1:
			state_machine.change("Moving", {
				"path": boss.top_bottom_right_side_path,
				"offset": 0
			})
		else:
			state_machine.change("Moving", {
				"path": boss.top_bottom_right_side_path,
				"offset": 1
			})
	elif boss.current_path == boss.top_bottom_left_side_path:
		if boss.boss_path.unit_offset == 1:
			state_machine.change("Moving", {
				"path": boss.top_bottom_left_side_path,
				"offset": 0
			})
		else:
			state_machine.change("Moving", {
				"path": boss.top_bottom_left_side_path,
				"offset": 1
			})


func switch_horizontal_path() -> void:
	if boss.current_path == boss.top_bottom_right_side_path:
		if boss.boss_path.unit_offset == 1:
			state_machine.change("Moving", {
				"path": boss.bottom_horizontal_path,
				"offset": 0,
				"swap": [boss.top_bottom_left_side_path, 1]
			})
		else:
			state_machine.change("Moving", {
				"path": boss.top_horizontal_path,
				"offset": 0,
				"swap": [boss.top_bottom_left_side_path, 0]
			})
	elif boss.current_path == boss.top_bottom_left_side_path:
		if boss.boss_path.unit_offset == 1:
			state_machine.change("Moving", {
				"path": boss.bottom_horizontal_path,
				"offset": 1,
				"swap": [boss.top_bottom_right_side_path, 1]
			})
		else:
			state_machine.change("Moving", {
				"path": boss.top_horizontal_path,
				"offset": 1,
				"swap": [boss.top_bottom_right_side_path, 0]
			})


func enter(data: Dictionary = {}) -> void:
	if !is_instance_valid(boss):
		return
	if !is_instance_valid(boss.boss_entity):
		return
	
	if boss.boss_entity.health < boss.boss_entity.max_health / 2:
		wait_time_before_attack = 1.7
	
	
	var tree = boss.boss_entity.get_tree()
	if !tree:
		return
	var timer = tree.create_timer(wait_time_before_attack)
	timer.connect("timeout", self, "_on_ChooseAttackTimer_timeout", [data], CONNECT_ONESHOT)


func _on_ChooseAttackTimer_timeout(data) -> void:
	if !is_instance_valid(boss):
		return
	if !is_instance_valid(boss.boss_entity):
		return
	if attacks_done >= 3:
		switch_horizontal_path()
		attacks_done = 0
		return
	
	
	if !(data.has("moved") and data.moved):
		if Globals.RNG.randf() > 0.5:
			switch_vertical_path()
			return
	
	
	var _attacks = attacks.duplicate()
	for a in previous_attacks_chosen:
		_attacks.erase(a)
	
	var attack_index: int = Globals.RNG.randi_range(0, _attacks.size() - 1)
	var attack: String = _attacks[attack_index]
	
	#while previous_attacks_chosen.count(attack) >= 1:
	#	attack_index = Globals.RNG.randi_range(0, _attacks.size() - 1)
	#	attack = _attacks[attack_index]
	
	
	previous_attacks_chosen.append(attack)
	
	state_machine.change(attack)
	attacks_done += 1


func exit() -> void:
	if previous_attacks_chosen.size() > 1:
		#previous_attacks_chosen.shuffle()
		previous_attacks_chosen.pop_front()
