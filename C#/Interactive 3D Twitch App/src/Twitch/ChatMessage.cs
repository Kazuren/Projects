using System;
using System.Collections.Generic;

using System.Linq;

namespace Twitch
{
  public class ChatMessage : Godot.Reference
  {
    public string Id { get; set; }
    public string UserId { get; set; }
    public List<Twitch.Emote> Emotes { get; set; }
    public string Text { get; set; }
    public List<int[]> EmoteLocations { get; set; }
    public string Color { get; set; }
    public string DisplayName { get; set; }
    public bool IsAction { get; set; }
    public List<Twitch.Badge> Badges { get; set; }
    public List<Twitch.Emoji> Emojis { get; set; }
    public List<int[]> EmojiLocations { get; set; }

    public ChatMessage() { }

    public override string ToString()
    {
      IEnumerable<string> chars = Text.Select(c => (int)c).Select(c => $@"\u{c:x4}");
      //GD.Print(string.Concat(literalEmojiCode));
      string literalText = string.Concat(chars);


      string emoteText = "";
      for (int i = 0; i < Emotes.Count; i++)
      {
        Twitch.Emote emote = Emotes[i];
        int[] location = EmoteLocations[i];

        emoteText += $"{emote}, location: {location[0]}-{location[1]}";

        if (i != Emotes.Count - 1)
        {
          emoteText += "\n";
        }
      }

      string emojiText = "";
      for (int i = 0; i < Emojis.Count; i++)
      {
        Twitch.Emoji emoji = Emojis[i];
        int[] location = EmojiLocations[i];

        emojiText += $"{emoji.Code}, location: {location[0]}-{location[1]}";

        if (i != Emojis.Count - 1)
        {
          emojiText += "\n";
        }
      }


      return String.Join(
        Environment.NewLine,
        $"Text: {Text}",
        $"Literal Text: {literalText}",
        $"Emotes: {emoteText}",
        $"Emojis: {emojiText}"
      );
    }
  }
}
