using Godot;
using System;

namespace Twitch.Chat
{
  public class Emote : TextureRect
  {
    private Twitch.Emote _twitchEmote;

    public Twitch.Emote TwitchEmote
    {
      get => _twitchEmote;
      set
      {
        if (_twitchEmote != null) { _twitchEmote.References--; }
        _twitchEmote = value;
        if (_twitchEmote == null) { Texture = null; return; }
        _twitchEmote.References++;
      }
    }
    public override void _Ready()
    {

    }

    public override void _Process(float delta)
    {
      if (TwitchEmote == null) { return; }
      Texture = TwitchEmote.GetTexture2D(1);
    }

    public override void _ExitTree()
    {
      TwitchEmote = null;
    }
  }
}
