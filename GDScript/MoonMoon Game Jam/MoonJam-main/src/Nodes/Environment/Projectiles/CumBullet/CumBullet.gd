extends Projectile


const SplashEffect = preload("res://src/Nodes/Environment/Projectiles/CumBullet/SplashEffect.tscn")
const sfx = preload("res://Assets/Audio/SFX/bullethit.wav")

onready var line = $Line2D
onready var hitbox_environment = $HitboxEnvironment

export(int) var point_count = 20
export(float) var frequency = 20.0
export(float) var sine_speed = 20.0
export(float, 1.0, 64.0) var cycles = 12.0
var time: float = 0.0


func _ready() -> void:
	hitbox_environment.connect("area_entered", self, "_on_HitboxEnvironment_area_entered")
	hitbox_environment.connect("body_entered", self, "_on_HitboxEnvironment_body_entered")
	line.clear_points()
	for i in point_count:
		line.add_point(Vector2.ZERO)



func _process(delta: float) -> void:
	time += delta * sine_speed
	var length = ($Line2D/End.position - $Line2D/Start.position).length()
	for i in range(0, point_count - 1):
		var t = float(i) / float(point_count)
		var x = t * length
		line.set_point_position(i, Vector2(
			x,
			sin(t * cycles + time) * frequency
		))
	
	#line.set_point_position(0, $Line2D/Start.global_position))
	line.set_point_position(point_count -1, $Line2D/End.position)


func _on_timer_timeout() -> void:
	create_splash()
	queue_free()


func _on_Area_entered(area: Area2D) -> void:
	Audio.play_effect(sfx, 1.0, global_position)
	create_splash()
	queue_free()


func _on_Body_entered(body: Node) -> void:
	Audio.play_effect(sfx, 1.0, global_position)
	create_splash()
	queue_free()


func _on_HitboxEnvironment_area_entered(area: Area2D) -> void:
	Audio.play_effect(sfx, 1.0, global_position)
	create_splash()
	queue_free()


func _on_HitboxEnvironment_body_entered(body: Node) -> void:
	Audio.play_effect(sfx, 1.0, global_position)
	create_splash()
	queue_free()


func create_splash() -> void:
	var splash_effect = SplashEffect.instance()
	splash_effect.direction = direction
	splash_effect.emitting = true
	
	
	get_tree().root.add_child(splash_effect)
	splash_effect.global_position = $Line2D/End.global_position
