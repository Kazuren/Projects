class_name Level
extends Node2D

export(int) var unlocks = 1
export(int) var id = 1
export(float) var best_time = 300.0

export(AudioStream) var intro
export(AudioStream) var music

const OptionsMenu = preload("res://src/Interface/OptionsMenu/OptionsMenu.tscn")
const GameOverMenu = preload("res://src/Interface/GameOverMenu/GameOverMenu.tscn")
const VictoryMenu = preload("res://src/Interface/VictoryMenu/VictoryMenu.tscn")


onready var tilemap = $TileMap
onready var camera = $Player/Camera2D
onready var player = $Player
onready var coins_container = $Coins
onready var finish_line = get_node_or_null("FinishLine")


var time_elapsed: float = 0.0
var max_transition_time: float = 2.0
var last_camera_surface_point: Vector2
var game_area: Rect2


var max_coins: int = 0


func _ready() -> void:
	if Globals.progress <= 1:
		Globals.progress = 2
		Globals.save_data()
		var dialog = Dialogic.start("EddieFirst")
		dialog.pause_mode = Node.PAUSE_MODE_PROCESS
		dialog.connect("timeline_end", self, "on_Dialog_timeline_end")
		add_child(dialog)
		get_tree().paused = true
		
	
	if Engine.editor_hint:
		return
	
	if music:
		if Audio.get_current_music() != music:
			Audio.play_music(music)
	
	var game_interface = Interface.get_node("GameInterface")
	if !game_interface.visible:
		game_interface.visible = true
	
	
	set_camera_limits()
	Events.connect("bullet_created", self, "_on_bullet_created")
	player.connect("death", self, "_on_Player_death")
	
	var coins = $Coins.get_children()
	max_coins = coins.size()
	for i in coins.size():
		var coin = coins[i]
		coin.level_id = id
		coin.id = i
		for c in Globals.coins_collected:
			if c.level == id and c.coin == coin.id:
				coin.queue_free()
	
	if finish_line:
		finish_line.connect("level_finished", self, "_on_Level_finished")


func calculate_score() -> int:
	var score = 0
	
	var time_multiplier: float = 1.0
	
	var time_score_reduction_index = 1 - (time_elapsed / best_time)
	if time_score_reduction_index < 0:
		time_multiplier = max(0, time_multiplier + time_score_reduction_index)
	
	score += lerp(0, 750, time_multiplier)
	
	var health_multiplier: float = float(player.health) / float(player.max_health)
	score += lerp(0, 250, health_multiplier)
	
	return int(round(score))


func _on_Level_finished() -> void:
	# play sfx
	Globals.progress = unlocks if unlocks > Globals.progress else Globals.progress
	var score = calculate_score()
	
	var coins = 0
	
	
	for coin in Globals.coins_collected:
		if coin.level == id:
			coins += 1
	
	Globals.level_completed(
		id, time_elapsed, player.health, player.max_health,
		coins, max_coins, score
	)
	Globals.save_data()
	var victory_menu = VictoryMenu.instance()
	Interface.add_child(victory_menu)
	victory_menu.init(time_elapsed, player.health, player.max_health, coins, max_coins, score)
	victory_menu.connect("continue_pressed", self, "_on_VictoryMenu_continue_pressed", [victory_menu])
	#var music_position = Audio.stop_music()
	Events.emit_signal("game_paused")
	get_tree().paused = true
	# initiate loading to level select


func _on_VictoryMenu_continue_pressed(victory_menu) -> void:
	get_tree().paused = false
	victory_menu.queue_free()
	queue_free()
	get_tree().change_scene("res://src/Interface/LevelSelectMenu/LevelSelectMenu.tscn")


func set_camera_limits():
	var map_limits = tilemap.get_used_rect()
	var map_cellsize = tilemap.cell_size
	camera.limit_left = map_limits.position.x * map_cellsize.x
	camera.limit_right = map_limits.end.x * map_cellsize.x
	camera.limit_top = 8#map_limits.position.y * map_cellsize.y
	camera.limit_bottom = map_limits.end.y * map_cellsize.y
	
	game_area = Rect2(
		Vector2(camera.limit_left, camera.limit_top - 10000),
		Vector2(abs(camera.limit_left) + camera.limit_right, abs(camera.limit_top - 10000) + camera.limit_bottom)
	)


func _physics_process(delta: float) -> void:
	time_elapsed += delta
	#var camera_surface = camera_limit_finder.get_collider()
	#var pos = camera_limit_finder.get_collision_point()
	#transition_progress += delta / transition_time
	if Engine.editor_hint:
		return
	
	if game_area and !game_area.has_point(player.global_position):
		player.health = 0
	


func _draw() -> void:
	pass


func _on_bullet_created(bullet: Projectile) -> void:
	$Bullets.add_child(bullet)


func _on_Player_death() -> void:
	get_tree().call_group("enemies", "disable_ai")
	
	yield(get_tree().create_timer(1), "timeout")
	var game_over_menu = GameOverMenu.instance()
	Interface.add_child(game_over_menu)
	Audio.stop_music()
	Globals.from_retry = true
	#Audio.start_death_music
	game_over_menu.connect("tree_exiting", self, "_on_GameOverMenu_tree_exiting")
	#Events.emit_signal("game_paused")
	#get_tree().paused = true


func _input(event: InputEvent) -> void:
	handle_input(event)


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and !player.dead:
		var options_menu = OptionsMenu.instance()
		Interface.add_child(options_menu)
		#var music_position = Audio.stop_music()
		var music_position: float = 0
		options_menu.connect("tree_exiting", self, "_on_OptionsMenu_tree_exiting", [music_position])
		
		Events.emit_signal("game_paused")
		get_tree().paused = true


func _on_OptionsMenu_tree_exiting(music_position: float) -> void:
	var tree = get_tree()
	if tree:
		tree.paused = false
	#Audio.play_music(wav, music_position)
	Events.emit_signal("game_resumed")



func _on_GameOverMenu_tree_exiting() -> void:
	pass
	#var tree = get_tree()
	#if tree:
	#	tree.paused = false
	#Events.emit_signal("game_resumed")





func on_Dialog_timeline_end(timeline_name):
	yield(get_tree(), "idle_frame")
	get_tree().paused = false
	Events.emit_signal("game_resumed")
