using Godot;
using System;

public class SceneLoader : Node
{
  [Signal]
  delegate void SceneLoaded(PackedScene scene);

  private PackedScene sceneLoaderProgressScene = ResourceLoader.Load<PackedScene>("res://src/SceneLoader/SceneLoaderProgress.tscn");
  private ResourceInteractiveLoader loader;
  private SceneLoaderProgress sceneLoader;

  private int waitFrames = 1;
  private ulong timeMax = 10; // ms

  public override void _Ready()
  {

  }

  //  // Called every frame. 'delta' is the elapsed time since the previous frame.
  //  public override void _Process(float delta)
  //  {
  //      
  //  }

  public void LoadScene(string path)
  {
    loader = ResourceLoader.LoadInteractive(path);

    sceneLoader = sceneLoaderProgressScene.Instance<SceneLoaderProgress>();

    AddChild(sceneLoader);

    SetProcess(true);

    waitFrames = 1;
  }

  public override void _Process(float delta)
  {
    if (loader == null)
    {
      // no need to process anymore
      SetProcess(false);
      return;
    }

    // Wait for frames to let the "loading" scene to show up.
    if (waitFrames > 0)
    {
      waitFrames--;
      return;
    }

    ulong t = Time.GetTicksMsec();
    // Use "time_max" to control for how long we block this thread.
    while (OS.GetTicksMsec() < t + timeMax)
    {
      Error err = loader.Poll();

      if (err == Error.FileEof) // finished loading
      {
        Resource resource = loader.GetResource();
        sceneLoader.QueueFree();
        loader.Dispose();
        loader = null;
        sceneLoader = null;

        PackedScene scene = (PackedScene)resource;
        EmitSignal("SceneLoaded", scene);
        break;
      }
      else if (err == Error.Ok)
      {
        UpdateProgress();
      }
      else
      {
        Logger.Instance.Log(Logger.Levels.ERROR, "SceneLoader", err.ToString());
        loader = null;
        break;
      }
    }
  }

  public void UpdateProgress()
  {
    if (sceneLoader == null || loader == null) { return; }

    float progress = (float)loader.GetStage() / (float)loader.GetStageCount();

    sceneLoader.ProgressBar.Value = progress * 100;
  }
}