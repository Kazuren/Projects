class_name BossState
extends State


var boss: Boss


func _ready() -> void:
	yield(owner, "ready")
	boss = owner as Boss
	assert(boss != null)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
