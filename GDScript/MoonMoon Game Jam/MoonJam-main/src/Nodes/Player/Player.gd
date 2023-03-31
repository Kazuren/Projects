tool
class_name Player
extends KinematicBody2D

signal death
signal health_changed
signal max_health_changed
signal cum_stacks_changed
signal max_cum_stacks_changed

#const footstep_effect = preload("res://Assets/SFX/footsteps.wav")

const MOVEMENTS = {
	"move_left": -1,
	"move_right": 1
}

const got_hit_sfx = preload("res://Assets/Audio/SFX/player_got_hit.wav")
const CumBullet: PackedScene = preload("res://src/Nodes/Environment/Projectiles/CumBullet/CumBullet.tscn")
const DeathEffect = preload("res://src/Nodes/Environment/DeathEffect.tscn")


# 7 64x64 tiles per second
export var speed: int = 7 * 64
export var max_dash_speed: int = 18 * 64
export var min_dash_speed: int = 11 * 64


export var jump_time_to_peak: float = 0.38
export var jump_time_to_descent: float = 0.32
export var jump_stall_time: float = 0.07


export var min_jump_height: float = 125
export var max_jump_height: float = 250
export var parry_jump_height: float = 200

export var health: int = 3 setget set_health
export var max_health: int = 3 setget set_max_health


onready var max_jump_velocity: float = ((2.0 * max_jump_height) / jump_time_to_peak) * -1.0
onready var min_jump_velocity: float = ((2.0 * min_jump_height) / jump_time_to_peak) * -1.0
onready var parry_jump_velocity: float = ((2.0 * parry_jump_height) / jump_time_to_peak) * -1.0

