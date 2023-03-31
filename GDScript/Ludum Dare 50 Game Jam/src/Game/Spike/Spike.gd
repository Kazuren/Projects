extends Area2D


var damage = 3

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body: Node):
	if body is Player:
		if body.has_method("hit"):
			body.hit(damage)
