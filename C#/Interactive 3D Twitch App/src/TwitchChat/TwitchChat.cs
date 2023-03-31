using Godot;
using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using System.Threading.Tasks;

using System.Text.RegularExpressions;

public class TwitchChat : Control
{
  private static readonly char[] InvisibleCharacters = new char[] { '\u200d', '\u200c', '\ufe0f' };
  //private static readonly Regex InvisibleCharacters = new Regex("\u200d\u200c\ufe0f", RegexOptions.Compiled);
  private const int ChatWidth = 300;
  public Twitch.Client TwitchClient { get; private set; }
  public List<ChatMessage> Messages { get; private set; } = new List<ChatMessage>();

  public string[] NameColors { get; private set; } = new string[13] {
    "#0000FF",
    "#FF0000",
    "#8A2BE2",
    "#FF69B4",
    "#1E90FF",
    "#008000",
    "#00FF7F",
    "#B22222",
    "#DAA520",
    "#FF4500",
    "#2E8B57",
    "#5F9EA0",
    "#D2691E",
  };

  [Export]
  private NodePath _twitchClientPath;
  private PackedScene _chatMessageScene = ResourceLoader.Load<PackedScene>("res://src/TwitchChat/ChatMessage/ChatMessage.tscn");
  private PackedScene _emoteScene = ResourceLoader.Load<PackedScene>("res://src/TwitchChat/Emote/Emote.tscn");
  private ScrollContainer _scrollContainer;
  private VBoxContainer _messageContainer;

  private Random random = new Random();

  private DynamicFont _normalFont = ResourceLoader.Load<DynamicFont>("res://Assets/fonts/TwitchChat/NotoSans,Arial,SegoeUISymbol,DroidSans.tres");
  private DynamicFont boldFont = ResourceLoader.Load<DynamicFont>("res://Assets/fonts/TwitchChat/NotoSans,Arial,SegoeUISymbol,DroidSans(Bold).tres");

  private string _availableChars;
  private List<int[]> _supportedUnicodeRanges;

  public override void _Ready()
  {
    if (_twitchClientPath == null) { return; }
    TwitchClient = GetNode<Twitch.Client>(_twitchClientPath);

    // Find and store supported unicode ranges.
    char[] chars = _normalFont.GetAvailableChars().ToArray();
    Array.Sort(chars);
    _availableChars = new String(chars);
    _supportedUnicodeRanges = CalculateFontUnicodeRanges();

    // foreach (int[] unicodeRange in supportedUnicodeRanges)
    // {
    //   GD.Print($"{unicodeRange[0]}-{unicodeRange[1]}");
    // }

    _scrollContainer = GetNode<ScrollContainer>("%ScrollContainer");
    _messageContainer = GetNode<VBoxContainer>("%Messages");

    TwitchClient.Connect("MessageReceived", this, nameof(OnMessageReceived));
    TwitchClient.Connect("ClearMessageReceived", this, nameof(OnClearMessageReceived));
    TwitchClient.Connect("ClearChatReceived", this, nameof(OnClearChatReceived));
    TwitchClient.Connect("ClearUserChatReceived", this, nameof(OnClearUserChatReceived));

    _scrollContainer.GetVScrollbar().RectScale = Vector2.Zero;
  }

  public override void _Process(float delta)
  {
    _scrollContainer.ScrollVertical = 10000;
  }

  private void OnClearMessageReceived(string messageId)
  {
    IEnumerable<ChatMessage> messagesToRemove = Messages.Where(m => IsInstanceValid(m) && m.Id == messageId).ToList();

    foreach (ChatMessage m in messagesToRemove)
    {
      if (m.IsInsideTree())
      {
        _messageContainer.RemoveChild(m);
      }
      m.FreeWhenPossible();
      Messages.Remove(m);
      break;
    }
  }

  private void OnClearChatReceived()
  {
    IEnumerable<ChatMessage> messagesToRemove = Messages.Where(m => IsInstanceValid(m)).ToList();

    foreach (ChatMessage m in messagesToRemove)
    {
      if (m.IsInsideTree())
      {
        _messageContainer.RemoveChild(m);
      }
      m.FreeWhenPossible();
      Messages.Remove(m);
    }
  }

