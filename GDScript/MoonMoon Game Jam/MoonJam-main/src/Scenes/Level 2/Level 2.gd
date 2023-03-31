extends Level



func _on_VictoryMenu_continue_pressed(victory_menu) -> void:
	get_tree().paused = false
	victory_menu.queue_free()
	queue_free()
	get_tree().change_scene("res://src/Scenes/FactoryScene/Factory.tscn")
