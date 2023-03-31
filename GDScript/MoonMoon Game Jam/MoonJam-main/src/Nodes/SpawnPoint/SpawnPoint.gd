extends Node2D

signal paused
signal unpaused

export(PackedScene) var enemy_scene

export(bool) var continuous = false

export(int) var looking_direction = 1.0
export(float) var cooldown = 1.0
export(float) var cooldown_offset = 0.0

export(float) var animation_time = 1.5
export(NodePath) var parent_path
export(bool) var spawn_on_ready = true
export(bool) var pause_off_screen = true
export(bool) var disable_hitbox_offscreen = true

export(bool) var disable_off_screen = true


export(float) var parriable_chance = 0.0
export(bool) var use_sequence_instead = false
export(int) var parriable_every_xth_spawn = 5
export(int) var parry_x_offset = 0

#export(int) var starting_direction = 1
#export(bool) var pause_off_screen = true
#export(bool) var disable_hitbox_offscreen = true

var velocity: Vector2 = Vector2.ZERO
var bullet_spawn_point: Node
#var looking_direction: int = 1

var time: float = 0.0

var spawned: Array = []
var paused: bool = false setget set_paused
var total_spawned: int = 0

onready var tween = $Tween
onready var parent = get_node(parent_path)
onready var visibility_enabler = $VisibilityEnabler2D


func _ready() -> void:
	if disable_off_screen:
		visibility_enabler.process_parent = true
		visibility_enabler.physics_process_parent = true
	
	
	add_to_group("spawn_points")
	if spawn_on_ready:
		time = cooldown
	
	time = time - cooldown_offset


func _process(delta: float) -> void:
	if paused:
		return
	if !continuous and !spawned.empty():
		return
	
	time += delta
	
	if time >= cooldown:
		time -= cooldown
		spawn()


func set_paused(value: bool) -> void:
	if value == paused:
		return
	paused = value
	if paused:
		emit_signal("paused")
	else:
		emit_signal("unpaused")


func spawn() -> void:
	if !continuous and !spawned.empty():
		return
	
	var enemy = enemy_scene.instance()
	spawned.append(enemy)
	total_spawned += 1
	
	enemy.disable_hitbox_offscreen = disable_hitbox_offscreen
	enemy.pause_off_screen = pause_off_screen
	enemy.scale = Vector2.ZERO
	enemy.spawning = true
	
	add_child(enemy)
	
	if use_sequence_instead:
		if (total_spawned + parry_x_offset) % parriable_every_xth_spawn == 0:
			enemy.parriable = true
	else:
		var percent = Globals.RNG.randf()
		if parriable_chance >= percent:
			enemy.parriable = true
	
	enemy.disable_hitbox()
	#enemy.disable_physics()
	enemy.look(looking_direction)
	
	enemy.disabled = true
	
	tween.interpolate_property(
		enemy, "scale", 
		Vector2.ZERO, Vector2(1, 1),
		animation_time
	)
	tween.start()
	var timer = get_tree().create_timer(animation_time)
	timer.connect("timeout", self, "_on_Timer_timeout", [enemy])
	enemy.connect("death", self, "_on_enemy_death", [enemy])


func _on_enemy_death(enemy: Enemy) -> void:
	spawned.erase(enemy)


func _on_Timer_timeout(enemy: Enemy) -> void:
	if !is_instance_valid(enemy):
		return
	if paused:
		connect("unpaused", self, "_on_Timer_timeout", [enemy], CONNECT_ONESHOT)
	else:
		remove_child(enemy)
		parent.add_child(enemy)
		enemy.spawning = false
		enemy.look(looking_direction)
		enemy.enable_hitbox()
		#enemy.enable_physics()
		enemy.global_position = global_position
		enemy.disabled = false
		
		for node in $AI.get_children():
			var dupe = node.duplicate()
			dupe.entity = enemy
			enemy.AI.add_child(dupe)
			dupe.setup(enemy)
