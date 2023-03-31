extends PlayerState


var special_ability


func enter(data: Dictionary = {}) -> void:
	special_ability = Globals.equipped_items[2]
	special_ability.enter(player, data)
	#special_ability.enter()
	#special_ability.physics_update()
	#special_ability.exit()
	

func exit() -> void:
	special_ability.exit(player)


func physics_update(delta: float) -> void:
	special_ability.physics_update(player, delta)
	
