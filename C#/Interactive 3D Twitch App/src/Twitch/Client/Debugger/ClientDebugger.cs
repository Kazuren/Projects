using Godot;
using System.Collections.Generic;
using System;

using System.Linq;
using Twitch;

namespace Twitch.ClientDebugger
{
  public class ClientDebugger : Control
  {
    [Export]
    private NodePath _twitchClientPath;

    private Twitch.Client _twitchClient;

    private Label _connectedChannelLabel;
    private Label _connectionStatusLabel;
    private Label _emoteReloadTimerTimeRemainingLabel;

    private PackedScene _emoteScene = (PackedScene)ResourceLoader.Load("res://src/Twitch/Client/Debugger/Emote/Emote.tscn");

    private GridContainer _emoteContainer;
    private GridContainer _temporaryEmoteContainer;
    private TabContainer _tabContainer;

    private Dictionary<string, Emote> _emotes = new Dictionary<string, Emote>();
    private Dictionary<string, Emote> _temporaryEmotes = new Dictionary<string, Emote>();

    public override void _Ready()
    {
      _twitchClient = GetNode<Twitch.Client>(_twitchClientPath);

      _connectedChannelLabel = GetNode<Label>("%ConnectedChannelLabel");
      _connectionStatusLabel = GetNode<Label>("%ConnectionStatusLabel");
      _emoteReloadTimerTimeRemainingLabel = GetNode<Label>("%EmoteReloadTimerTimeRemainingLabel");

      _emoteContainer = GetNode<GridContainer>("%Emotes");
      _temporaryEmoteContainer = GetNode<GridContainer>("%Temporary Emotes");
      _tabContainer = GetNode<TabContainer>("%TabContainer");
      SetProcess(false);
    }

    public override void _Process(float delta)
    {
      _connectedChannelLabel.Text = $"Channel: {_twitchClient.Channel}";
      _connectionStatusLabel.Text = $"Status: {_twitchClient.WebSocketConnectionStatus}";

      double timeRemaining = _twitchClient.EmoteReloadTimerInterval / 1000 - _twitchClient.EmoteReloadTimerTimeRemaining.TotalSeconds;
      _emoteReloadTimerTimeRemainingLabel.Text = $"Emotes refresh in: {timeRemaining.ToString("0")}s";

      KeyValuePair<string, Twitch.Emote>[] twitchEmotes = _twitchClient.Emotes;
      KeyValuePair<string, Twitch.Emote>[] twitchTemporaryEmotes = _twitchClient.TemporaryEmotes;

      UpdateEmotes(twitchEmotes, _emotes, _emoteContainer);
      UpdateEmotes(twitchTemporaryEmotes, _temporaryEmotes, _temporaryEmoteContainer);

      int downloadedEmoteCount = twitchEmotes.Count(emotePair => emotePair.Value.Texture != null);
      int downloadedTemporaryEmoteCount = twitchTemporaryEmotes.Count(emotePair => emotePair.Value.Texture != null);

      _tabContainer.SetTabTitle(0, $"Emotes ({downloadedEmoteCount}/{twitchEmotes.Length})");
      _tabContainer.SetTabTitle(1, $"Temporary Emotes ({downloadedTemporaryEmoteCount}/{twitchTemporaryEmotes.Length})");
    }

    public override void _Input(InputEvent @event)
    {
      if (@event is InputEventKey eventKey)
      {
        if (eventKey.Scancode == (int)KeyList.F12 && eventKey.Pressed && !eventKey.Echo)
        {
          Visible = !Visible;
          SetProcess(Visible);
          _emotes.Clear();
          _temporaryEmotes.Clear();
          foreach (Node child in _emoteContainer.GetChildren())
          {
            child.QueueFree();
          }
          foreach (Node child in _temporaryEmoteContainer.GetChildren())
          {
            child.QueueFree();
          }
        }
      }
    }

    private void UpdateEmotes(KeyValuePair<string, Twitch.Emote>[] twitchEmoteArray, Dictionary<string, Emote> emoteDictionary, GridContainer container)
    {

      //List<string> emotesToRemove = new List<string>();

      // Find and queue free any emotes that are not saved in the twitch client anymore
      List<string> emotesToRemove = emoteDictionary
        .Where(emotePair => !Array.Exists(twitchEmoteArray, twitchEmotePair => twitchEmotePair.Key == emotePair.Key)) //.All(twitchEmotePair => twitchEmotePair.Key != emotePair.Key)
        .Select(emotePair => emotePair.Key).ToList();

      /*
      
      foreach (KeyValuePair<string, Emote> emotePair in emoteDictionary)
      {
        bool found = false;
        foreach (KeyValuePair<string, Twitch.Emote> twitchEmotePair in twitchEmoteArray)
        {
          if (emoteDictionary.ContainsKey(twitchEmotePair.Key))
          {
            found = true;
            break;
          }
        }

        if (!found)
        {
          emotesToRemove.Add(emotePair.Key);
        }
      }
      */

      foreach (string emote in emotesToRemove)
      {
        emoteDictionary[emote].QueueFree();
        emoteDictionary.Remove(emote);
      }

      // Add any new emotes to the debugger that haven't been added yet
      foreach (KeyValuePair<string, Twitch.Emote> twitchEmotePair in twitchEmoteArray)
      {
        if (!emoteDictionary.ContainsKey(twitchEmotePair.Key))
        {
          Emote emote = _emoteScene.Instance<Emote>();
          container.AddChild(emote);
          emoteDictionary.Add(twitchEmotePair.Key, emote);
          emote.TwitchEmote = twitchEmotePair.Value;
        }
      }
    }
  }
}
