class_name Main
extends Node2D

const SettingsMenu = preload("res://src/Interface/Menus/Settings/Settings.tscn")
onready var camera = $Player/Camera2D
onready var tilemap = $TileMap
onready var player = $Player


func _ready():
	camera.current = true
	get_tree().paused = false
	Events.emit_signal("game_resumed")
	player.connect("death", self, "_on_Player_death")
	set_camera_limits()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		var menu = SettingsMenu.instance()
		$UI/Interface.add_child(menu)


func set_camera_limits():
	var map_limits = tilemap.get_used_rect()
	var map_cellsize = tilemap.cell_size
	camera.limit_left = map_limits.position.x * map_cellsize.x
	camera.limit_right = map_limits.end.x * map_cellsize.x
	camera.limit_top = map_limits.position.y * map_cellsize.y
	camera.limit_bottom = map_limits.end.y * map_cellsize.y


func _on_Player_death() -> void:
	get_tree().reload_current_scene()
