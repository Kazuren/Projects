using Godot;
using System;

using System.Threading.Tasks;


public class ChatMessage : PanelContainer
{
  public string Id { get; set; }
  public string UserId { get; set; }
  public RichTextLabel Label { get; private set; }
  public Task PopulateTask { get; set; }

  public bool QueuedForDeletion { get; set; } = false;

  public override void _Ready()
  {
    Label = GetNode<RichTextLabel>("%Label");
  }

  public async void FreeWhenPossible()
  {
    QueuedForDeletion = true;

    if (PopulateTask != null && !PopulateTask.IsCompleted)
    {
      await PopulateTask;
    }
    QueueFree();
  }

  //  // Called every frame. 'delta' is the elapsed time since the previous frame.
  //  public override void _Process(float delta)
  //  {
  //      
  //  }
}
