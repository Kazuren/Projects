extends Node2D

# Todo list:

# For moon:
# controller recommended (but not sure if my dpad is broken or bad coding but dpad was stuttering for me)


const MainMenu = preload("res://src/Interface/MainMenu/MainMenu.tscn")


func _ready() -> void:
	var menu = MainMenu.instance()
	Interface.add_child(menu)