  private void OnClearUserChatReceived(string userId)
  {
    IEnumerable<ChatMessage> messagesToRemove = Messages.Where(m => IsInstanceValid(m) && m.UserId == userId).ToList();

    foreach (ChatMessage m in messagesToRemove)
    {
      if (m.IsInsideTree())
      {
        _messageContainer.RemoveChild(m);
      }
      m.FreeWhenPossible();
      Messages.Remove(m);
    }
  }

  private List<int[]> CalculateFontUnicodeRanges()
  {
    List<int[]> list = new List<int[]>();
    int i = 1;
    int[] unicodeRange = new int[2] { (int)_availableChars[0], (int)_availableChars[0] };

    // Calculate font unicode ranges to be able to check if a character is supported by the font
    while (i < _availableChars.Length)
    {
      char c = _availableChars[i];
      int code = (int)c;

      if (unicodeRange[1] + 1 != code)
      {
        list.Add(unicodeRange);
        unicodeRange = new int[2] { code, code };
      }
      else
      {
        unicodeRange[1] = code;
        if (i == _availableChars.Length - 1)
        {
          list.Add(unicodeRange);
        }
      }
      i++;
    }
    return list;
  }

  private bool IsCharacterSupported(char c)
  {
    int code = (int)c;
    foreach (int[] unicodeRange in _supportedUnicodeRanges)
    {
      if (code >= unicodeRange[0] && code <= unicodeRange[1])
      {
        return true;
      }
    }
    return false;
  }

  private async Task PopulateMessageNode(ChatMessage instance, Twitch.ChatMessage message)
  {
    MessageIterator messageIterator = new MessageIterator();

    Font boldFont = instance.Label.GetFont("bold_font");
    Font normalFont = instance.Label.GetFont("normal_font");

    instance.Label.BbcodeText = "";

    // ? Note: The +1 is needed for correct vertical emote position for some reason
    int fontHeight = (int)normalFont.GetHeight() + 1;

    int badgeMarginRight = 3;

    foreach (Twitch.Badge badge in message.Badges)
    {
      // TODO run all tasks at once and await all
      ImageTexture texture = await badge.GetTextureAsync(1);

      // If the download failed
      if (texture == null) { continue; }

      int width = texture.GetWidth() + badgeMarginRight;
      int height = texture.GetHeight();

      Texture transparentImageTexture = ResourceLoader.Load<Texture>("res://src/TwitchChat/TransparentImage.tres");
      instance.Label.AddImage(transparentImageTexture, width, 1);

      Node2D node2D = new Node2D();
      TextureRect textureRect = new TextureRect();

      node2D.AddChild(textureRect);
      instance.Label.AddChild(node2D);

      node2D.Position = new Vector2(messageIterator.CurrentWidth + texture.GetWidth() / 2, messageIterator.CurrentHeight + fontHeight / 2);

      // Center the texture relative to the Node2D's position
      textureRect.RectPosition = -texture.GetSize() / 2;
      textureRect.Texture = texture;

      messageIterator.CurrentWidth += width;
    }

    string displayName = $"{message.DisplayName}{(message.IsAction ? " " : ": ")}";
    Godot.Color color = message.Color != null ? new Color(message.Color) : new Color(NameColors[random.Next(0, NameColors.Length)]);

    // Brightens up darker colors for better contrast, not perfect
    // would be better to be able to calculate and adjust contrast depending on background color
    float luminance = 0.2126f * color.r + 0.7152f * color.g + 0.0722f * color.b;
    if (luminance < 0.5)
    {
      color = color.Lightened(0.5F - luminance);
    }

    instance.Label.PushBold();
    instance.Label.PushColor(color);
    AppendWord(displayName, instance.Label, fontHeight, messageIterator, true);
    instance.Label.Pop();
    instance.Label.Pop();

    if (message.IsAction)
    {
      instance.Label.PushColor(color);
    }

    string text = message.Text;
    string[] words = Regex.Split(text, @"(\s+)", RegexOptions.Compiled).Where(s => s != String.Empty).ToArray(); // .Where(s => s != String.Empty)

    foreach (string word in words)
    {
      try
      {
        await HandleWord(message, word, instance.Label, fontHeight, messageIterator);
      }
      catch (Exception exc)
      {
        GD.Print(message);
        throw exc;
      }
    }

    if (message.IsAction)
    {
      instance.Label.Pop();
    }
  }

