extends Enemy


onready var pivot = $Pivot


func _ready() -> void:
	sprite = $Pivot/Sprite


func look(dir) -> void:
	
	if dir != looking_direction:
		$Pivot.scale.x *= -1
		var temp = floor_ray_cast_left
		floor_ray_cast_left = floor_ray_cast_right
		floor_ray_cast_right = temp
		
		temp = ray_cast_left
		ray_cast_left = ray_cast_right
		ray_cast_right = temp
	
	looking_direction = dir
	