onready var jump_gravity: float = ((-2.0 * max_jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity: float = ((-2.0 * max_jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

onready var energy_beam_area = $EnergyBeamArea

var velocity: Vector2 = Vector2.ZERO
var snap_length: int = 32
var max_slides: int = 32
var snap_vector: Vector2 = Vector2.DOWN * snap_length

var cum_stacks: int = 0 setget set_cum_stacks
var max_cum_stacks: int = 5 setget set_max_cum_stacks
#var gravity: float

var direction_history: Array = []
var looking_direction: int = 1 setget set_looking_direction
var dead: bool = false

var main_weapon: bool = true



#var weapon1: Equipment = null
#var weapon2: Equipment = null
#var special: Equipment = null
#var passive: Equipment = null


onready var animation_player = $AnimationPlayer
onready var state_machine = $StateMachine

onready var pivot = $Pivot

onready var sprite = $Pivot/Sprite

onready var coyote_timer = $CoyoteTimer
onready var jump_buffer = $JumpBuffer
onready var jump_stall_timer = $JumpStallTimer

onready var shooting_cooldown = $ShootingCooldown
onready var bullet_spawn_point = $Pivot/BulletSpawnPoint

onready var hurtbox = $Pivot/Hurtbox
onready var hurtbox_timer = $Pivot/Hurtbox/Timer

onready var parry_cooldown = $ParryCooldown
onready var parry_timer = $ParryTimer
onready var parry_area = $ParryArea

onready var dash_cooldown = $DashCooldown

onready var ray1 = $RayCast2D
onready var ray2 = $RayCast2D2


onready var center = $Pivot/Center

onready var god_ray = $GodRay
#onready var special_ability_shoot_cooldown = $SpecialAbilityShootCooldown

onready var fart_position = $Pivot/FartPosition
onready var fart_bar = $Node/FartBarPosition/FartBar

onready var death_effect_position = $DeathEffectPosition


func _ready() -> void:
	Globals.player = self
	Events.connect("game_resumed", self, "_on_Events_game_resumed")
	hurtbox_timer.connect("timeout", self, "_on_Hurtbox_timer_timeout")
	hurtbox.connect("area_entered", self, "_on_Hurtbox_area_entered")
	
	
	for item in Globals.equipped_items:
		if item:
			item.equip(self)
			#print(item)


func _process(delta: float) -> void:
	for direction in direction_history:
		if !Input.is_action_pressed(direction):
			direction_history.erase(direction)
	
	if !Engine.editor_hint:
		# 1.5 is dash_cooldown
		fart_bar.value = (1 - (dash_cooldown.time_left / 1.5)) * 100


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_weapon"):
		main_weapon = !main_weapon
	
	for direction in MOVEMENTS.keys():
		if event.is_action_pressed(direction):
			if !direction_history.has(direction):
				direction_history.append(direction)
		if event.is_action_released(direction):
			direction_history.erase(direction)


func _on_Events_game_resumed():
	for direction in MOVEMENTS.keys():
		if Input.is_action_pressed(direction):
			if !direction_history.has(direction):
				direction_history.append(direction)


func get_gravity() -> float:
	if !jump_stall_timer.is_stopped():
		return 0.0
	if velocity.y < 0.0:
		return jump_gravity
	else:
		return fall_gravity
	#return jump_gravity if velocity.y < 0.0 else fall_gravity


func get_xinput() -> int:
	if direction_history.empty():
		return 0
	else:
		return MOVEMENTS[direction_history.back()]


func get_aiming_direction() -> Vector2:
	var x_dir = sign(Input.get_axis("move_left", "move_right"))
	var y_dir
	
	#var crouching = -sign(Input.get_action_strength("look_up"))
	# if in air and pressing crouch we can aim down 
	# or if we're moving we can aim diagonally down
	if !is_on_floor() or x_dir != 0:
		y_dir = sign(Input.get_axis("look_up", "crouch"))
	elif Input.is_action_pressed("crouch"):
		y_dir = 0
	else:
		y_dir = -sign(Input.get_action_strength("look_up"))
	
	var direction = Vector2(x_dir, y_dir)
	if direction == Vector2.ZERO:
		direction.x = looking_direction
	
	return direction.normalized()


func set_looking_direction(value: int) -> void:
	if looking_direction != value:
		scale.x *= -1
		#hurtbox.scale.x *= -1
		#pivot.scale.x *= -1
	
	looking_direction = value
	
	#sprite.flip_h = looking_direction < 0
	

func shoot() -> void:
	var weapon1 = Globals.equipped_items[0]
	var weapon2 = Globals.equipped_items[1]
	
	if !weapon1:
		weapon2.use(self)
	elif !weapon2:
		weapon1.use(self)
	elif weapon1 and weapon2:
		if main_weapon:
			weapon1.use(self)
		else:
			weapon2.use(self)
	
#	if main_weapon:
#		Globals.equipped_items[0].shoot(self)
#	else:
#		Globals.equipped_items[1].shoot(self)
	# do equipment[0].shoot()
func special() -> bool:
	var special_ability = Globals.equipped_items[2]
	if !special_ability:
		return false
	
	state_machine.change("SpecialAbility")
	
	return true


func set_health(value: int) -> void:
	health = min(value, max_health)
	emit_signal("health_changed", health)
	if !dead:
		Audio.play_effect(got_hit_sfx, 1.0, global_position)
	
	if health <= 0 and !dead:
		var death_effect = DeathEffect.instance()
		death_effect.initialize(sprite.texture)
		get_tree().root.add_child(death_effect)
		death_effect.global_position = death_effect_position.global_position
		death_effect.scale.x = looking_direction
		visible = false
		dead = true
		fart_bar.visible = false
		disable()
		state_machine.change("Death")
		emit_signal("death")


func set_max_health(value: int) -> void:
	max_health = value
	emit_signal("max_health_changed", max_health)
	if max_health < health:
		self.health = max_health


func set_cum_stacks(value: int) -> void:
	cum_stacks = min(value, max_cum_stacks)
	emit_signal("cum_stacks_changed", cum_stacks)


func set_max_cum_stacks(value: int) -> void:
	max_cum_stacks = value
	emit_signal("max_cum_stacks_changed", max_cum_stacks)


func _on_Hurtbox_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		if hurtbox_timer.is_stopped():
			self.health -= area.damage
			hurtbox.set_deferred("monitoring", false)
			hurtbox_timer.start()
			animation_player.play("invulnerable")


func _on_Hurtbox_timer_timeout():
	hurtbox.monitoring = true


func _draw() -> void:
	if Engine.editor_hint:
		draw_line(Vector2.ZERO, Vector2(0, -max_jump_height), Color.red, 2, true)


func enable() -> void:
	hurtbox.monitoring = true


func disable() -> void:
	hurtbox.set_deferred("monitoring", false)
