extends Node

signal volume_changed(bus_name, value)

const PATH = "user://settings.save"

var settings = {
	"fullscreen": true,
	"vsync": true,
	"master_volume": 50,
	"music_volume": 50,
	"effects_volume": 50,
}


func _ready() -> void:
	load_settings()


func toggle_fullscreen(value: bool) -> void:
	if OS.has_feature('JavaScript'):
		return
	OS.window_fullscreen = value
	settings.fullscreen = value


func toggle_vsync(value: bool) -> void:
	if OS.has_feature('JavaScript'):
		return
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
			"vsync": true,
			"master_volume": 50,
			"music_volume": 50,
			"effects_volume": 50,
		}
		save_settings()
	file.open(PATH, File.READ)
	settings = file.get_var()
	file.close()
	
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
