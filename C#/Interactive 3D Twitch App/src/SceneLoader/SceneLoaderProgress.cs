using Godot;
using System;
// TODO make this eat input so we can't press esc and shit to open up menues
public class SceneLoaderProgress : CenterContainer
{
  public ProgressBar ProgressBar { get; set; }
  public override void _Ready()
  {
    ProgressBar = GetNode<ProgressBar>("%ProgressBar");
  }

  public override void _UnhandledInput(InputEvent @event)
  {
    GetViewport().SetInputAsHandled();
  }

  //  // Called every frame. 'delta' is the elapsed time since the previous frame.
  //  public override void _Process(float delta)
  //  {
  //      
  //  }
}
