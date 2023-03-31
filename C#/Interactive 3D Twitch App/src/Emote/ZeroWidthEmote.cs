using Godot;
using System;

public class ZeroWidthEmote : Sprite3D
{
  public Twitch.Emote TwitchEmote
  {
    get => _twitchEmote;
    set
    {
      if (_twitchEmote != null) { _twitchEmote.References--; }
      _twitchEmote = value;
      if (_twitchEmote == null) { Texture = null; return; }
      _twitchEmote.References++;
      //Texture = _twitchEmote.GetTexture();
      Scale = new Vector3(_twitchEmote.Scale, _twitchEmote.Scale, 1);
    }
  }

  private Twitch.Emote _twitchEmote;

  public override void _Ready()
  {

  }

  public override void _Process(float delta)
  {
    if (TwitchEmote == null) { return; }
    Texture = TwitchEmote.GetTexture(3);
    SpatialMaterial material = (SpatialMaterial)MaterialOverride;
    material.AlbedoTexture = Texture;
  }

  public override void _Notification(int what)
  {
    switch (what)
    {
      case NotificationPredelete:
        TwitchEmote = null;
        break;
    }
    base._Notification(what);
  }
}
