extends Node

signal volume_changed(bus_name, value)
signal fullscreen_changed(value)

const PATH = "user://settings.save"

var settings = {
	"fullscreen": true,
	"vsync": false,
	"master_volume": 50,
	"music_volume": 50,
	"effects_volume": 50,
}


func _ready() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
	load_settings()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		toggle_fullscreen(!OS.window_fullscreen)


func update_progress(value: int) -> void:
	if settings.progress < value:
		settings.progress = value
		save_settings()


func toggle_fullscreen(value: bool) -> void:
	#if OS.has_feature('JavaScript'):
	#	return
	OS.window_fullscreen = value
	settings.fullscreen = value
	emit_signal("fullscreen_changed", value)


func toggle_vsync(value: bool) -> void:
	#if OS.has_feature('JavaScript'):
	#	return
	OS.vsync_enabled = value
	settings.vsync = value


func update_volume(bus_name: String, volume: float) -> void:
	var clamped_volume = clamp(volume, 0, 100)
	var dB = linear2db(clamped_volume / 100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), dB)
	if bus_name == "Master":
		settings.master_volume = clamped_volume
	elif bus_name == "Music":
		settings.music_volume = clamped_volume
	elif bus_name == "Effects":
		settings.effects_volume = clamped_volume
	emit_signal("volume_changed", bus_name, clamped_volume)


func load_settings() -> void:
	var file = File.new()
	if not file.file_exists(PATH):
		settings = {
			"fullscreen": true,
			"vsync": false,
			"master_volume": 50,
			"music_volume": 50,
			"effects_volume": 50,
		}
		save_settings()
	
	file.open(PATH, File.READ)
	settings = file.get_var()
	file.close()
	
	settings.fullscreen = settings.fullscreen if settings.has("fullscreen") else true
	settings.vsync = settings.vsync if settings.has("vsync") else false
	settings.master_volume = settings.master_volume if settings.has("master_volume") else 50
	settings.music_volume = settings.music_volume if settings.has("music_volume") else 50
	settings.effects_volume = settings.effects_volume if settings.has("effects_volume") else 50
	
	toggle_fullscreen(settings.fullscreen)
	toggle_vsync(settings.vsync)
	update_volume("Master", settings.master_volume)
	update_volume("Music", settings.music_volume)
	update_volume("Effects", settings.effects_volume)


func save_settings() -> void:
	var file = File.new()
	file.open(PATH, File.WRITE)
	file.store_var(settings)
	file.close()
