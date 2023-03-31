using Godot;
using System;

public class SceneContainer : VBoxContainer
{
  public Button Button { get; set; }
  public TextureRect TextureRect { get; set; }
  public Label Label { get; set; }

  public string Path { get; set; }

  public override void _Ready()
  {
    Label = GetNode<Label>("%Label");
    Button = GetNode<Button>("%Button");
    TextureRect = GetNode<TextureRect>("%TextureRect");
  }

  public void Setup(string text, Texture texture, string path)
  {
    Label.Text = text;
    TextureRect.Texture = texture;
    Path = path;
  }

  //  // Called every frame. 'delta' is the elapsed time since the previous frame.
  //  public override void _Process(float delta)
  //  {
  //      
  //  }
}