  private ChatMessage CreateMessageNode(Twitch.ChatMessage message)
  {
    ChatMessage instance = _chatMessageScene.Instance<ChatMessage>();
    instance.Id = message.Id;
    instance.UserId = message.UserId;
    AddChild(instance);
    RemoveChild(instance);
    return instance;
  }

  private class MessageIterator
  {
    public float CurrentWidth { get; set; } = 0;
    public float CurrentHeight { get; set; } = 0;
    public int CurrentEmoteIndex { get; set; } = 0;
    public int CurrentEmojiIndex { get; set; } = 0;
    public int WordIndex { get; set; } = 0;
    public int EmojiIndex { get; set; } = 0;
    public int[] LastEmoteLocation { get; set; }
    public int[] LastEmojiLocation { get; set; }
    public Vector2 LastEmotePosition { get; set; }
    public Vector2 LastEmojiPosition { get; set; }
  }

  private async Task HandleWord(Twitch.ChatMessage message, string word, RichTextLabel label, int fontHeight, MessageIterator messageIterator)
  {
    // Get the label fonts
    Font boldFont = label.GetFont("bold_font");
    Font normalFont = label.GetFont("normal_font");

    // Print the literal word unicode for debugging
    //IEnumerable<string> literalWord = word.Select(c => (int)c).Select(c => $@"\u{c:x4}");
    //GD.Print($"Word index: {messageIterator.WordIndex}, Emoji index: {messageIterator.EmojiIndex}, Word: {word}, Literal Word: {string.Concat(literalWord)}");

    // Figure out if the word is a mention to another user
    bool isMention = word.BeginsWith("@");

    // Decide on the font used based on if it's a mention or not
    Font font = isMention ? boldFont : normalFont;

    // Cache the width of a space character
    float spaceSize = font.GetCharSize((int)' ').x;

    // Handle word being a series of spaces
    if (word.All(c => c == ' '))
    {
      if (messageIterator.CurrentWidth + spaceSize > ChatWidth)
      {
        messageIterator.CurrentWidth = 0;
        messageIterator.CurrentHeight += fontHeight;
        label.AddText("\n");
      }
      else if (messageIterator.CurrentWidth != 0)
      {
        messageIterator.CurrentWidth += spaceSize;
        label.AddText(" ");
      }
      messageIterator.WordIndex += word.Length;
      messageIterator.EmojiIndex += word.Length;
      return;
    }

    // Check if an emote starts at our current word index
    int[] emoteLocation = message.EmoteLocations.FirstOrDefault(l => l[0] == messageIterator.WordIndex);

    // Handles logic for when an emote is found
    if (emoteLocation != null)
    {
      // Gets the current emote and its texture
      Twitch.Emote emote = message.Emotes[messageIterator.CurrentEmoteIndex];
      ImageTexture texture = await emote.GetTexture2DAsync(1);

      // If the download failed
      if (texture == null) { return; }

      bool isZeroWidth = false;
      Vector2 emotePosition = Vector2.Zero;

      if (emote.ZeroWidth)
      {
        // substring the text from lastemote location to the start of this emote location
        // and if it's just spaces, then they're adjacent
        int[] lastEmoteLocation = messageIterator.LastEmoteLocation;
        int[] lastEmojiLocation = messageIterator.LastEmojiLocation;

        string textBetweenEmote = lastEmoteLocation != null ? message.Text.Substring(lastEmoteLocation[1] + 1, emoteLocation[0] - (lastEmoteLocation[1] + 1)) : null;
        string textBetweenEmoji = lastEmojiLocation != null ? message.Text.Substring(lastEmojiLocation[1] + 1, emoteLocation[0] - (lastEmojiLocation[1] + 1)) : null;

        if (textBetweenEmote != null && textBetweenEmote.All(c => c == ' '))
        {
          isZeroWidth = true;
          emotePosition = messageIterator.LastEmotePosition;
        }
        else if (textBetweenEmoji != null && textBetweenEmoji.All(c => c == ' '))
        {
          isZeroWidth = true;
          emotePosition = messageIterator.LastEmojiPosition;
        }
      }

      // If the emote is too big to fit in this line, go to the next line
      if (!isZeroWidth && messageIterator.CurrentWidth + texture.GetWidth() > ChatWidth)
      {
        messageIterator.CurrentWidth = 0;
        messageIterator.CurrentHeight += fontHeight;
        label.AddText("\n");
      }

      // Create a transparent image in the position where the emote is going to be placed
      // We do this because appending the image directly increases line height to be at least the same as the textures height
      if (!isZeroWidth)
      {
        Texture transparentImageTexture = ResourceLoader.Load<Texture>("res://src/TwitchChat/TransparentImage.tres");
        label.AddImage(transparentImageTexture, texture.GetWidth(), 1);
      }

      // Instance the emote scene
      Twitch.Chat.Emote textureRect = _emoteScene.Instance<Twitch.Chat.Emote>();
      textureRect.TwitchEmote = emote;

      // Instance a Node2D to position the emote correctly
      Node2D node2D = new Node2D();

      // Add them to the tree
      node2D.AddChild(textureRect);
      label.AddChild(node2D);

      // Make the Node2D's position the current position of the text
      node2D.Position = isZeroWidth ? emotePosition : new Vector2(messageIterator.CurrentWidth + texture.GetWidth() / 2, messageIterator.CurrentHeight + fontHeight / 2);

      // Center the texture relative to the Node2D's position
      textureRect.RectPosition = -texture.GetSize() / 2;
      textureRect.Texture = texture;

      // Increment the width, current emote index, word index and emoji index accordingly
      messageIterator.CurrentWidth += isZeroWidth ? 0 : texture.GetWidth();
      messageIterator.CurrentEmoteIndex++;
      messageIterator.WordIndex += word.Length;
      messageIterator.EmojiIndex += word.Length;
      messageIterator.LastEmoteLocation = emoteLocation;
      messageIterator.LastEmotePosition = node2D.Position;
      return;
    }

    // Word & Emoji handling
    int charIndex = 0;
    int wordIndexStart = 0;
    int wordIndexEnd = 0;
    int emojiOffset = 0;
    List<Twitch.Emoji> emojisFound = new List<Twitch.Emoji>();

    while (charIndex < word.Length)
    {
      //GD.Print(messageIterator.EmojiIndex + charIndex + emojiOffset);
      int[] emojiLocation = message.EmojiLocations.FirstOrDefault(l => l[0] == messageIterator.EmojiIndex + charIndex + emojiOffset);

      if (emojiLocation != null)
      {
        if (wordIndexEnd - wordIndexStart != 0)
        {
          string actualWord = word.Substring(wordIndexStart, wordIndexEnd - wordIndexStart);
          AppendWord(actualWord, label, fontHeight, messageIterator);
          messageIterator.WordIndex += actualWord.Length;
          messageIterator.EmojiIndex += actualWord.Length;
          emojiOffset -= actualWord.Length;
        }

        // Get the current emoji and its location + texture
        Twitch.Emoji emoji = message.Emojis[messageIterator.CurrentEmojiIndex];
        int startIndex = emojiLocation[0];
        int endIndex = emojiLocation[1];
        Texture texture = emoji.Texture;

        // If the emoji is too big to fit in this line, go to the next line
        if (messageIterator.CurrentWidth + 20 > ChatWidth)
        {
          messageIterator.CurrentWidth = 0;
          messageIterator.CurrentHeight += fontHeight;
          label.AddText("\n");
        }

        // Create a transparent image in the position where the emote is going to be placed
        // We do this because appending the image directly increases line height to be at least the same as the textures height
        Texture transparentImageTexture = ResourceLoader.Load<Texture>("res://src/TwitchChat/TransparentImage.tres");
        label.AddImage(transparentImageTexture, 20, 1);

        // Instance the emoji scene
        // * look at emote handling for reference
        TextureRect textureRect = new TextureRect() { Expand = true, RectSize = new Vector2(20, 20) };
        Node2D node2D = new Node2D();

        node2D.AddChild(textureRect);
        label.AddChild(node2D);

        node2D.Position = new Vector2(messageIterator.CurrentWidth + textureRect.RectSize.x / 2, messageIterator.CurrentHeight + fontHeight / 2);

        textureRect.RectPosition = -textureRect.RectSize / 2;
        textureRect.RectSize = new Vector2(20, 20);
        textureRect.Texture = texture;

        // Increment the width, current emoji index, word index, emoji index, and character index accordingly
        messageIterator.CurrentWidth += 20;
        messageIterator.CurrentEmojiIndex++;
        messageIterator.WordIndex += emoji.TwitchCharacterLength;
        messageIterator.EmojiIndex += emoji.Code.Length;
        messageIterator.LastEmojiLocation = emojiLocation;
        messageIterator.LastEmojiPosition = node2D.Position;

        emojiOffset -= emoji.Code.Length;

        charIndex += endIndex - startIndex + 1; // charIndex = endIndex ?

        emojisFound.Add(emoji);

        wordIndexStart = charIndex;
        wordIndexEnd = charIndex;
      }
      else
      {
        wordIndexEnd++;
        charIndex++;
      }
    }

    if (wordIndexEnd - wordIndexStart != 0)
    {
      string actualWord = word.Substring(wordIndexStart, wordIndexEnd - wordIndexStart);
      AppendWord(actualWord, label, fontHeight, messageIterator);
      messageIterator.WordIndex += actualWord.Length;
      messageIterator.EmojiIndex += actualWord.Length;
    }
  }

