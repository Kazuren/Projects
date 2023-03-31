class_name BackAndForthAI
extends Node

export(bool) var fall_off_edges = false
export(int) var direction = 1

var entity


func _ready() -> void:
	set_physics_process(false)
	set_process(false)
#	if owner is Enemy:
#		yield(owner, "ready")
#		entity = owner
#		entity.look(direction)
#	print(direction)



func setup(entity) -> void:
	self.entity = entity
	entity.look(direction)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _physics_process(delta: float) -> void:
	#var floor_below = entity.floor_ray_cast_left.get_collider()
	
	if !fall_off_edges and entity.is_on_floor():
		if direction == -1 and entity.floor_ray_cast_left.get_collider() == null:
			direction = 1
			entity.look(direction)
		elif direction == 1 and entity.floor_ray_cast_right.get_collider() == null:
			direction = -1
			entity.look(direction)
		
	if direction == -1 and entity.ray_cast_left.get_collider():
		direction = 1
		entity.look(direction)
	elif direction == 1 and entity.ray_cast_right.get_collider():
		direction = -1
		entity.look(direction)
	
	entity.velocity.x = entity.speed * direction
