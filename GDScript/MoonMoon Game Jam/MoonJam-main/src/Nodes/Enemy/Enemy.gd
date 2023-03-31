class_name Enemy
extends KinematicBody2D

signal death
signal spawned

const DeathEffect = preload("res://src/Nodes/Environment/DeathEffect.tscn")
const death_sfx = preload("res://Assets/Audio/SFX/enemydeathsfx.wav")

export(AudioStream) var shoot_sfx

export(int) var health = 3 setget set_health
export(int) var speed = 200
export(float) var gravity = 1500
export(int) var starting_direction = 1
export(bool) var pause_off_screen = true
export(bool) var disable_hitbox_offscreen = true
export(bool) var disable_physics = false

var velocity: Vector2 = Vector2.ZERO
var bullet_spawn_point: Node
var looking_direction: int = 1

var ai_disabled: bool = false
var disabled: bool = false

var parriable: bool = false setget set_parriable

onready var hurtbox = $Hurtbox
onready var hitbox = $Hitbox
onready var animation_player = $AnimationPlayer
onready var sprite = get_node_or_null("Sprite")

onready var floor_ray_cast_left = get_node_or_null("FloorRayCastLeft")
onready var floor_ray_cast_right = get_node_or_null("FloorRayCastRight")
onready var ray_cast_left = get_node_or_null("RayCastLeft")
onready var ray_cast_right = get_node_or_null("RayCastRight")

onready var AI = $AI

onready var death_effect_position = $DeathEffectPosition
onready var visibility_enabler = get_node_or_null("VisibilityEnabler2D")

var snap_length = 32
var snap_vector = Vector2.DOWN * snap_length
var spawning: bool = false setget set_spawning


func set_spawning(value: bool) -> void:
	if value == false and spawning == true:
		emit_signal("spawned")
	spawning = value


func set_parriable(value: bool) -> void:
	parriable = value


func _ready() -> void:
	add_to_group("enemies")
	
	if disable_physics:
		$CollisionShape2D.disabled = true
	
	bullet_spawn_point = get_node_or_null("BulletSpawnPoint")
	hurtbox.connect("area_entered", self, "_on_Hurtbox_area_entered")
	
	if spawning:
		yield(self, "spawned")
	
	
	
	look(starting_direction)
	
	for ai in AI.get_children():
		ai.owner = self
		ai.setup(self)
	
	
	if visibility_enabler:
		if pause_off_screen:
			set_physics_process(false)
			set_process(false)
			visibility_enabler.process_parent = true
			visibility_enabler.physics_process_parent = true
		if disable_hitbox_offscreen:
			disable_physics()
		visibility_enabler.connect("screen_entered", self, "_on_VisibilityEnabler_screen_entered")
		visibility_enabler.connect("screen_exited", self, "_on_VisibilityEnabler_screen_exited")


func _on_VisibilityEnabler_screen_entered() -> void:
	if disable_hitbox_offscreen:
		enable_physics()


func _on_VisibilityEnabler_screen_exited() -> void:
	if disable_hitbox_offscreen:
		disable_physics()


func enable_physics() -> void:
	for node in hitbox.get_children():
		if node is CollisionShape2D:
			node.set_deferred("disabled", false)
	
	for node in hurtbox.get_children():
		if node is CollisionShape2D:
			node.set_deferred("disabled", false)


func disable_physics() -> void:
	for node in hitbox.get_children():
		if node is CollisionShape2D:
			node.set_deferred("disabled", true)
	
	for node in hurtbox.get_children():
		if node is CollisionShape2D:
			node.set_deferred("disabled", true)


func enable_hitbox() -> void:
	for node in hitbox.get_children():
		if node is CollisionShape2D:
			node.set_deferred("disabled", false)


func disable_hitbox() -> void:
	for node in hitbox.get_children():
		if node is CollisionShape2D:
			node.set_deferred("disabled", true)




func _physics_process(delta: float) -> void:
	if disabled:
		return
	
	if !ai_disabled:
		for node in AI.get_children():
			node._physics_process(delta)
	else:
		velocity.x = 0
	
	velocity.y += gravity * delta
	velocity = move_and_slide_with_snap(
		velocity, snap_vector, Vector2.UP, true
	)


func look(dir: int) -> void:
	looking_direction = dir
	sprite.flip_h = dir < 0


func shoot(bullet: Projectile, direction: Vector2) -> void:
	Events.emit_signal("bullet_created", bullet)
	if shoot_sfx:
		Audio.play_effect(shoot_sfx, 1.0, global_position)
	if !bullet.is_inside_tree():
		return
	# enemy bullet layer, player mask
	bullet.hitbox.set_collision_layer_bit(3, true)
	bullet.hitbox.set_collision_mask_bit(0, true)
	bullet.launch(direction)
	bullet.global_position = bullet_spawn_point.global_position if bullet_spawn_point else global_position


func enable_ai() -> void:
	ai_disabled = false


func disable_ai() -> void:
	ai_disabled = true


func enable() -> void:
	disabled = false


func disable() -> void:
	disabled = true


func set_health(value: int) -> void:
	health = value
	if health <= 0:
		emit_signal("death")
		# possibly make a particles death animation here
		var death_effect = DeathEffect.instance()
		death_effect.initialize(sprite.texture, scale)
		get_tree().root.add_child(death_effect)
		death_effect.scale.x = looking_direction
		death_effect.global_position = death_effect_position.global_position
		Audio.play_effect(death_sfx, 1.0, global_position)
		queue_free()


#func hit(damage: int) -> void:
#	self.health -= damage
#	animation_player.play("Hit")


func _on_Hurtbox_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		self.health -= area.damage
		animation_player.play("Hit")