  private void AppendWord(string word, RichTextLabel label, int fontHeight, MessageIterator messageIterator, bool bold = false)
  {
    // Get the label fonts
    DynamicFont boldFont = (DynamicFont)label.GetFont("bold_font");
    DynamicFont normalFont = (DynamicFont)label.GetFont("normal_font");

    // Figure out if the word is a mention to another user
    bool isMention = word.BeginsWith("@");

    // Decide on the font used based on if the word is a mention or not
    DynamicFont font = isMention || bold ? boldFont : normalFont;

    // Remove bad characters like "Variant Selector", "Zero Width Joiner (u200d)", "Zero Width Non Joiner (u200c)" etc
    // Remove unavailable characters that show up as a diamond question mark "�"
    word = new String(
      word.Where(c => !InvisibleCharacters.Contains(c) && IsCharacterSupported(c)).ToArray() // !InvisibleCharacters.IsMatch($"{c}") && 
    );

    if (isMention)
    {
      label.PushBold();
    }

    Vector2 wordSize = font.GetStringSize(word);

    if (messageIterator.CurrentWidth + wordSize.x > ChatWidth)
    {
      messageIterator.CurrentHeight += fontHeight;
      messageIterator.CurrentWidth = 0;
      label.AddText("\n");
    }

    if (messageIterator.CurrentWidth + wordSize.x > ChatWidth)
    {
      for (int i = 0; i < word.Length; i++)
      {
        char c = word[i];

        Vector2 charSize = i == word.Length - 1 ? font.GetCharSize((int)c) : font.GetCharSize((int)c, word[i + 1]);

        if (messageIterator.CurrentWidth + charSize.x > ChatWidth)
        {
          messageIterator.CurrentWidth = 0;
          messageIterator.CurrentHeight += fontHeight;
          label.AddText("\n");
        }

        messageIterator.CurrentWidth += charSize.x;

        label.AddText($"{c}");
      }
    }
    else
    {
      messageIterator.CurrentWidth += wordSize.x;
      label.AddText(word);
    }

    if (isMention)
    {
      label.Pop();
    }
  }

