extends Particles2D


var direction


func _ready() -> void:
	process_material.set("direction", -Vector3(direction.x, direction.y, 0))


func _process(delta: float) -> void:
	if !emitting:
		queue_free()
