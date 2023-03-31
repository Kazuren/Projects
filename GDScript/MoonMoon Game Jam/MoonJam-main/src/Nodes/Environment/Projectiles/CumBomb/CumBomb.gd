extends Projectile


const SplashEffect = preload("res://src/Nodes/Environment/Projectiles/CumBomb/CumBombSplashEffect.tscn")
const sfx = preload("res://Assets/Audio/SFX/bullethit.wav")

onready var blast_area = $BlastArea
onready var bomb_sprite = $Panel
#onready var hitbox_environment = $HitboxEnvironment


var time: float = 0.0

var velocity: Vector2 = Vector2.ZERO
var target_position: Vector2

export(int) var up_gravity = 1920
export(int) var down_gravity = 2880
export(int) var target_range = 448



func _ready() -> void:
	pass
	#blast_area.connect("area_entered", self, "_on_BlastArea_area_entered")
	#blast_area.connect("body_entered", self, "_on_BlastArea_body_entered")



func launch(dir: Vector2) -> void:
	hitbox.connect("area_entered", self, "_on_Area_entered")
	hitbox.connect("body_entered", self, "_on_Body_entered")
	#rotation = atan2(dir.y, dir.x)
	#direction = dir
	
	target_position = dir * target_range + global_position
	target_position += Vector2(rand_range(-64, 64), rand_range(-64, 64))
	#print(target_position)
	
	var arc_height = target_position.y - global_position.y - 32
	arc_height = min(arc_height, -32)
	#print(arc_height)
	velocity = PhysicsHelper.calculate_arc_velocity(
		global_position, target_position, arc_height, 
		up_gravity, down_gravity
	)
	if dir == Vector2.DOWN:
		velocity.x = 0
		velocity.y = target_range
	#print(velocity)
	#velocity = velocity.clamped(1000)
	velocity.rotated(rand_range(-0.1, 0.1))
	
	launched = true
	var timer = get_tree().create_timer(lifetime, false)
	timer.connect("timeout", self, "_on_timer_timeout")


func physics_update(delta: float) -> void:
	if velocity.y > 0:
		velocity.y += down_gravity * delta
	else:
		velocity.y += up_gravity * delta
	
	position += velocity * delta


func _on_timer_timeout() -> void:
	create_splash()
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
	
	blast_area.monitoring = true
	blast_area.set_deferred("monitorable", true)
	bomb_sprite.visible = false
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	queue_free()


func _on_Area_entered(area: Area2D) -> void:
	create_splash()
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
	
	blast_area.monitoring = true
	blast_area.set_deferred("monitorable", true)
	bomb_sprite.visible = false
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	queue_free()


func _on_Body_entered(body: Node) -> void:
	create_splash()
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
	
	blast_area.monitoring = true
	blast_area.set_deferred("monitorable", true)
	#blast_area.monitorable = true
	bomb_sprite.visible = false
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	queue_free()



#func _on_HitboxEnvironment_area_entered(area: Area2D) -> void:
#	create_splash()
#	queue_free()
#
#
#func _on_HitboxEnvironment_body_entered(body: Node) -> void:
#	create_splash()
#	queue_free()


func create_splash() -> void:
	Audio.play_effect(sfx, 1.0, global_position)
	var splash_effect = SplashEffect.instance()
	splash_effect.emitting = true
	
	
	get_tree().root.add_child(splash_effect)
	splash_effect.global_position = global_position
