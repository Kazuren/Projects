extends Projectile



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
