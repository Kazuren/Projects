class_name Player
extends KinematicBody2D

signal death

const footstep_effect = preload("res://Assets/SFX/footsteps.wav")

const MOVEMENTS = {
	"move_left": -1,
	"move_right": 1
}

export var speed: int = 7 * 16

export var jump_duration: float = 0.45
export var min_jump_height: float = 20
export var max_jump_height: float = 40
export var health: int = 3 setget set_health


var max_jump_velocity: float
var min_jump_velocity: float
var velocity: Vector2 = Vector2.ZERO
var gravity: float

var direction_history: Array = []
var looking_direction: int = 1 setget set_looking_direction

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_node = animation_tree.get("parameters/playback")
onready var effects_animation_player = $EffectsAnimationPlayer
onready var state_machine = $StateMachine
onready var sprite = $Sprite
onready var coyote_timer = $CoyoteTimer
onready var jump_buffer = $JumpBuffer
onready var bullet_spawn_point = $BulletSpawnPoint
onready var bullet_spawn_point_flipped = $BulletSpawnPointFlipped
onready var hurtbox = $Hurtbox
onready var hurtbox_timer = $Hurtbox/Timer
onready var shooting_buffer = $ShootingBuffer


func _ready() -> void:
	Globals.player = self
	gravity = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)
	Events.connect("game_resumed", self, "_on_Events_game_resumed")
	hurtbox_timer.connect("timeout", self, "_on_Hurtbox_timer_timeout")


func _process(delta: float) -> void:
	for direction in direction_history:
		if !Input.is_action_pressed(direction):
			direction_history.erase(direction)


func _unhandled_input(event: InputEvent) -> void:
	for direction in MOVEMENTS.keys():
		if event.is_action_pressed(direction):
			direction_history.append(direction)
		if event.is_action_released(direction):
			direction_history.erase(direction)


func _on_Events_game_resumed():
	for direction in MOVEMENTS.keys():
		if Input.is_action_pressed(direction):
			if !direction_history.has(direction):
				direction_history.append(direction)


func get_xinput() -> int:
	if !PlayerInfo.can_input:
		return 0
	if direction_history.empty():
		return 0
	else:
		return MOVEMENTS[direction_history.back()]


func set_looking_direction(value: int) -> void:
	looking_direction = value
	sprite.flip_h = looking_direction < 0


func set_health(value: int) -> void:
	health = value
	if health <= 0:
		emit_signal("death")


func hit(damage: int) -> void:
	if hurtbox_timer.is_stopped():
		self.health -= damage
		hurtbox.set_deferred("monitoring", false)
		hurtbox_timer.start()


func _on_Hurtbox_timer_timeout():
	hurtbox.monitoring = true


func play_footstep_sound() -> void:
	Audio.play_effect(footstep_effect)