  private void AppendTransparentImage(RichTextLabel label, int width)
  {
    Texture transparentImageTexture = ResourceLoader.Load<Texture>("res://src/TwitchChat/TransparentImage.tres");
    label.AddImage(transparentImageTexture, width, 1);
  }

  private async void OnMessageReceived(Twitch.ChatMessage message)
  {
    ChatMessage chatMessageNode = CreateMessageNode(message);
    Messages.Add(chatMessageNode);

    // TODO: try multithreading this
    chatMessageNode.PopulateTask = PopulateMessageNode(chatMessageNode, message);

    await Task.Delay(200); // <- ms to wait before showing message on screen to allow time to download|process emotes|text or to delete the message if malicious

    if (chatMessageNode.QueuedForDeletion)
    {
      return;
    }
    _messageContainer.AddChild(chatMessageNode);

    await ToSignal(GetTree(), "idle_frame");

    if (chatMessageNode.QueuedForDeletion)
    {
      return;
    }

    //chatMessageNode.GrabFocus();

    int messageCount = _messageContainer.GetChildCount();
    while (messageCount > 50)
    {
      ChatMessage m = _messageContainer.GetChild<ChatMessage>(0);
      _messageContainer.RemoveChild(m);
      m.FreeWhenPossible();
      Messages.Remove(m);
      messageCount--;
    }
  }
}
