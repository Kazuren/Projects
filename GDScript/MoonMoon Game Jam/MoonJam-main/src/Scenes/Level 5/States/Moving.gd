extends BossState


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var swap_path

var time_required: float = 1.5

var time_passed: float = 0.0
var t: float = 0

var path_follow
var offset



func _ready() -> void:
	pass # Replace with function body.


func enter(data = {}) -> void:
	if !is_instance_valid(boss):
		return
	if !is_instance_valid(boss.boss_entity):
		return
	if boss.boss_entity.health < boss.boss_entity.max_health / 2:
		time_required = 1.1
	
	time_passed = 0.0
	
	swap_path = null
	offset = data.offset
	
	if data.has("swap"):
		swap_path = data.swap
	
	var p = PathFollow2D.new()
	p.rotate = false
	p.loop = false
	p.unit_offset = offset
	
	# make current path the path we're moving on right now
	boss.current_path = data.path
	boss.boss_path = p
	
	# add new path follow 2d to path
	boss.current_path.add_child(p)
	# remove boss from the previous path and queue free it
	var previous_path = boss.boss_entity.get_parent()
	previous_path.remove_child(boss.boss_entity)
	previous_path.queue_free()
	
	# add boss to new path follow 2d
	p.add_child(boss.boss_entity)
	var t = time_passed / time_required
	if offset == 0:
		t = 1 - t
	t = ease(t, -3.0)
	p.unit_offset = clamp(t, 0, 1)
	# remove old path 2d
	#if path_follow:
	#	path_follow.queue_free()
	
	
	path_follow = p



func physics_update(delta: float) -> void:
	if !is_instance_valid(boss):
		return
	if !is_instance_valid(boss.boss_entity):
		return
	time_passed += delta
	var t = time_passed / time_required
	if offset == 0:
		t = 1 - t
	t = ease(t, -3.0)
	path_follow.unit_offset = clamp(t, 0, 1)
	if time_passed > time_required:
		if swap_path:
			boss.current_path = swap_path[0]
			var p = PathFollow2D.new()
			p.rotate = false
			p.loop = false
			boss.current_path.add_child(p)
			boss.boss_path = p
			# remove boss from the previous path and queue free it
			var previous_path = boss.boss_entity.get_parent()
			previous_path.remove_child(boss.boss_entity)
			previous_path.queue_free()
			p.unit_offset = swap_path[1]
			# add boss to new path follow 2d
			p.add_child(boss.boss_entity)
			
		
		state_machine.change("ChoosingAttack", {"moved": true})


func exit() -> void:
	pass


func new_path() -> void:
	pass


#state_machine.change("Moving", {
#				"path": top_horizontal_path,
#				"offset": 1,
#				"swap": [top_bottom_right_side_path, 0]
#			})
