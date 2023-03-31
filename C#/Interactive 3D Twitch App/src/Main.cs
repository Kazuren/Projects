using Godot;
using System;
using System.Collections.Generic;
using System.Collections.Concurrent;
using System.Diagnostics;

using System.Linq;

using Game;


public class Main : Spatial
{
  //const int MaxEmotesOnScreen = 500;
  private Twitch.Client _twitchClient;
  private PackedScene _emoteScene = ResourceLoader.Load<PackedScene>("res://src/Emote/Emote.tscn");
  //private Godot.Path _path;

  //private EmotePathFollow[] _pathFollows = new EmotePathFollow[MaxEmotesOnScreen];
  //private Emote[] _emotes = new Emote[MaxEmotesOnScreen];

  //private Game.Path.Route[] _routes;

  private Random RNG = new Random();

  private PathManager PathManager;

  private PackedScene MainMenuScene = ResourceLoader.Load<PackedScene>("res://src/UI/MainMenu/MainMenu.tscn");
  private Control Interface;
  private Viewport TwitchChatViewport;

  private Scene3D Scene3D { get; set; }

  // private class PathData
  // {
  //   Game.Path Path { get; set; }

  // }

  public async void OnSceneLoaderSceneLoaded(PackedScene scene)
  {
    if (Scene3D != null)
    {
      Scene3D.QueueFree();
      await ToSignal(Scene3D, "tree_exited");
    }

    Scene3D = scene.Instance<Scene3D>();
    AddChild(Scene3D);
    Setup3DScene(Scene3D);
  }

  public override void _Ready()
  {
    Settings.Load();

    GetTree().Root.CallDeferred("add_child", Logger.Instance);

    PathManager = GetNode<PathManager>("%PathManager");
    Interface = GetNode<Control>("%Interface");
    TwitchChatViewport = GetNode<Viewport>("%TwitchChatViewport");
    TwitchChatViewport.GetTexture().Flags = (uint)(Texture.FlagsEnum.Filter | Texture.FlagsEnum.AnisotropicFilter | Texture.FlagsEnum.Mipmaps);
    _twitchClient = GetNode<Twitch.Client>("%TwitchClient");
    _twitchClient.Connect("MessageReceived", this, nameof(OnTwitchClientMessageReceived));

    SceneLoader sceneLoader = GetNode<SceneLoader>("/root/SceneLoader");
    sceneLoader.Connect("SceneLoaded", this, nameof(OnSceneLoaderSceneLoaded));
    sceneLoader.LoadScene(Settings.Scene3D.MainScene);
  }

  public override void _Notification(int what)
  {
    switch (what)
    {
      case NotificationCrash:
      case NotificationWmQuitRequest:
        GetTree().QueueDelete(GetTree());
        break;
    }
  }

  public void Setup3DScene(Scene3D scene)
  {
    SpatialMaterial mat = (SpatialMaterial)scene.TwitchChatQuad.GetSurfaceMaterial(0);
    mat.AlbedoTexture = TwitchChatViewport.GetTexture();
    mat.AlbedoTexture.Flags = (uint)(Texture.FlagsEnum.Filter | Texture.FlagsEnum.AnisotropicFilter | Texture.FlagsEnum.Mipmaps);

    PathManager.Setup(scene.PathRoot);
  }

  public override void _UnhandledInput(InputEvent @event)
  {
    if (@event is InputEventKey eventKey)
    {
      if (eventKey.Scancode == (int)KeyList.Escape && eventKey.Pressed && !eventKey.Echo)
      {
        Control mainMenu = MainMenuScene.Instance<Control>();

        Interface.AddChild(mainMenu);
      }
    }
  }

  private void OnTwitchClientMessageReceived(Twitch.ChatMessage message)
  {
    if (message.Emotes.Count == 0) { return; }

    if (message.Emotes.Count > 1)
    {
      int firstEmoteEndIndex = message.EmoteLocations[0][1];
      int secondEmoteStartIndex = message.EmoteLocations[1][0];

      // Checks for an adjacent zero width emote and spawns the emote with an extra zeroWidthEmote if there is one otherwise just spawns the first one.
      // +1 to account for space
      // +1 more to check if there is an emote right after the space
      if (message.Emotes[1].ZeroWidth && (firstEmoteEndIndex + 2) == secondEmoteStartIndex)
      {
        SpawnEmote(message.Emotes[0], message.Emotes[1]);
      }
      else
      {
        SpawnEmote(message.Emotes[0]);
      }
    }
    else
    {
      SpawnEmote(message.Emotes[0]);
    }
  }

  private Game.Path.Route ChooseFreeRoute(EmotePathFollow pathFollow)
  {
    // TODO find better way to shuffle because this is hideous
    RNG.Shuffle(PathManager.Routes);
    ConcurrentBag<Game.Path.Route> routes = new ConcurrentBag<Game.Path.Route>(PathManager.Routes);

    Game.Path.Route route;
    do
    {
      routes.TryTake(out route);
    }
    while (route != null && !PathManager.IsRouteValid(route, pathFollow));

    return route;
  }

  private async void SpawnEmote(Twitch.Emote twitchEmote, Twitch.Emote zeroWidthEmote = null)
  {
    // Get the emote texture
    ImageTexture emoteTexture = await twitchEmote.GetTextureAsync(3);

    // If the download failed, return
    if (emoteTexture == null) { return; }

    // Instance the required scenes
    Emote emote = _emoteScene.Instance<Emote>();
    EmotePathFollow pathFollow = new EmotePathFollow();

    // Set the emotes twitchEmote reference to the one that's being spawned
    emote.TwitchEmote = twitchEmote;

    if (zeroWidthEmote != null)
    {
      await emote.AddZeroWidthEmote(zeroWidthEmote);
    }

    //Game.Path path = GetNode<Game.Path>("%Path1");

    Game.Path.Route route = ChooseFreeRoute(pathFollow);
    if (route == null) { emote.QueueFree(); pathFollow.QueueFree(); return; }

    PathManager.RegisterRoute(route, pathFollow);

    pathFollow.AddChild(emote);
    pathFollow.SetRoute(route);

    // Set the emote position so it correctly stands on the path
    float yOffset = emoteTexture.GetHeight() / 2 * emote.PixelSize * twitchEmote.Scale;
    emote.Translation = new Vector3(0, yOffset, 0);

    await ToSignal(pathFollow, "PathEnded");

    //emote.TwitchEmote = null;
    emote.QueueFree();
    pathFollow.QueueFree();
  }
}
