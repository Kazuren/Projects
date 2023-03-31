using Godot;
using System;


namespace Twitch
{
  public class Emoji
  {
    public Emoji(string code, string path)
    {
      Code = code;
      Path = path;

      //Texture = ResourceLoader.Load<Texture>(path);

      TwitchCharacterLength = Twitch.Client.WithoutCodeUnits(code).Length;
    }
    // TODO possibly make texture loading async
    public Texture Texture
    {
      get
      {
        if (_texture == null) { _texture = ResourceLoader.Load<Texture>(Path); }
        return _texture;
      }
      set
      {
        _texture = value;
      }
    }
    public string Code { get; private set; }
    public string Path { get; private set; }
    public int TwitchCharacterLength { get; private set; }
    private Texture _texture;
  }
}
