class_name Projectile
extends Node2D


export var lifetime: float = 2.0
export var speed: float = 100

var direction
var launched: bool = false
var parriable: bool = false


onready var hitbox = $Hitbox


func _ready() -> void:
	speed = speed * 60
	
	
func launch(dir: Vector2) -> void:
	hitbox.connect("area_entered", self, "_on_Area_entered")
	hitbox.connect("body_entered", self, "_on_Body_entered")
	rotation = atan2(dir.y, dir.x)
	direction = dir
	
	launched = true
	var timer = get_tree().create_timer(lifetime, false)
	timer.connect("timeout", self, "_on_timer_timeout")


func _physics_process(delta: float) -> void:
	physics_update(delta)


func physics_update(delta: float) -> void:
	if launched:
		position += transform.x * speed * delta


func _on_timer_timeout() -> void:
	queue_free()


func _on_Area_entered(area: Area2D) -> void:
	#print(area)
	queue_free()
	#print(area)
	#pass
	#if area is Hurtbox:
		#queue_free()
	#if area.owner.has_method("hit"):
	#	area.owner.hit(damage)
	#speed = 0
	#animation_player.play("Hit")
	#yield(animation_player, "animation_finished")
	


func _on_Body_entered(body: Node) -> void:
	#print(body)
	#animation_player.play("Hit")
	#speed = 0
	#yield(animation_player, "animation_finished")
	queue_free()

