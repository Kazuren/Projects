extends Projectile


export(int) var up_gravity = 1536
export(int) var down_gravity = 1536
#export(int) var target_range = 448

var time: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var target_position: Vector2
var target_range: float

onready var outer_panel = $Control/OuterPanel
#onready var inner_panel = $Control/OuterPanel/MarginContainer/InnerPanel


func _ready() -> void:
	if parriable:
		# white projectile layer
		hitbox.set_collision_layer_bit(9, true)
		# white shader
		#$Sprite.material.set_shader_param("active", true)
		var style = outer_panel.get("custom_styles/panel")
		#style.border_width_top = 4
		#style.border_width_right = 4
		#style.border_width_bottom = 4
		#style.border_width_left = 4
		style.bg_color = Color(1.25, 1.25, 1.25)
		
		#style = inner_panel.get("custom_styles/panel")
		#style.border_color = Color.white


func launch(dir: Vector2) -> void:
	hitbox.connect("area_entered", self, "_on_Area_entered")
	hitbox.connect("body_entered", self, "_on_Body_entered")
	#rotation = atan2(dir.y, dir.x)
	#direction = dir
	#target_position = dir * target_range + global_position
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
	velocity = velocity.clamped(2000)
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


#func _on_timer_timeout() -> void:
#	create_splash()
#	hitbox.set_deferred("monitoring", false)
#	hitbox.set_deferred("monitorable", false)
#
#	blast_area.monitoring = true
#	blast_area.set_deferred("monitorable", true)
#	bomb_sprite.visible = false
#	yield(get_tree(), "physics_frame")
#	yield(get_tree(), "physics_frame")
#	queue_free()


#func _on_Area_entered(area: Area2D) -> void:
#	create_splash()
#	hitbox.set_deferred("monitoring", false)
#	hitbox.set_deferred("monitorable", false)
#
#	blast_area.monitoring = true
#	blast_area.set_deferred("monitorable", true)
#	bomb_sprite.visible = false
#	yield(get_tree(), "physics_frame")
#	yield(get_tree(), "physics_frame")
#	queue_free()
#
#
#func _on_Body_entered(body: Node) -> void:
#	create_splash()
#	hitbox.set_deferred("monitoring", false)
#	hitbox.set_deferred("monitorable", false)
#
#	blast_area.monitoring = true
#	blast_area.set_deferred("monitorable", true)
#	#blast_area.monitorable = true
#	bomb_sprite.visible = false
#	yield(get_tree(), "physics_frame")
#	yield(get_tree(), "physics_frame")
#	queue_free()

