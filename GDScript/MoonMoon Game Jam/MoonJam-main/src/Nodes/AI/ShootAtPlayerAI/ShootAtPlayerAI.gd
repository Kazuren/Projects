class_name ShootAtPlayerAI
extends Node2D


export(int) var detection_radius = 512
export(float) var cooldown = 2.0
export(PackedScene) var Bullet
export(float) var parriable_bullet_chance = 0.5
export(bool) var variable_y_value = false
export(bool) var shoot_only_when_looking = false
#export(AudioStream) var sfx


var entity
var player

onready var player_detection_area = $PlayerDetectionArea
onready var player_detection_shape = $PlayerDetectionArea/CollisionShape2D
onready var cooldown_timer = $Timer


func _ready() -> void:
	set_physics_process(false)
	set_process(false)
	#entity.look(direction)


func setup(entity) -> void:
	self.entity = entity
	player_detection_area.connect("body_entered", self, "_on_PlayerDetectionArea_body_entered")
	player_detection_area.connect("body_exited", self, "_on_PlayerDetectionArea_body_exited")
	player_detection_shape.shape.radius = detection_radius



func _physics_process(delta: float) -> void:
#	if !entity:
#		return
	if player and cooldown_timer.is_stopped():
		if shoot_only_when_looking:
			var dir = entity.global_position.direction_to(player.center.global_position)
			var dot = dir.dot(Vector2(entity.looking_direction, 0))
			if dot < 0.0:
				return
		
		# TODO make each enemy export sfx instead of the ai
		#if sfx:
		#	Audio.play_effect(sfx, 1.0, entity.global_position)
		
		var bullet = Bullet.instance()
		var direction
		if variable_y_value:
			direction = entity.global_position.direction_to(player.center.global_position)
		else:
			direction = entity.global_position.direction_to(
				Vector2(player.center.global_position.x, entity.global_position.y)
			)
		var percent = Globals.RNG.randf()
		if parriable_bullet_chance >= percent:
			bullet.parriable = true
		
		cooldown_timer.start(cooldown)
		entity.shoot(bullet, direction)


func _on_PlayerDetectionArea_body_entered(body: Node) -> void:
	if body is Player:
		player = body


func _on_PlayerDetectionArea_body_exited(body: Node) -> void:
	if body == player:
		player = null
