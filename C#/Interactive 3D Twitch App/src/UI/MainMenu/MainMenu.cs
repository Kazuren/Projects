using Godot;
using System;

public class MainMenu : CenterContainer
{
  private Panel menuPanel;
  private Button resumeButton;
  private Button switchSceneButton;
  private Button settingsButton;
  private Button quitButton;

  private PackedScene settingsMenuScene = ResourceLoader.Load<PackedScene>("res://src/UI/SettingsMenu/SettingsMenu.tscn");
  private PackedScene switchSceneMenuScene = ResourceLoader.Load<PackedScene>("res://src/UI/SwitchSceneMenu/SwitchSceneMenu.tscn");

  public override void _Ready()
  {
    menuPanel = GetNode<Panel>("%MenuPanel");

    resumeButton = GetNode<Button>("%ResumeButton");
    switchSceneButton = GetNode<Button>("%SwitchSceneButton");
    settingsButton = GetNode<Button>("%SettingsButton");
    quitButton = GetNode<Button>("%QuitButton");

    resumeButton.Connect("pressed", this, nameof(OnResumeButtonPressed));
    switchSceneButton.Connect("pressed", this, nameof(OnSwitchSceneButtonPressed));
    settingsButton.Connect("pressed", this, nameof(OnSettingsButtonPressed));
    quitButton.Connect("pressed", this, nameof(OnQuitButtonPressed));
  }

  public void OnResumeButtonPressed()
  {
    QueueFree();
  }

  public void OnSwitchSceneButtonPressed()
  {
    SwitchSceneMenu switchSceneMenu = switchSceneMenuScene.Instance<SwitchSceneMenu>();

    AddChild(switchSceneMenu);
    menuPanel.Visible = false;

    switchSceneMenu.Connect("SceneSelected", this, nameof(OnSwitchSceneMenuSceneSelected));
    switchSceneMenu.Connect("tree_exited", this, nameof(OnSwitchSceneMenuTreeExited));
  }

  public void OnSwitchSceneMenuSceneSelected()
  {
    QueueFree();
  }

  public void OnSwitchSceneMenuTreeExited()
  {
    menuPanel.Visible = true;
  }

  public async void OnSettingsButtonPressed()
  {
    Control settingsMenu = settingsMenuScene.Instance<Control>();
    AddChild(settingsMenu);
    menuPanel.Visible = false;

    await ToSignal(settingsMenu, "tree_exited");
    menuPanel.Visible = true;
  }

  public void OnQuitButtonPressed()
  {
    GetTree().Quit();
  }

  public override void _UnhandledInput(InputEvent @event)
  {
    if (!Visible) { return; }

    if (@event is InputEventKey eventKey)
    {
      if (eventKey.Scancode == (int)KeyList.Escape && eventKey.Pressed && !eventKey.Echo)
      {
        GetViewport().SetInputAsHandled();
        QueueFree();
      }
    }
  }
}
