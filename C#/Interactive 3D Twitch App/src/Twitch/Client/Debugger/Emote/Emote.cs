using Godot;
using System;

namespace Twitch.ClientDebugger
{
  public class Emote : Panel
  {
    public Texture defaultTexture = ResourceLoader.Load<Texture>("res://src/Twitch/Client/Debugger/Emote/Textures/questionmark.png");

    public Twitch.Emote TwitchEmote
    {
      get => _twitchEmote;
      set
      {
        _twitchEmote = value;
        _textureRect.Texture = TwitchEmote.Texture2D != null ? TwitchEmote.Texture2D : defaultTexture;
        _nameLabel.Text = _twitchEmote.Code;
        _providerLabel.Text = _twitchEmote.Provider.ToString();
      }
    }

    private Twitch.Emote _twitchEmote;

    private TextureRect _textureRect;
    private Label _nameLabel;
    private Label _providerLabel;
    private Label _referencesLabel;
    private Label _framesLabel;
    private Label _currentFrameLabel;
    private Label _lengthLabel;
    private Label _currentTimeLabel;

    public override void _Ready()
    {
      _textureRect = GetNode<TextureRect>("%TextureRect");
      _textureRect.Texture = defaultTexture;

      _nameLabel = GetNode<Label>("%Name");
      _providerLabel = GetNode<Label>("%Provider");
      _referencesLabel = GetNode<Label>("%References");
      _framesLabel = GetNode<Label>("%Frames");
      _currentFrameLabel = GetNode<Label>("%CurrentFrame");
      _lengthLabel = GetNode<Label>("%Length");
      _currentTimeLabel = GetNode<Label>("%CurrentTime");
    }

    public override void _Process(float delta)
    {
      _textureRect.Texture = TwitchEmote.Texture2D != null ? TwitchEmote.Texture2D : defaultTexture;
      _providerLabel.Text = $"Provider: {TwitchEmote.Provider}";
      _referencesLabel.Text = $"References: {TwitchEmote.References}";
      _framesLabel.Text = $"Frames: {TwitchEmote.Frames[0]}|{TwitchEmote.Frames[1]}|{TwitchEmote.Frames[2]}";
      _currentFrameLabel.Text = $"Current Frame: {TwitchEmote.GetCurrentFrame(1)}|{TwitchEmote.GetCurrentFrame(2)}|{TwitchEmote.GetCurrentFrame(3)}";
      _lengthLabel.Text = $"Length (s): {TwitchEmote.TotalAnimationTime.ToString("0.000")}";
      _currentTimeLabel.Text = $"Current Time (s): {TwitchEmote.AnimationTime.ToString("0.000")}";
    }
  }
}
