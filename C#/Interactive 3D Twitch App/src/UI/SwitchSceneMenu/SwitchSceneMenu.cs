using Godot;
using System;


// todo signal if we are about to load a scene so main menu can close itself
public class SwitchSceneMenu : CenterContainer
{
  [Signal]
  delegate void SceneSelected();

  public string[,] Scenes { get; } = new string[2, 3]
  {
    { "res://Lollus Stuff/src/Shed modified.tscn", "res://Lollus Stuff/src/Shed.png", "Shed" },
    { "res://Lollus Stuff/Halloween/Halloween.tscn", "res://Lollus Stuff/Halloween/HalloweenShed.png", "Halloween Shed"},
  };

  private PackedScene sceneContainerScene = ResourceLoader.Load<PackedScene>("res://src/UI/SwitchSceneMenu/SceneContainer/SceneContainer.tscn");

  private GridContainer scenes;

  private Button backButton;

  public override void _Ready()
  {
    scenes = GetNode<GridContainer>("%Scenes");
    backButton = GetNode<Button>("%BackButton");
    backButton.Connect("pressed", this, nameof(OnBackButtonPressed));

    for (int i = 0; i < Scenes.GetLength(0); i++)
    {
      string scenePath = Scenes[i, 0];
      string texturePath = Scenes[i, 1];
      string name = Scenes[i, 2];

      Texture texture = ResourceLoader.Load<Texture>(texturePath);

      SceneContainer sceneContainer = sceneContainerScene.Instance<SceneContainer>();
      scenes.AddChild(sceneContainer);
      sceneContainer.Setup(name, texture, scenePath);
      sceneContainer.Button.Connect("pressed", this, nameof(OnSceneButtonPressed), new Godot.Collections.Array { scenePath });
    }
  }

  public void OnSceneButtonPressed(string scenePath)
  {
    EmitSignal(nameof(SceneSelected));
    QueueFree();

    SceneLoader sceneLoader = GetNode<SceneLoader>("/root/SceneLoader");
    sceneLoader.LoadScene(scenePath);
    Settings.Scene3D.MainScene = scenePath;
    Settings.Save();
  }

  public void OnBackButtonPressed()
  {
    QueueFree();
  }
}
