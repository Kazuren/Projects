class_name Boss
extends Level

export(AudioStream) var moonboss_intro


onready var boss_entity = $Paths/TopBottomRightSidePath/PathFollow2D/Moon

onready var top_bottom_left_side_path = $Paths/TopBottomLeftSidePath
onready var top_bottom_right_side_path = $Paths/TopBottomRightSidePath
onready var top_horizontal_path = $Paths/TopHorizontalPath
onready var bottom_horizontal_path = $Paths/BottomHorizontalPath

onready var state_machine = $StateMachine



onready var tentacle_positions = $TentaclePositions


onready var current_path = top_bottom_right_side_path
onready var boss_path = $Paths/TopBottomRightSidePath/PathFollow2D

var current_sfx = null
#onready var tilemap = $TileMap
#onready var camera = $Player/Camera2D


func _ready() -> void:
	Globals.space_level = true
	if is_instance_valid(boss_entity):
		if boss_entity.global_position.x >= 1920 / 2:
			if boss_entity.pivot.scale.x == 1:
				boss_entity.pivot.scale.x *= -1
		elif boss_entity.global_position.x < 1920 / 2:
			if boss_entity.pivot.scale.x == -1:
				boss_entity.pivot.scale.x *= -1
	
	
	if !Globals.from_retry:
#		Globals.progress = 2
#		Globals.save_data()
		var player = Audio.play_music(moonboss_intro)
		player.connect("finished", self, "_on_AudioPlayer_finished", [], CONNECT_ONESHOT)
		var dialog = Dialogic.start("BossFightStart")
		dialog.pause_mode = Node.PAUSE_MODE_PROCESS
		dialog.connect("timeline_end", self, "on_Dialog_timeline_end")
		add_child(dialog)
		get_tree().paused = true
	else:
		state_machine.change("ChoosingAttack")
	
	#Audio.play_music(music)
	
	
	
	add_to_group("enemies")
	boss_entity.connect("death", self, "_on_boss_dead")


func _on_AudioPlayer_finished() -> void:
	Audio.play_music(music)


func add_to_path() -> void:
	pass


func _on_boss_dead() -> void:
	if current_sfx:
		current_sfx.stop()
	disable()
	if !player.dead:
		var timer = player.get_tree().create_timer(0.5, true)
		timer.connect("timeout", self, "_on_boss_died_timer_timeout", [], CONNECT_ONESHOT)



func _on_boss_died_timer_timeout():
	_on_Level_finished()


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and is_instance_valid(boss_entity) and (!player.dead and !boss_entity.dead):
		var options_menu = OptionsMenu.instance()
		Interface.add_child(options_menu)
		#var music_position = Audio.stop_music()
		var music_position: float = 0.0
		options_menu.connect("tree_exiting", self, "_on_OptionsMenu_tree_exiting", [music_position])
		
		Events.emit_signal("game_paused")
		get_tree().paused = true


func _on_Player_death() -> void:
	get_tree().call_group("enemies", "disable_ai")
	
	yield(get_tree().create_timer(1), "timeout")
	var game_over_menu = GameOverMenu.instance()
	Interface.add_child(game_over_menu)
	Audio.stop_music()
	Globals.from_retry = true
	#Audio.start_death_music
	game_over_menu.connect("tree_exiting", self, "_on_GameOverMenu_tree_exiting")
	
	if is_instance_valid(boss_entity):
		var percent = float(boss_entity.health) / float(boss_entity.max_health) * 100
		game_over_menu.init(percent)
	#Events.emit_signal("game_paused")
	#get_tree().paused = true


func _on_VictoryMenu_continue_pressed(victory_menu) -> void:
	get_tree().paused = false
	victory_menu.queue_free()
	queue_free()
	get_tree().change_scene("res://src/Scenes/Level 5/Outro/Outro.tscn")


func _on_OptionsMenu_tree_exiting(music_position: float) -> void:
	var tree = get_tree()
	if tree:
		tree.paused = false
	#Audio.play_music(wav, music_position)
	Events.emit_signal("game_resumed")


func _process(delta: float) -> void:
	if is_instance_valid(boss_entity):
		if boss_entity.global_position.x >= 1920 / 2:
			if boss_entity.pivot.scale.x == 1:
				boss_entity.pivot.scale.x *= -1
		elif boss_entity.global_position.x < 1920 / 2:
			if boss_entity.pivot.scale.x == -1:
				boss_entity.pivot.scale.x *= -1
	else:
		disable()


# for player special
func enable() -> void:
	state_machine.set_process(true)
	state_machine.set_physics_process(true)
	$StateMachine/TentacleAttack/Tween.resume_all()


func disable() -> void:
	state_machine.set_process(false)
	state_machine.set_physics_process(false)
	$StateMachine/TentacleAttack/Tween.stop_all()


func on_Dialog_timeline_end(timeline_name):
	state_machine.change("ChoosingAttack")
	yield(get_tree(), "idle_frame")
	get_tree().paused = false
	enable()
	Events.emit_signal("game_resumed")


func _exit_tree() -> void:
	Globals.space_level = false
