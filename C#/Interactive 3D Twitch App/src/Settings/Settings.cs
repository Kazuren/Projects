using Godot;
using System;
using System.IO;

public static class Settings
{
  public const string Path = "./settings.cfg";
  public const string ProjectSettingsPath = "./override.cfg";

  private static ConfigFile ConfigFile { get; } = new ConfigFile();
  private static ConfigFile ProjectSettingsConfigFile { get; } = new ConfigFile();

  public enum DisplayMode
  {
    Fullscreen,
    BorderlessWindowed,
    Windowed
  }

  public static Vector2[] ResolutionOptions = new Vector2[]
  {
    new Vector2(640, 360),
    new Vector2(1280, 720),
    new Vector2(1920, 1080),
    new Vector2(2560, 1440),
    new Vector2(3840, 2160)
  };

  public static class Video
  {
    public static DisplayMode DisplayMode
    {
      get => _displayMode;
      set { SetDisplayMode(value); }
    }
    public static bool Vsync
    {
      get => _vsync;
      set { SetVsync(value); }
    }

    public static Vector2 Resolution
    {
      get => _resolution;
      set { SetResolution(value); }
    }

    private static DisplayMode _displayMode = DisplayMode.Fullscreen;
    private static bool _vsync = false;
    private static Vector2 _resolution = OS.GetScreenSize();


    private static void SetDisplayMode(DisplayMode value)
    {
      _displayMode = value;

      switch (value)
      {
        case DisplayMode.Fullscreen:
          OS.WindowFullscreen = true;
          ProjectSettingsConfigFile.SetValue("display", "window/size/fullscreen", true);
          break;
        case DisplayMode.BorderlessWindowed:
          OS.WindowFullscreen = false;
          OS.WindowBorderless = true;
          OS.WindowMaximized = true;
          ProjectSettingsConfigFile.SetValue("display", "window/size/borderless", true);
          ProjectSettingsConfigFile.SetValue("display", "window/size/fullscreen", false);

          //OS.WindowSize = OS.GetScreenSize();
          //OS.WindowPosition = Vector2.Zero;
          break;
        case DisplayMode.Windowed:
          OS.WindowFullscreen = false;
          OS.WindowBorderless = false;
          OS.WindowMaximized = false;
          OS.WindowSize = Video.Resolution;
          ProjectSettingsConfigFile.SetValue("display", "window/size/borderless", false);
          ProjectSettingsConfigFile.SetValue("display", "window/size/fullscreen", false);
          break;
        default:
          break;
      }

      ConfigFile.SetValue("Video", "Display Mode", value);
    }

    private static void SetVsync(bool value)
    {
      _vsync = value;

      OS.VsyncEnabled = _vsync;
      ProjectSettingsConfigFile.SetValue("display", "window/vsync/use_vsync", _vsync);
      ConfigFile.SetValue("Video", "Vsync", value);
    }

    private static void SetResolution(Vector2 value)
    {
      _resolution = value;

      Vector2 screenSize = OS.GetScreenSize();
      int clampedX = (int)Mathf.Clamp(value.x, 0, screenSize.x);
      int clampedY = (int)Mathf.Clamp(value.y, 0, screenSize.y);

      OS.WindowMaximized = Video.DisplayMode == DisplayMode.Windowed ? false : true;
      OS.WindowSize = Video.DisplayMode == DisplayMode.Windowed ? new Vector2(clampedX, clampedY) : screenSize;

      ConfigFile.SetValue("Video", "Resolution", value);
      ProjectSettingsConfigFile.SetValue("display", "window/size/test_width", value.x);
      ProjectSettingsConfigFile.SetValue("display", "window/size/test_height", value.y);
    }
  }

  public static class Scene3D
  {
    public static string MainScene
    {
      get => _mainScene;
      set { SetMainScene(value); }
    }

    private static string _mainScene = "res://Lollus Stuff/src/Shed modified.tscn";

    private static void SetMainScene(string value)
    {
      _mainScene = value;
      ConfigFile.SetValue("Scene3D", "Main Scene", value);
      Save();
    }
  }

  //public static VideoSettings Video { get; private set; } = new VideoSettings();

  // OS.set_borderless_window(true)
  // OS.set_window_size(OS.get_screen_size())
  // OS.set_window_position(Vector2(0, 0))

