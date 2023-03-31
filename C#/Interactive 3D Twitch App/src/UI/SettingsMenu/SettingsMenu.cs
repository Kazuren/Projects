using Godot;
using System;

public class SettingsMenu : CenterContainer
{
  private OptionButton displayModeButton { get; set; }
  private OptionButton resolutionButton { get; set; }
  private Button vsyncButton { get; set; }
  private Button backButton { get; set; }

  public override void _Ready()
  {
    displayModeButton = GetNode<OptionButton>("%DisplayModeOptions");
    resolutionButton = GetNode<OptionButton>("%ResolutionOptions");
    vsyncButton = GetNode<Button>("%VsyncButton");
    backButton = GetNode<Button>("%BackButton");

    displayModeButton.AddItem("Fullscreen", (int)Settings.DisplayMode.Fullscreen);
    displayModeButton.AddItem("Borderless Windowed", (int)Settings.DisplayMode.BorderlessWindowed);
    displayModeButton.AddItem("Windowed", (int)Settings.DisplayMode.Windowed);

    for (int i = 0; i < Settings.ResolutionOptions.Length; i++)
    {
      Vector2 resolution = Settings.ResolutionOptions[i];
      resolutionButton.AddItem($"{resolution.x}x{resolution.y}", i);
    }

    displayModeButton.Connect("pressed", this, nameof(OnDisplayModeButtonPressed));
    displayModeButton.Connect("item_selected", this, nameof(OnDisplayModeButtonItemSelected));

    resolutionButton.Connect("pressed", this, nameof(OnResolutionButtonPressed));
    resolutionButton.Connect("item_selected", this, nameof(OnResolutionButtonItemSelected));

    vsyncButton.Connect("pressed", this, nameof(OnVsyncButtonPressed));
    backButton.Connect("pressed", this, nameof(OnBackButtonPressed));

    displayModeButton.Selected = displayModeButton.GetItemIndex((int)Settings.Video.DisplayMode);
    resolutionButton.Selected = Array.IndexOf(Settings.ResolutionOptions, Settings.Video.Resolution);
    vsyncButton.Text = Settings.Video.Vsync ? "ON" : "OFF";
  }

  public void OnDisplayModeButtonPressed()
  {
    PopupMenu popupMenu = displayModeButton.GetPopup();

    popupMenu.RectGlobalPosition = new Vector2(popupMenu.RectGlobalPosition.x, popupMenu.RectGlobalPosition.y + 16);
  }

  public void OnDisplayModeButtonItemSelected(int index)
  {
    int id = displayModeButton.GetItemId(index);

    Settings.Video.DisplayMode = (Settings.DisplayMode)id;
    Settings.Save();
  }

  public void OnResolutionButtonPressed()
  {
    PopupMenu popupMenu = resolutionButton.GetPopup();

    popupMenu.RectGlobalPosition = new Vector2(popupMenu.RectGlobalPosition.x, popupMenu.RectGlobalPosition.y + 16);
  }

  public void OnResolutionButtonItemSelected(int index)
  {
    int id = resolutionButton.GetItemId(index);

    Settings.Video.Resolution = Settings.ResolutionOptions[id];
    Settings.Save();
  }

  public void OnVsyncButtonPressed()
  {
    Settings.Video.Vsync = !Settings.Video.Vsync;
    vsyncButton.Text = Settings.Video.Vsync ? "ON" : "OFF";
    Settings.Save();
  }

  public void OnBackButtonPressed()
  {
    QueueFree();
  }

  //  // Called every frame. 'delta' is the elapsed time since the previous frame.
  //  public override void _Process(float delta)
  //  {
  //      
  //  }
}
