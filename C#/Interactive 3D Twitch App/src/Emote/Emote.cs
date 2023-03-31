using Godot;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

public class Emote : Sprite3D
{
  private Twitch.Emote _twitchEmote;

  private AnimationPlayer _animationPlayer;

  private Camera _camera;

  private PackedScene _zeroWidthEmoteScene = ResourceLoader.Load<PackedScene>("res://src/Emote/ZeroWidthEmote.tscn");

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

  public override void _Ready()
  {
    _camera = GetViewport().GetCamera();
    _animationPlayer = GetNode<AnimationPlayer>("AnimationPlayer");
    _animationPlayer.Play("Walk");
  }

  public override void _Process(float delta)
  {
    if (TwitchEmote == null) { return; }
    Texture = TwitchEmote.GetTexture(3);
    SpatialMaterial material = (SpatialMaterial)MaterialOverride;
    material.AlbedoTexture = Texture;

    float yAngle = Mathf.LerpAngle(Rotation.y, Mathf.Atan2(_camera.GlobalTranslation.x - GlobalTranslation.x, _camera.GlobalTranslation.z - GlobalTranslation.z), 1);

    Rotation = new Vector3(
      Rotation.x,
      yAngle,
      Rotation.z
    );
  }

  public async Task AddZeroWidthEmote(Twitch.Emote twitchEmote)
  {
    // Get the emote texture
    ImageTexture emoteTexture = await twitchEmote.GetTextureAsync(3);

    // If the download failed, return
    if (emoteTexture == null) { return; }

    ZeroWidthEmote zeroWidthEmote = _zeroWidthEmoteScene.Instance<ZeroWidthEmote>();
    zeroWidthEmote.TwitchEmote = twitchEmote;

    // "Unscales" the zero width emote because it will have scaling applied to it by the root emote node.
    zeroWidthEmote.Scale = Vector3.One / Scale;

    Spatial zeroWidthEmotesContainer = GetNode<Spatial>("%ZeroWidthEmotes");
    zeroWidthEmotesContainer.AddChild(zeroWidthEmote);
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
