using Godot;
using System;
using System.Globalization;

public sealed class Logger : Node
{
  public enum Levels
  {
    VERBOSE,
    DEBUG,
    INFO,
    WARN,
    ERROR
  }


  private static readonly Logger instance = new Logger();
  static Logger()
  {

  }
  private Logger()
  {

  }
  public static Logger Instance
  {
    get => instance;
  }


  public void Log(Levels level, string module, string message)
  {
    DateTime utcDate = DateTime.UtcNow;
    long frame = IsInsideTree() ? GetTree().GetFrame() : 0;

    switch (level)
    {
      case Levels.WARN:
        GD.PushWarning($"[{frame}] [UTC {utcDate.ToString("dd/MM/yyyy hh:mm:ss.fff tt")}] [{level}] [{module}]: {message}");
        break;
      case Levels.ERROR:
        GD.PushError($"[{frame}] [UTC {utcDate.ToString("dd/MM/yyyy hh:mm:ss.fff tt")}] [{level}] [{module}]: {message}");
        break;
      default:
        GD.Print($"[{frame}] [UTC {utcDate.ToString("dd/MM/yyyy hh:mm:ss.fff tt")}] [{level}] [{module}]: {message}");
        break;
    }
  }
}
