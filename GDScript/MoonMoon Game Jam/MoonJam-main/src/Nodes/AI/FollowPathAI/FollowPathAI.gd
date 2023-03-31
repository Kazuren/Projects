class_name FollowPathAI
extends Node

signal path_ended


export(NodePath) var path_node_path
export(bool) var kill_on_end = true
export(bool) var rotate = false
export(bool) var use_unit_offset = false
export(float) var time_required = 0.0
export(float) var ease_curve = 1.0


export(bool) var loop = false

onready var path = get_node(path_node_path)


var path_follow_2d
var entity
var time = 0.0
var reverse: bool = false

func _ready() -> void:
	set_physics_process(false)
	set_process(false)


func setup(entity) -> void:
	self.entity = entity
	path_follow_2d = PathFollow2D.new()
	path_follow_2d.rotate = rotate
	path_follow_2d.loop = false#loop
	path.add_child(path_follow_2d)
	entity.get_parent().remove_child(entity)
	path_follow_2d.add_child(entity)
	entity.position = Vector2.ZERO

	connect("path_ended", self, "_on_path_ended")


func _physics_process(delta: float) -> void:
	time += delta
	
	if !use_unit_offset:
	#	var t = ease(time / time_required, ease_curve)
		var speed = entity.speed
		if reverse:
			speed *= -1
		path_follow_2d.offset += speed * delta
	else:
		var t = time / time_required
		if reverse:
			t = 1 - t
		path_follow_2d.unit_offset = ease(t, ease_curve)
	
	if path_follow_2d.unit_offset >= 1 and !reverse:
		if loop:
			reverse = !reverse
		else:
			emit_signal("path_ended")
	elif path_follow_2d.unit_offset <= 0 and reverse:
		if loop:
			reverse = !reverse
		else:
			emit_signal("path_ended")


func _on_path_ended() -> void:
	if kill_on_end:
		entity.connect("tree_exiting", self, "_on_entiy_tree_exiting")
		entity.health = 0


func _on_entiy_tree_exiting() -> void:
	path_follow_2d.queue_free()
