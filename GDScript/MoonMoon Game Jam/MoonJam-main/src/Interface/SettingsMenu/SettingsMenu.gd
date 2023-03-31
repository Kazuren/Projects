extends Control

onready var close_button: Button = $Menu/MarginContainer/VBoxContainer/HBoxContainer/CloseButton
#onready var exit_button: Button = $Settings/Background/MarginContainer/VBoxContainer/HBoxContainer2/ExitButton
#onready var restart_scene_button: Button = $Settings/Background/MarginContainer/VBoxContainer/HBoxContainer2/RestartSceneButton
onready var test_effects_button = $Menu/MarginContainer/VBoxContainer/EffectsVolumeContainer/HBoxContainer/TestEffectsButton

onready var fullscreen_btn = $Menu/MarginContainer/VBoxContainer/CheckboxContainer/FullScreenCheckbox
onready var vsync_btn = $Menu/MarginContainer/VBoxContainer/CheckboxContainer/VsyncCheckbox

onready var master_volume_slider = $Menu/MarginContainer/VBoxContainer/MasterVolumeContainer/SliderContainer/MasterSlider
onready var master_volume_value = $Menu/MarginContainer/VBoxContainer/MasterVolumeContainer/SliderContainer/MasterValue

onready var music_volume_slider = $Menu/MarginContainer/VBoxContainer/MusicVolumeContainer/SliderContainer/MusicSlider
onready var music_volume_value = $Menu/MarginContainer/VBoxContainer/MusicVolumeContainer/SliderContainer/MusicValue

onready var effects_volume_slider = $Menu/MarginContainer/VBoxContainer/EffectsVolumeContainer/SliderContainer/EffectsSlider
onready var effects_volume_value = $Menu/MarginContainer/VBoxContainer/EffectsVolumeContainer/SliderContainer/EffectsValue


var effects: Array = [
	preload("res://Assets/Audio/SFX/playerParry.wav"),
	preload("res://Assets/Audio/SFX/borpaBoost.wav")
]


func _ready() -> void:
	#if Globals.game_started:
	#	restart_scene_button.visible = true
	#if OS.has_feature('JavaScript'):
	#	exit_button.visible = false
	#	fullscreen_btn.visible = false
	#	vsync_btn.visible = false
	
	Settings.connect("fullscreen_changed", self, "_on_Settings_fullscreen_changed")
	
	#Events.emit_signal("game_paused")
	#pause_mode = PAUSE_MODE_PROCESS
	#get_tree().paused = true
	
	close_button.connect("pressed", self, "_on_CloseButton_pressed")
	test_effects_button.connect("pressed", self, "_on_TestEffectsButton_pressed")
	#exit_button.connect("pressed", self, "_on_ExitButton_pressed")
	#restart_scene_button.connect("pressed", self, "_on_RestartSceneButton_pressed")
	
	fullscreen_btn.pressed = Settings.settings.fullscreen
	vsync_btn.pressed = Settings.settings.vsync
	
	master_volume_slider.value = Settings.settings.master_volume
	music_volume_slider.value = Settings.settings.music_volume
	effects_volume_slider.value = Settings.settings.effects_volume
	
	master_volume_value.text = str(Settings.settings.master_volume) + "%"
	music_volume_value.text = str(Settings.settings.music_volume) + "%"
	effects_volume_value.text = str(Settings.settings.effects_volume) + "%"
	
	fullscreen_btn.connect("toggled", self, "_on_FullscreenButton_toggled")
	vsync_btn.connect("toggled", self, "_on_VsyncButton_toggled")
	
	master_volume_slider.connect("value_changed", self, "_on_MasterVolumeSlider_value_changed")
	music_volume_slider.connect("value_changed", self, "_on_MusicVolumeSlider_value_changed")
	effects_volume_slider.connect("value_changed", self, "_on_EffectsVolumeSlider_value_changed")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().set_input_as_handled()
		#get_tree().paused = false
		#Events.emit_signal("game_resumed")
		queue_free()


func _on_CloseButton_pressed() -> void:
	#get_tree().paused = false
	#Events.emit_signal("game_resumed")
	queue_free()


func _on_TestEffectsButton_pressed() -> void:
	var rand_index = Globals.RNG.randi_range(0, effects.size() - 1)
	var rand_effect = effects[rand_index]
	Audio.play_effect(rand_effect)


func _on_ExitButton_pressed() -> void:
	get_tree().quit()


#func _on_RestartSceneButton_pressed() -> void:
#	get_tree().reload_current_scene()


func _on_FullscreenButton_toggled(button_pressed: bool) -> void:
	Settings.toggle_fullscreen(button_pressed)
	Settings.save_settings()


func _on_Settings_fullscreen_changed(value: bool) -> void:
	fullscreen_btn.pressed = value


func _on_VsyncButton_toggled(button_pressed: bool) -> void:
	Settings.toggle_vsync(button_pressed)
	Settings.save_settings()


func _on_MasterVolumeSlider_value_changed(value: float) -> void:
	Settings.update_volume("Master", value)
	master_volume_value.text = str(value) + "%"
	Settings.save_settings()


func _on_MusicVolumeSlider_value_changed(value: float) -> void:
	Settings.update_volume("Music", value)
	music_volume_value.text = str(value) + "%"
	Settings.save_settings()


func _on_EffectsVolumeSlider_value_changed(value: float) -> void:
	Settings.update_volume("Effects", value)
	effects_volume_value.text = str(value) + "%"
	Settings.save_settings()

