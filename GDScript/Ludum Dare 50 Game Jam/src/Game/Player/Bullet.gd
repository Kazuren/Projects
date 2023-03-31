extends Area2D


var direction: Vector2
var speed = 50 * 16
var damage = 1

onready var animation_player = $AnimationPlayer
onready var sprite = $Sprite
onready var kill_timer = $KillTimer


func _ready() -> void:
	animation_player.play("Shoot")
	connect("area_entered", self, "_on_Area_entered")
	connect("body_entered", self, "_on_Body_entered")
	kill_timer.connect("timeout", self, "_on_KillTimer_timeout")
	sprite.flip_h = direction.x < 0


func _physics_process(delta: float) -> void:
	position += transform.x * speed * direction * delta


func _on_Area_entered(area: Area2D) -> void:
	if area.owner.has_method("hit"):
		area.owner.hit(damage)
	speed = 0
	animation_player.play("Hit")
	yield(animation_player, "animation_finished")
	queue_free()


func _on_Body_entered(body: Node) -> void:
	animation_player.play("Hit")
	speed = 0
	yield(animation_player, "animation_finished")
	queue_free()


func _on_KillTimer_timeout() -> void:
	queue_free()
