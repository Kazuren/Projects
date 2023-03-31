class_name Enemy
extends KinematicBody2D

signal death
signal hit

const enemy_death_effect = preload("res://Assets/SFX/enemy-death.wav")
const enemy_hit_effect = preload("res://Assets/SFX/enemy-hit.wav")


export var health: int = 3 setget set_health
export var speed: int = 100
export var damage: int = 3
export var invincible: bool = false
export var animation_speed_scale: float = 1.0

var velocity: Vector2 = Vector2.ZERO
var gravity: int = 800

var player = null

onready var player_detection_zone = $PlayerDetectionZone
onready var hitbox = $HitBox
onready var animation_player = $AnimationPlayer
onready var movement_animation_player = $MovementAnimationPlayer
onready var sprite = $Sprite


func _ready() -> void:
	movement_animation_player.playback_speed = animation_speed_scale
	player_detection_zone.connect("body_entered", self, "_on_PlayerDetectionZone_Body_entered")
	player_detection_zone.connect("body_exited", self, "_on_PlayerDetectionZone_Body_exited")
	hitbox.connect("area_entered", self, "_on_Hitbox_Area_entered")


func _physics_process(delta: float) -> void:
	if can_see_player():
		seek_player()
		movement_animation_player.play("Run")
	else:
		velocity.x = 0
		movement_animation_player.play("Idle")
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity)


func hit(damage) -> void:
	if invincible:
		return
	self.health -= damage
	animation_player.play("Hit")
	player = Globals.player
	emit_signal("hit")
	Audio.play_effect(enemy_hit_effect)


func set_health(value: int) -> void:
	health = value
	if health <= 0:
		emit_signal("death")
		queue_free()
		Audio.play_effect(enemy_death_effect)


func can_see_player() -> bool:
	return player != null


func _on_PlayerDetectionZone_Body_entered(body: Node) -> void:
	if body is Player:
		player = body


func _on_PlayerDetectionZone_Body_exited(body: Node) -> void:
	player = null


func _on_Hitbox_Area_entered(area: Area2D) -> void:
	if area.owner.has_method("hit"):
		area.owner.hit(damage)


func seek_player() -> void:
	var direction = position.direction_to(player.global_position)
	if direction.x > 0:
		sprite.flip_h = false
		velocity.x = 1 * speed
	elif direction.x < 0:
		sprite.flip_h = true
		velocity.x = -1 * speed