  public static void Load()
  {
    bool fileExists = System.IO.File.Exists(Path);
    bool projectSettingsFileExists = System.IO.File.Exists(ProjectSettingsPath);

    if (fileExists)
    {
      ConfigFile.Load(Path);
    }

    if (projectSettingsFileExists)
    {
      ProjectSettingsConfigFile.Load(ProjectSettingsPath);
    }

    Video.DisplayMode = (DisplayMode)ConfigFile.GetValue("Video", "Display Mode", DisplayMode.Fullscreen);
    Video.Vsync = (bool)ConfigFile.GetValue("Video", "Vsync", false);
    Video.Resolution = (Vector2)ConfigFile.GetValue("Video", "Resolution", OS.GetScreenSize());

    Scene3D.MainScene = (string)ConfigFile.GetValue("Scene3D", "Main Scene", "res://Lollus Stuff/src/Shed modified.tscn");
    Save();
  }

  public static void Save()
  {
    ConfigFile.Save(Path);
    ProjectSettingsConfigFile.Save(ProjectSettingsPath);
  }
}






// func load_settings() -> void:
// 	var file = File.new()
// 	if not file.file_exists(PATH):
// 		settings = {
// 			"fullscreen": true,
// 			"vsync": false,
// 			"master_volume": 50,
// 			"music_volume": 50,
// 			"effects_volume": 50,
// 		}
// 		save_settings()

// 	file.open(PATH, File.READ)
// 	settings = file.get_var()
// 	file.close()

// 	settings.fullscreen = settings.fullscreen if settings.has("fullscreen") else true
// 	settings.vsync = settings.vsync if settings.has("vsync") else false
// 	settings.master_volume = settings.master_volume if settings.has("master_volume") else 50
// 	settings.music_volume = settings.music_volume if settings.has("music_volume") else 50
// 	settings.effects_volume = settings.effects_volume if settings.has("effects_volume") else 50

// 	toggle_fullscreen(settings.fullscreen)
// 	toggle_vsync(settings.vsync)
// 	update_volume("Master", settings.master_volume)
// 	update_volume("Music", settings.music_volume)
// 	update_volume("Effects", settings.effects_volume)

// extends Node

// signal volume_changed(bus_name, value)
// signal fullscreen_changed(value)

// const PATH = "user://settings.save"

// var settings = {
// 	"fullscreen": true,
// 	"vsync": false,
// 	"master_volume": 50,
// 	"music_volume": 50,
// 	"effects_volume": 50,
// }


// func _ready() -> void:
// 	pause_mode = Node.PAUSE_MODE_PROCESS
// 	load_settings()


// func _input(event: InputEvent) -> void:
// 	if event.is_action_pressed("toggle_fullscreen"):
// 		toggle_fullscreen(!OS.window_fullscreen)


// func update_progress(value: int) -> void:
// 	if settings.progress < value:
// 		settings.progress = value
// 		save_settings()


// func toggle_fullscreen(value: bool) -> void:
// 	#if OS.has_feature('JavaScript'):
// 	#	return
// 	OS.window_fullscreen = value
// 	settings.fullscreen = value
// 	emit_signal("fullscreen_changed", value)


// func toggle_vsync(value: bool) -> void:
// 	#if OS.has_feature('JavaScript'):
// 	#	return
// 	OS.vsync_enabled = value
// 	settings.vsync = value


// func update_volume(bus_name: String, volume: float) -> void:
// 	var clamped_volume = clamp(volume, 0, 100)
// 	var dB = linear2db(clamped_volume / 100)
// 	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), dB)
// 	if bus_name == "Master":
// 		settings.master_volume = clamped_volume
// 	elif bus_name == "Music":
// 		settings.music_volume = clamped_volume
// 	elif bus_name == "Effects":
// 		settings.effects_volume = clamped_volume
// 	emit_signal("volume_changed", bus_name, clamped_volume)


// func load_settings() -> void:
// 	var file = File.new()
// 	if not file.file_exists(PATH):
// 		settings = {
// 			"fullscreen": true,
// 			"vsync": false,
// 			"master_volume": 50,
// 			"music_volume": 50,
// 			"effects_volume": 50,
// 		}
// 		save_settings()

// 	file.open(PATH, File.READ)
// 	settings = file.get_var()
// 	file.close()

// 	settings.fullscreen = settings.fullscreen if settings.has("fullscreen") else true
// 	settings.vsync = settings.vsync if settings.has("vsync") else false
// 	settings.master_volume = settings.master_volume if settings.has("master_volume") else 50
// 	settings.music_volume = settings.music_volume if settings.has("music_volume") else 50
// 	settings.effects_volume = settings.effects_volume if settings.has("effects_volume") else 50

// 	toggle_fullscreen(settings.fullscreen)
// 	toggle_vsync(settings.vsync)
// 	update_volume("Master", settings.master_volume)
// 	update_volume("Music", settings.music_volume)
// 	update_volume("Effects", settings.effects_volume)


// func save_settings() -> void:
// 	var file = File.new()
// 	file.open(PATH, File.WRITE)
// 	file.store_var(settings)
// 	file.close()
