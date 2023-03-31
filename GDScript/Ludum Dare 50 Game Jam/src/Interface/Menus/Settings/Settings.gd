extends CanvasLayer

onready var close_button: Button = $Settings/Background/MarginContainer/VBoxContainer/HBoxContainer2/CloseButton
onready var exit_button: Button = $Settings/Background/MarginContainer/VBoxContainer/HBoxContainer2/ExitButton
onready var restart_scene_button: Button = $Settings/Background/MarginContainer/VBoxContainer/HBoxContainer2/RestartSceneButton

onready var fullscreen_btn = $Settings/Background/MarginContainer/VBoxContainer/HBoxContainer/FullscreenCheckbox
onready var vsync_btn = $Settings/Background/MarginContainer/VBoxContainer/HBoxContainer/VsyncCheckbox

onready var master_volume_slider = $Settings/Background/MarginContainer/VBoxContainer/MasterVolumeContainer/HBoxContainer/MasterSlider
onready var master_volume_value = $Settings/Background/MarginContainer/VBoxContainer/MasterVolumeContainer/HBoxContainer/MasterValue

onready var music_volume_slider = $Settings/Background/MarginContainer/VBoxContainer/MusicVolumeContainer/HBoxContainer/MusicSlider
onready var music_volume_value = $Settings/Background/MarginContainer/VBoxContainer/MusicVolumeContainer/HBoxContainer/MusicValue

onready var effects_volume_slider = $Settings/Background/MarginContainer/VBoxContainer/EffectsVolumeContainer/HBoxContainer/EffectsSlider
onready var effects_volume_value = $Settings/Background/MarginContainer/VBoxContainer/EffectsVolumeContainer/HBoxContainer/EffectsValue


func _ready() -> void:
	if Globals.game_started:
		restart_scene_button.visible = true
	if OS.has_feature('JavaScript'):
		exit_button.visible = false
		fullscreen_btn.visible = false
		vsync_btn.visible = false
	
	Events.emit_signal("game_paused")
	get_tree().paused = true
	
	close_button.connect("pressed", self, "_on_CloseButton_pressed")
	exit_button.connect("pressed", self, "_on_ExitButton_pressed")
	restart_scene_button.connect("pressed", self, "_on_RestartSceneButton_pressed")
	
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
	if event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		get_tree().paused = false
		Events.emit_signal("game_resumed")
		queue_free()


func _on_CloseButton_pressed() -> void:
	get_tree().paused = false
	Events.emit_signal("game_resumed")
	queue_free()


func _on_ExitButton_pressed() -> void:
	get_tree().quit()


func _on_RestartSceneButton_pressed() -> void:
	get_tree().reload_current_scene()


func _on_FullscreenButton_toggled(button_pressed: bool) -> void:
	Settings.toggle_fullscreen(button_pressed)
	Settings.save_settings()


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

