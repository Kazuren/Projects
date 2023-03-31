using Godot;
using System;
using System.Collections.Generic;
using System.Collections.Concurrent;
using System.Threading;
using System.Threading.Tasks;
using System.Diagnostics;

using System.Net.Http;
using System.Net.Http.Headers;
using System.Net;

using System.Linq;

using System.Text.RegularExpressions;

using System.IO;

namespace Twitch
{
  /// <summary>
  /// A Twitch Client that connects to Twitch's IRC server. <br/>
  /// Has support for Twitch, FFZ, BTTV, 7TV emotes.
  /// </summary>
  public class Client : Node
  {
    static Client()
    {
      ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls12;
      ServicePointManager.MaxServicePointIdleTime = 15000;
      HttpClient = new System.Net.Http.HttpClient();
    }
    /// <summary>
    /// The Http Client that is used for all HTTP requests regarding twitch.
    /// </summary>
    public static readonly System.Net.Http.HttpClient HttpClient;

    public static readonly Regex EmojiUnicodeSequenceRegex = new Regex("[\u1000-\uFFFF]+", RegexOptions.Compiled);

    /// <summary>
    /// The Twitch websocket URI.
    /// </summary>
    private const string WebSocketURL = "wss://irc-ws.chat.twitch.tv:443";

    /// <summary>
    /// The client id of the registered Twitch Application.
    /// </summary>
    public const string ClientId = "mf0qut9205m0ygmvqaa1ps4soyzrbt";

    /// <summary>
    /// The client secret of the registered Twitch Application.
    /// </summary>
    public const string ClientSecret = "g4l9s7zeb8oqydsbvy4zunyurfcf8v";

    /// <summary>
    /// The client name of the registered Twitch Application.
    /// </summary>
    private const string ClientName = "kazuren_";

    /// <summary>
    /// Godot Signal that emits when a "PRIVMSG" is received from the Twitch IRC Client.
    /// </summary>
    /// <param name="message">The chat message received.</param>
    [Signal]
    delegate void MessageReceived(ChatMessage message);
    [Signal]
    delegate void ClearChatReceived();
    [Signal]
    delegate void ClearUserChatReceived(string userId);
    [Signal]
    delegate void ClearMessageReceived(string messageId);

    [Signal]
    delegate void EmoteAdded(Twitch.Emote emote);
    [Signal]
    delegate void EmoteRemoved(Twitch.Emote emote);
    [Signal]
    delegate void EmoteUpdated(Twitch.Emote oldEmote, Twitch.Emote emote);
    [Signal]
    delegate void TemporaryEmoteAdded(Twitch.Emote emote);
    [Signal]
    delegate void TemporaryEmoteRemoved(Twitch.Emote emote);

    /// <summary>
    /// The channel name to connect to.
    /// </summary>
    [Export]
    private string _channel = "";

    /// <summary>
    /// The Twitch OAuth Token that Twitch uses to connect to authenticate requests to the Twitch API.
    /// </summary>
    public string OAuthToken { get; private set; }

    public KeyValuePair<string, Emote>[] Emotes
    {
      get => _emotes.ToArray();
    }

    public KeyValuePair<string, Emote>[] TemporaryEmotes
    {
      get => _temporaryEmotes.ToArray();
    }

    public TimeSpan EmoteReloadTimerTimeRemaining
    {
      get => _emoteReloadTimerStopWatch.Elapsed;
    }

    public string Channel
    {
      get => _channel;
    }

    public WebSocketClient.ConnectionStatus WebSocketConnectionStatus
    {
      get => _webSocketClient.GetConnectionStatus();
    }

    public double EmoteReloadTimerInterval
    {
      get => _emoteReloadTimer.Interval;
    }

    /// <summary>
    /// The id of the connected <see cref="_channel"/>.
    /// </summary>
    private string _channelId;

    /// <summary>
    /// The websocket client used to connect to twitch.
    /// </summary>
    private WebSocketClient _webSocketClient = new WebSocketClient();

    /// <summary>
    /// Dictionary that stores <see cref="Twitch.Emote"/>.
    /// </summary>
    private ConcurrentDictionary<string, Emote> _emotes = new ConcurrentDictionary<string, Emote>();
    private ConcurrentDictionary<string, Emote> _temporaryEmotes = new ConcurrentDictionary<string, Emote>();

    private ConcurrentDictionary<string, Emoji> _emojis = new ConcurrentDictionary<string, Emoji>();

    private List<string> _emojiList = new List<string>();

    private Dictionary<string, Badge> _badges = new Dictionary<string, Badge>();

    /// <summary>
    /// Timer that calls <see cref="ReloadEmoteList"/> to reload the emote list on a set interval.
    /// </summary>
    private System.Timers.Timer _emoteReloadTimer = new System.Timers.Timer(TimeSpan.FromMinutes(1).TotalMilliseconds);

    /// <summary>
    /// Stopwatch to measure the time remaining of the <see cref="_emoteReloadTimer"/>.
    /// </summary>
    private Stopwatch _emoteReloadTimerStopWatch = new Stopwatch();

    /// <summary>
    /// The delay before the <see cref="Twitch.Client"/> attempts to reconnect to the Twitch IRC server.
    /// </summary>
    private float _reconnectTimer = 0.0F;

    public static int[] ToCodePoints(string input)
    {
      List<int> codePoints = new List<int>(input.Length);

      for (int i = 0; i < input.Length; i++)
      {
        codePoints.Add(char.ConvertToUtf32(input, i));
        if (char.IsHighSurrogate(input[i]))
        {
          i++;
        }
      }
      return codePoints.ToArray();
    }

    /// <summary>
    /// Used to correctly calculate the emote position in a twitch message, twitch counts surrogate pairs as one character <br/>
    /// So to correctly find the emote code, we remove the low surrogate character from the string as if the high surrogate character was a surrogate pair <br/>
    /// Note: This is a malformed string and should only be used for calculating emote codes from a twitch message given emote indices. <br/>
    /// https://discuss.dev.twitch.tv/t/cant-calculate-offset-from-the-emotes-tag-if-the-message-contains-emojis/28414/2
    /// </summary>
    /// <param name="input"></param>
    /// <returns></returns>
    public static string WithoutCodeUnits(string input)
    {
      List<char> list = new List<char>(input.Length);

      for (int i = 0; i < input.Length; i++)
      {
        char c = input[i];
        list.Add(c);
        if (char.IsHighSurrogate(c))
        {
          i++;
        }
      }
      return new string(list.ToArray());
    }

    /// <summary>
    /// Automatically called when the <see cref="Twitch.Client"/> is ready. <br/>
    /// Connects to the necessary signals for the <see cref="_webSocketClient"/> to function. <br/>
    /// Gets the <see cref="_channelId"/> from the <see cref="_channel"/>. <br/>
    /// Awaits the download of all <see cref="Twitch.Emote"/>s. <br/>
    /// Connects to the <see cref="_webSocketClient"/> with the provided <see cref="WebSocketURL"/>
    /// Enables a 3rd party emote reload timer to refresh the emote list and remove old emotes.
    /// </summary>
    /// <remarks>
    /// Calls: <br/>
    /// <seealso cref="GetChannelId"/> <br/>
    /// <seealso cref="DownloadEmotes"/>
    /// </remarks>
    public override async void _Ready()
    {
      Utility.Certs.Load();
      SetProcess(false);
      _webSocketClient.Connect("connection_closed", this, nameof(OnConnectionClosed));
      _webSocketClient.Connect("connection_error", this, nameof(OnConnectionError));
      _webSocketClient.Connect("connection_established", this, nameof(OnConnectionEstablished));

      _webSocketClient.Connect("data_received", this, nameof(OnDataReceived));

      string[] pngFiles = Utility.GetFiles("res://Assets/emojis/72x72", ".png");

      foreach (string file in pngFiles)
      {
        string hexCode = System.IO.Path.GetFileNameWithoutExtension(file);
        string[] hexValues = hexCode.Split('-');
        string unicodeRepresentation = "";

        foreach (string hexValue in hexValues)
        {
          int value = Int32.Parse(hexValue, System.Globalization.NumberStyles.HexNumber);
          string unicodeValue = Char.ConvertFromUtf32(value);
          unicodeRepresentation += unicodeValue;
        }

        _emojis.TryAdd(unicodeRepresentation, new Emoji(unicodeRepresentation, file));
        _emojiList.Add(unicodeRepresentation);
      }
      // doesn't work for all cases example 'G''G''R' -> might be 'GG''R' or 'G''GR'
      // needs to go from start of string or also alphabetically sorted?
      _emojiList.Sort((a, b) => a.Length < b.Length ? 1 : a.Length == b.Length ? 0 : -1);

      OAuthToken = await TokenManager.GetToken();

      _channelId = await GetChannelId(_channel);
      await DownloadEmotes(_channelId);
      await DownloadBadges(_channelId);
      SetProcess(true);
      ConnectToTwitch();

      _emoteReloadTimer.AutoReset = true;
      _emoteReloadTimer.Enabled = true;
      _emoteReloadTimer.Elapsed += ReloadEmoteList;

      _emoteReloadTimerStopWatch.Start();
    }

    /// <summary>
    /// Automatically called once per frame. <br/>
    /// Polls the <see cref="_webSocketClient"/>. <br/>
    /// Finds and deletes unused twitch emotes. <br/>
    /// Updates all <see cref="_emotes"/>.
    /// </summary>
    /// <remarks>
    /// Calls: <br/>
    /// <seealso cref="Emote.Update"/> <br/>
    /// </remarks>
    public override void _Process(float delta)
    {
      // If we get disconnected from twitch, reconnect back
      if (_webSocketClient.GetConnectionStatus() == WebSocketClient.ConnectionStatus.Disconnected)
      {
        ConnectToTwitch();
      }
      // Update twitch emotes.
      foreach (KeyValuePair<string, Emote> emotePair in _emotes)
      {
        Emote emote = emotePair.Value;
        emote.Update(delta);
      }

      foreach (KeyValuePair<string, Emote> emotePair in _temporaryEmotes)
      {
        Emote emote = emotePair.Value;
        emote.Update(delta);
      }

      // Delete temporary emotes and emotes queued for deletion if they're not currently in use.
      KeyValuePair<string, Emote>[] emotesToRemove = _emotes.Where(emotePair => emotePair.Value.QueuedForDeletion && !emotePair.Value.CurrentlyInUse).ToArray();
      KeyValuePair<string, Emote>[] temporaryEmotesToRemove = _temporaryEmotes.Where(emotePair => !emotePair.Value.CurrentlyInUse).ToArray();

      foreach (KeyValuePair<string, Emote> emotePair in emotesToRemove)
      {
        bool success = RemoveEmote(emotePair.Key);
        if (success)
        {
          Logger.Instance.Log(Logger.Levels.INFO, "TwitchClient",
            $"Deleted {emotePair.Value} from the emote list because it was queued for deletion."
          );
        }
        else
        {
          Logger.Instance.Log(Logger.Levels.WARN, "TwitchClient",
            $"Emote {emotePair.Value} didn't exist in the _emotes dictionary to remove."
          );
        }
      }

      foreach (KeyValuePair<string, Emote> emotePair in temporaryEmotesToRemove)
      {
        bool success = RemoveEmote(emotePair.Key, true);
        if (success)
        {
          Logger.Instance.Log(Logger.Levels.INFO, "TwitchClient",
            $"Deleted {emotePair.Value} from the emote list because it was temporary."
          );
        }
        else
        {
          Logger.Instance.Log(Logger.Levels.WARN, "TwitchClient",
            $"Temporary emote {emotePair.Value} didn't exist in the _temporaryEmotes dictionary to remove."
          );
        }
      }

      _webSocketClient.Poll();
    }

    /// <summary>
    /// Gets called automatically by the <see cref="_emoteReloadTimer"/> to reload the emote list.
    /// </summary>
    private async void ReloadEmoteList(object sender, System.Timers.ElapsedEventArgs args)
    {
      Logger.Instance.Log(Logger.Levels.INFO, "EmoteReloadTimer", "Refreshing emote list...");

      _emoteReloadTimerStopWatch.Restart();

      List<Emote> downloadedEmotes = await DownloadEmotes(_channelId);
      //List<Emote> emotesToUpdate = new List<Emote>();

      // Remove emotes that aren't in the downloaded emotes list and are not from twitch
      foreach (KeyValuePair<string, Emote> emote in _emotes)
      {
        bool inList = downloadedEmotes.Any(e => e.ToString() == emote.Key);

        //emotesToUpdate.AddRange(downloadedEmotes.Where(e => e.Provider == emote.Value.Provider && e.Code == emote.Value.Code && e.Id != emote.Value.Id));

        if (!inList && emote.Value.Provider != EmoteProvider.Twitch)
        {
          bool success = RemoveEmote(emote.Key);
          if (success)
          {
            Logger.Instance.Log(Logger.Levels.INFO, "EmoteReloadTimer",
              $"Removed {emote} from the _emotes Dictionary because it was not in the downloaded emote list."
            );
          }
          else
          {
            Logger.Instance.Log(Logger.Levels.WARN, "EmoteReloadTimer", $"Failed to remove {emote} from the _emotes Dictionary. It was not in the downloaded emote list.");
          }

          if (emote.Value.CurrentlyInUse)
          {
            success = AddEmote(emote.ToString(), emote.Value, true);
            if (success)
            {
              Logger.Instance.Log(Logger.Levels.INFO, "EmoteReloadTimer",
                $"The {emote} from the _emotes Dictionary is currently in use. Added it to the temporary emotes dictionary."
              );
            }
            else
            {
              Logger.Instance.Log(Logger.Levels.WARN, "EmoteReloadTimer", $"The {emote} from the _emotes Dictionary is currently in use. Could not add it to the temporary emotes dictionary.");
            }
          }
        }
      }
    }

    /// <summary>
    /// Does an HTTP Request to the Twitch API to get a channel id from a channel name. <br/>
    /// <paramref name="channel"/>: The channel to get the id from.
    /// </summary>
    /// <param name="channel">The channel to get the id from.</param>
    /// <returns>The channel id.</returns>
    private async Task<string> GetChannelId(string channel)
    {
      using (var request = new HttpRequestMessage(HttpMethod.Get, $"https://api.twitch.tv/helix/users?login={channel}"))
      {
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", OAuthToken);
        request.Headers.Add("Client-Id", ClientId);
        HttpResponseMessage response = await HttpClient.SendAsync(request);
        response.EnsureSuccessStatusCode();
        byte[] responseBody = await response.Content.ReadAsByteArrayAsync();

        object json = JSON.Parse(responseBody.GetStringFromUTF8()).Result;

        if (json is Godot.Collections.Dictionary jsonResult)
        {
          if (jsonResult.Contains("data") && jsonResult["data"] is Godot.Collections.Array data)
          {
            // TODO: do sanity check if twitch user doesn't exist in case we want to set it from in game later
            // if we get a user that doesn't exist this array is empty
            Godot.Collections.Dictionary user = (Godot.Collections.Dictionary)data[0];
            return (string)user["id"];
          }
        }
        return null;
      }
    }

    /// <summary>
    /// Attempts to connect to twitch with an exponential backoff.
    /// </summary>
    private async void ConnectToTwitch(float delay = 0F)
    {
      _reconnectTimer = Math.Max(Math.Min(_reconnectTimer * 2, 512F), 1F);

      if (delay > 0)
      {
        await Task.Delay(TimeSpan.FromSeconds(delay));
      }

      Logger.Instance.Log(Logger.Levels.INFO, "WebSocketClient", $"Attempting to connect to {WebSocketURL}...");
      Error error = _webSocketClient.ConnectToUrl(WebSocketURL);
      if (error != Error.Ok)
      {
        Logger.Instance.Log(Logger.Levels.ERROR, "WebSocketClient", $"Unable to connect to {WebSocketURL}: {error}");
      }
    }

    /// <summary>
    /// Emitted when the connection to the <see cref="WebSocketURL"/> is closed. <br/>
    /// <paramref name="wasClean"/> will be true if the connection was shutdown cleanly. <br/>
    /// Causes the <see cref="Client"/> to stop processing.
    /// </summary>
    /// <param name="wasClean">Will be <see langword="true"/> if the connection was shutdown cleanly.</param>
    private void OnConnectionClosed(bool wasClean = false)
    {
      Logger.Instance.Log(Logger.Levels.WARN, "WebSocketClient", $"Connection to server closed. Clean: {wasClean}");
      ConnectToTwitch(_reconnectTimer);
    }

    /// <summary>
    /// Emitted when the connection to the <see cref="WebSocketURL"/> fails. <br/>
    /// Causes the <see cref="Client"/> to stop processing.
    /// </summary>
    private void OnConnectionError()
    {
      Logger.Instance.Log(Logger.Levels.ERROR, "WebSocketClient", $"Connection to server failed.");
      ConnectToTwitch(_reconnectTimer);
    }

    /// <summary>
    /// Emitted when a connection with the <see cref="WebSocketURL"/> is established. <br/>
    /// Resets the <see cref="_reconnectTimer"/>. <br/>
    /// <paramref name="protocol"/> will contain the sub-protocol agreed with the <see cref="_webSocketClient"/>. <br/>
    /// Authenticates with the Twitch IRC server anonymously. <br/>
    /// Connects to the specified <see cref="_channel"/>.
    /// </summary>
    /// <param name="protocol">Will contain the sub-protocol agreed with the <see cref="_webSocketClient"/>.</param>
    private void OnConnectionEstablished(string protocol = "")
    {
      Logger.Instance.Log(Logger.Levels.INFO, "WebSocketClient", $"Successfully connected to the twitch websocket server!");
      _reconnectTimer = 0.0F;
      AuthenticateAnonymously();
      ConnectToChannel(_channel);
    }

    /// <summary>
    /// Emitted when a WebSocket message is received.
    /// Parses the message and handles it.
    /// </summary>
    /// <remarks>
    /// Can be multiple messages at once. <br/>
    /// Calls: <br/>
    /// <seealso cref="ParseMessage"/> <br/>
    /// <seealso cref="HandleMessage"/> <br/>
    /// </remarks>
    private void OnDataReceived()
    {
      string data = _webSocketClient.GetPeer(1).GetPacket().GetStringFromUTF8();

      string[] messages = data.StripEdges(false).Split("\r\n");

      foreach (string message in messages)
      {
        //GD.Print($"Received data: {message}");
        Dictionary<string, object> parsedMessage = ParseMessage(message);
        if (parsedMessage != null)
        {
          HandleMessage(parsedMessage);
        }
      }
      //GD.Print($"Got data from server: {data}");
    }

    /// <summary>
    /// Authenticates the <see cref="Client"/> with the Twitch IRC server.<br/>
    /// </summary>
    private void AuthenticateAnonymously()
    {
      _webSocketClient.GetPeer(1).SetWriteMode(WebSocketPeer.WriteMode.Text);

      SendData("CAP REQ :twitch.tv/tags");
      SendData("CAP REQ :twitch.tv/commands");
      SendData($"PASS kappa");
      SendData($"NICK justinfan69");
    }

    /// <summary>
    /// Helper function to send data to the Twitch IRC server. <br/>
    /// <paramref name="data"/>: The data to send. Gets converted to a byte array.
    /// </summary>
    /// <param name="data">The data to send. Gets converted to a byte array.</param>
    private void SendData(string data)
    {
      _webSocketClient.GetPeer(1).PutPacket(data.ToUTF8());
      //GD.Print($"Sent data: {data}");
    }

    /// <summary>
    /// Helper function to connect to a twitch channel. <br/>
    /// <paramref name="channel"/>: The twitch channel to connect to.
    /// </summary>
    /// <param name="channel">The twitch channel to connect to.</param>
    private void ConnectToChannel(string channel)
    {
      SendData($"JOIN #{channel}");
    }

    /// <summary>
    /// Handles a parsed Twitch IRC message. <br/>
    /// <paramref name="message"/>: The parsed IRC message.
    /// </summary>
    /// <param name="message">The parsed IRC message.</param>
    private void HandleMessage(Dictionary<string, object> message)
    {

      if (message["command"] is Dictionary<string, object> command)
      {
        string text = (string)message["parameters"];

        switch ((string)command["command"])
        {
          case "PING":
            SendData($"PONG :{text}");
            break;
          case "PRIVMSG":
            //text = (string)message["parameters"];

            // Stopwatch stopwatch = new Stopwatch();
            // stopwatch.Start();

            Dictionary<string, object> tags = (Dictionary<string, object>)message["tags"];
            Dictionary<string, object> twitchEmotes = (Dictionary<string, object>)tags["emotes"];
            Dictionary<string, string> twitchBadges = (Dictionary<string, string>)tags["badges"];
            string color = (string)tags["color"];
            string displayName = (string)tags["display-name"];
            string messageId = (string)tags["id"];
            string userId = (string)tags["user-id"];

            // TODO move this in parse message function and add a fake tag that the message is a /me (ACTION) message
            // Remove ACTION (/me) from messages for correct emote detection.
            bool isAction = text.StartsWith("\u0001" + "ACTION");
            text = isAction ? text.Replace("\u0001" + "ACTION ", String.Empty).Replace("\u0001", String.Empty) : text;
            text = text.Replace("\udb40\udc02", "\u200d");

            //TODO detect emojis here
            // Prints unicode literals

            List<Emoji> emojis = new List<Emoji>();
            List<int[]> emojiLocations = new List<int[]>();
            MatchCollection matches = EmojiUnicodeSequenceRegex.Matches(text);

            foreach (Match match in matches)
            {
              string emojiSequence = match.Value;
              int emojiStartIndex = match.Index;
              int emojiEndIndex = emojiStartIndex + match.Length - 1;
              List<int[]> matchLocations = new List<int[]>();

              foreach (string code in _emojiList)
              {
                int index = 0;
                do
                {
                  index = emojiSequence.IndexOf(code, index, StringComparison.Ordinal);
                  if (index != -1)
                  {
                    //IEnumerable<string> literalEmojiCode = code.Select(c => (int)c).Select(c => $@"\u{c:x4}");
                    //GD.Print(string.Concat(literalEmojiCode));
                    matchLocations.Add(new int[] { emojiStartIndex + index, emojiStartIndex + index + code.Length - 1 });
                    //emojis.Add(_emojis[code]);
                    //emojiLocations.Add(new int[] { emojiStartIndex + offset + index, emojiStartIndex + offset + index + code.Length - 1 });
                    //offset += code.Length;

                    //emojiSequence = emojiSequence.Remove(index, code.Length);
                    index++;
                  }
                }
                while (index != -1);
              }

              matchLocations = GetLongestEmojiLocations(matchLocations);

              foreach (int[] l in matchLocations)
              {
                string emojiCode = text.Substring(l[0], l[1] - l[0] + 1);
                emojiLocations.Add(l);
                emojis.Add(_emojis[emojiCode]);
              }
            }

            // Replace emoji sequences with spaces temporarily to handle twitch emote positions correctly
            // Matches one or more unicode characters and replaces them with a single space to account for the message length correctly
            string correctLengthText = WithoutCodeUnits(text);
            //string textWithoutEmojis = EmojiUnicodeSequenceRegex.Replace(text.Replace("\u200d", " "), " ");

            List<Emote> twitchEmotesInMessage = new List<Emote>();

            // Emote handling
            if (twitchEmotes != null)
            {
              foreach (KeyValuePair<string, object> twitchEmote in twitchEmotes)
              {
                string id = twitchEmote.Key;

                List<Dictionary<string, string>> positions = (List<Dictionary<string, string>>)twitchEmote.Value;

                int startPosition = int.Parse(positions[0]["startPosition"]);
                int endPosition = int.Parse(positions[0]["endPosition"]);

                string emoteCode = correctLengthText.Substring(startPosition, endPosition - startPosition + 1);

                string emoteKey = Emote.GenerateEmoteKey(emoteCode, id, EmoteProvider.Twitch);

                string[] imageUrls = new string[3]
                {
                  $"https://static-cdn.jtvnw.net/emoticons/v2/{id}/default/dark/1.0",
                  $"https://static-cdn.jtvnw.net/emoticons/v2/{id}/default/dark/2.0",
                  $"https://static-cdn.jtvnw.net/emoticons/v2/{id}/default/dark/3.0"
                };

                if (!_emotes.ContainsKey(emoteKey))
                {
                  Emote e = new Emote(emoteCode, imageUrls, id, EmoteProvider.Twitch);
                  AddEmote(emoteKey, e);
                  twitchEmotesInMessage.Add(e);
                }
                else
                {
                  twitchEmotesInMessage.Add(_emotes[emoteKey]);
                }

                // if (!_emotes.ContainsKey(emoteCode))
                // {
                //   Emote e = new Emote(emoteCode, imageUrls, id, EmoteProvider.Twitch);
                //   AddEmote(emoteCode, e);
                // }
              }
            }

            List<Emote> emotes = new List<Emote>();
            List<int[]> emoteLocations = new List<int[]>();

            string[] words = correctLengthText.Split(' ');
            int startIndex = 0;
            foreach (string word in words)
            {
              System.Globalization.StringInfo wordInfo = new System.Globalization.StringInfo(word);
              int endIndex = startIndex + word.Length - 1; // -1 because arrays are zero indexed

              Emote twitchEmote = twitchEmotesInMessage.FirstOrDefault(e => e.Code == word);
              Emote emote = twitchEmote != null ? twitchEmote : _emotes.Where(e => e.Value.Code == word && e.Value.Provider != EmoteProvider.Twitch)
                .OrderBy(e => e.Value.Provider).FirstOrDefault().Value;

              if (emote != null)
              {
                emotes.Add(emote);
                emoteLocations.Add(new int[] { startIndex, endIndex });
              }

              // if (_emotes.ContainsKey(word))
              // {
              //   emotes.Add(_emotes[word]);
              //   emoteLocations.Add(new int[] { startIndex, endIndex });
              // }
              startIndex += word.Length + 1;
            }

            // Badge handling
            List<Badge> badges = new List<Badge>();
            if (twitchBadges != null)
            {
              foreach (KeyValuePair<string, string> badge in twitchBadges)
              {
                string key = $"{badge.Key}:{badge.Value}";
                if (_badges.ContainsKey(key))
                {
                  badges.Add(_badges[key]);
                }
              }
            }

            // Remove extra spaces
            //text = new Regex("[ ]{2,}", RegexOptions.Compiled).Replace(text, " ");

            //ChatMessage m = new ChatMessage(text, emotes, emoteLocations, color: color, displayName: displayName, badges: badges, emojis: emojis, emojiLocations: emojiLocations);
            ChatMessage m = new ChatMessage
            {
              Text = text,
              Emotes = emotes,
              EmoteLocations = emoteLocations,
              Color = color,
              DisplayName = displayName,
              Badges = badges,
              Emojis = emojis,
              EmojiLocations = emojiLocations,
              IsAction = isAction,
              Id = messageId,
              UserId = userId,
            };
            EmitSignal(nameof(MessageReceived), m);

            // stopwatch.Stop();
            // GD.Print($"Elapsed time to handle PRIVMSG: {stopwatch.ElapsedMilliseconds}ms");
            break;
          case "CLEARMSG":
            HandleClearMessage(message);
            //Dictionary<string, object> tags = (Dictionary<string, object>)message["tags"];
            break;
          case "CLEARCHAT":
            HandleClearChat(message);
            break;
        }
      }
    }

    private void HandlePrivateMessage(Dictionary<string, object> message)
    {

    }

    private void HandleClearMessage(Dictionary<string, object> message)
    {
      // target-msg-id
      Dictionary<string, object> tags = (Dictionary<string, object>)message["tags"];

      string targetMessageId = (string)tags["target-msg-id"];

      EmitSignal(nameof(ClearMessageReceived), targetMessageId);
    }

    private void HandleClearChat(Dictionary<string, object> message)
    {
      // if it has a room-id clear all chat
      // if it has a target-user-id clear all messages with that id
      Dictionary<string, object> tags = (Dictionary<string, object>)message["tags"];

      string roomId = tags.ContainsKey("room-id") ? (string)tags["room-id"] : null;
      string targetUserId = tags.ContainsKey("target-user-id") ? (string)tags["target-user-id"] : null;

      if (targetUserId != null)
      {
        EmitSignal(nameof(ClearUserChatReceived), targetUserId);
      }
      else if (roomId != null)
      {
        EmitSignal(nameof(ClearChatReceived));
      }
    }

    private List<int[]> GetLongestEmojiLocations(List<int[]> input)
    {
      if (input.Count == 0)
      {
        return input;
      }

      IOrderedEnumerable<int[]> list = input.OrderBy(l => l[0]).ThenByDescending(l => l[1]);

      List<int[]> locations = new List<int[]>();

      int[] currentLocation = null;

      foreach (int[] l in list)
      {
        if (currentLocation == null)
        {
          currentLocation = l;
          continue;
        }

        // if the emoji starts at a different index
        if (currentLocation[0] != l[0])
        {
          // if it's in between our current emoji, skip
          if (l[0] <= currentLocation[1])
          {
            continue;
          }
          else
          {
            locations.Add(currentLocation);
            currentLocation = l;
          }
        }
        else if (currentLocation[1] < l[1])
        {
          currentLocation = l;
        }
      }
      locations.Add(currentLocation);
      return locations;
    }

    /// <summary>
    /// Parses the IRC message.
    /// </summary>
    private Dictionary<string, object> ParseMessage(string message)
    {

      // Contains the component parts.
      Dictionary<string, object> parsedMessage = new Dictionary<string, object>()
      {
        ["tags"] = null,
        ["source"] = null,
        ["command"] = null,
        ["parameters"] = null,
      };

      // The start index. Increments as we parse the IRC message.
      int idx = 0;

      int endIdx = 0;

      // The raw components of the IRC message.

      string rawTagsComponent = null;
      string rawSourceComponent = null;
      string rawCommandComponent = null;
      string rawParametersComponent = null;


      // If the message includes tags, get the tags component of the IRC message.
      if (message[idx] == '@')
      {
        // The message includes tags.
        endIdx = message.IndexOf(' ');
        rawTagsComponent = message.Substring(1, endIdx - 1);
        idx = endIdx + 1; // Should now point to source colon (:).
      }


      // Get the source component (nick and host) of the IRC message.
      // The idx should point to the source part; otherwise, it's a PING command.
      if (message[idx] == ':')
      {
        idx += 1;
        endIdx = message.IndexOf(' ', idx);
        rawSourceComponent = message.Substring(idx, endIdx - idx);
        idx = endIdx + 1; // Should point to the command part of the message.
      }


      // Get the command component of the IRC message.
      endIdx = message.IndexOf(':', idx);  // Looking for the parameters part of the message.
      if (endIdx == -1)                    // But not all messages include the parameters part.
      {
        endIdx = message.Length;
      }
      rawCommandComponent = message.Substring(idx, endIdx - idx).Trim();

      // Get the parameters component of the IRC message.
      if (endIdx != message.Length)  // Check if the IRC message contains a parameters component.
      {
        idx = endIdx + 1; // Should point to the parameters part of the message.
        rawParametersComponent = message.Substring(idx);
      }

      // Parse the command component of the IRC message.
      parsedMessage["command"] = ParseCommand(rawCommandComponent);


      // Only parse the rest of the components if it's a command
      // we care about; we ignore some messages.

      if (parsedMessage["command"] == null)
      {  // Is null if it's a message we don't care about.
        return null;
      }
      else
      {
        if (rawTagsComponent != null)
        {
          parsedMessage["tags"] = ParseTags(rawTagsComponent);
        }

        parsedMessage["source"] = ParseSource(rawSourceComponent);
        parsedMessage["parameters"] = rawParametersComponent;
        if (rawParametersComponent != null && rawParametersComponent[0] == '!')
        {
          parsedMessage["command"] = ParseParameters(rawParametersComponent, (Dictionary<string, object>)parsedMessage["command"]);
        }
      }

      return parsedMessage;
    }



    /// <summary>
    /// Parses the command component of the IRC message.
    /// </summary>
    private Dictionary<string, object> ParseCommand(string rawCommandComponent)
    {
      Dictionary<string, object> parsedCommand = null;

      string[] commandParts = rawCommandComponent.Split(' ');

      switch (commandParts[0])
      {
        case "JOIN":
        case "PART":
        case "NOTICE":
        case "CLEARCHAT":
        case "CLEARMSG":
        case "HOSTTARGET":
        case "PRIVMSG":
          parsedCommand = new Dictionary<string, object>
          {
            ["command"] = commandParts[0],
            ["channel"] = commandParts[1]
          };
          break;
        case "PING":
          parsedCommand = new Dictionary<string, object>
          {
            ["command"] = commandParts[0]
          };
          break;
        case "CAP":
          parsedCommand = new Dictionary<string, object>
          {
            ["command"] = commandParts[0],
            ["isCapRequestEnabled"] = (commandParts[2] == "ACK")
            // The parameters part of the messages contains the 
            // enabled capabilities.
          };
          break;
        case "RECONNECT":
          Logger.Instance.Log(Logger.Levels.INFO, "WebSocketClient", $"The Twitch IRC server is about to terminate the connection for maintenance.");
          parsedCommand = new Dictionary<string, object>
          {
            ["command"] = commandParts[0]
          };
          break;
        case "421":
          Logger.Instance.Log(Logger.Levels.WARN, "WebSocketClient", $"Unsupported IRC command: {commandParts[2]}");
          return null;
        case "001":  // Logged in (successfully authenticated). 
          parsedCommand = new Dictionary<string, object>
          {
            ["command"] = commandParts[0],
            ["channel"] = commandParts[1]
          };
          break;
        case "002":  // Ignoring all other numeric messages.
        case "003":
        case "004":
        case "353":  // Tells you who else is in the chat room you're joining.
        case "366":
        case "372":
        case "375":
        case "376":
          //GD.Print($"Numeric message: {commandParts[0]}");
          return null;
        case "ROOMSTATE": // Ignore bot joining channel
        case "USERNOTICE": // Ignore subs
          return null;
        default:
          Logger.Instance.Log(Logger.Levels.WARN, "WebSocketClient", $"\nUnexpected command: {commandParts[0]}\n");
          return null;
      }
      return parsedCommand;
    }

    /// <summary>
    /// Parses the tags component of the IRC message.
    /// </summary>
    private Dictionary<string, object> ParseTags(string rawTagsComponent)
    {
      // badge-info=;badges=broadcaster/1;color=#0000FF;...

      string[] tagsToIgnore = new string[] { "client-nonce", "flags" }; // List of tags to ignore.

      Dictionary<string, object> dictParsedTags = new Dictionary<string, object>(); // Holds the parsed list of tags. 
                                                                                    // The key is the tag's name (e.g., color).

      string[] parsedTags = rawTagsComponent.Split(';');

      foreach (string tag in parsedTags)
      {
        string[] parsedTag = tag.Split('=');  // Tags are key/value pairs.
        string tagValue = parsedTag[1] == "" ? null : parsedTag[1];

        switch (parsedTag[0]) // Switch on tag name
        {
          case "badges":
          case "badge-info":
            // badges=staff/1,broadcaster/1,turbo/1;
            if (tagValue != null)
            {
              Dictionary<string, string> dict = new Dictionary<string, string>(); // Holds the list of badge objects.
                                                                                  // The key is the badge's name (e.g., subscriber).
              string[] badges = tagValue.Split(',');
              foreach (string pair in badges)
              {
                string[] badgeParts = pair.Split('/');
                dict[badgeParts[0]] = badgeParts[1];
              }
              dictParsedTags[parsedTag[0]] = dict;
            }
            else
            {
              dictParsedTags[parsedTag[0]] = null;
            }
            break;

          case "emotes":
            // emotes=25:0-4,12-16/1902:6-10
            if (tagValue != null)
            {
              Dictionary<string, object> dictEmotes = new Dictionary<string, object>(); // Holds a list of emote objects.
                                                                                        // The key is the emote's ID.
              string[] emotes = tagValue.Split('/');
              foreach (string emote in emotes)
              {
                string[] emoteParts = emote.Split(':');

                List<Dictionary<string, string>> textPositions = new List<Dictionary<string, string>>();

                string[] positions = emoteParts[1].Split(',');
                foreach (string position in positions)
                {
                  string[] positionParts = position.Split('-');
                  textPositions.Add(new Dictionary<string, string>()
                  {
                    ["startPosition"] = positionParts[0],
                    ["endPosition"] = positionParts[1],
                  });
                }
                dictEmotes[emoteParts[0]] = textPositions;
              }
              dictParsedTags[parsedTag[0]] = dictEmotes;
            }
            else
            {
              dictParsedTags[parsedTag[0]] = null;
            }
            break;
          case "emote-sets":
            // emote-sets=0,33,50,237
            string[] emoteSetIds = tagValue.Split(','); // Array of emote set IDs.
            dictParsedTags[parsedTag[0]] = emoteSetIds;
            break;
          default:
            // If the tag is in the list of tags to ignore, ignore
            // it; otherwise, add it.
            if (Array.IndexOf<string>(tagsToIgnore, parsedTag[0]) != -1)
            {
              ;
            }
            else
            {
              dictParsedTags[parsedTag[0]] = tagValue;
            }
            break;
        }
      }

      return dictParsedTags;
    }

    /// <summary>
    /// Parses the source (nick and host) components of the IRC message.
    /// </summary>
    private Dictionary<string, object> ParseSource(string rawSourceComponent)
    {
      if (rawSourceComponent == null)
      {  // Not all messages contain a source
        return null;
      }
      else
      {
        string[] sourceParts = rawSourceComponent.Split('!');
        return new Dictionary<string, object>
        {
          ["nick"] = sourceParts.Length == 2 ? sourceParts[0] : null,
          ["host"] = sourceParts.Length == 2 ? sourceParts[1] : sourceParts[0]
        };
      }
    }
    /// <summary>
    /// Parsing the IRC parameters component if it contains a command (e.g., !dice).
    /// </summary>
    private Dictionary<string, object> ParseParameters(string rawParametersComponent, Dictionary<string, object> command)
    {
      int idx = 0;
      string commandParts = rawParametersComponent.Substring(idx + 1).Trim();
      int paramsIdx = commandParts.IndexOf(' ');

      if (paramsIdx == -1) // no parameters
      {
        command["botCommand"] = commandParts.Substring(0);
      }
      else
      {
        command["botCommand"] = commandParts.Substring(0, paramsIdx);
        command["botCommandParams"] = commandParts.Substring(paramsIdx).Trim();
        // TODO: remove extra spaces in parameters string
      }
      return command;
    }

    /// <summary>
    /// Loads FFZ, BTTV and 7TV emotes.
    /// </summary>
    private async Task<List<Emote>> DownloadEmotes(string channelId)
    {
      List<Emote> emotesDownloaded = new List<Emote>();

      // FFZ
      foreach (string endpoint in new string[] { "emotes/global", $"users/twitch/{channelId}" })
      {
        HttpResponseMessage response;
        using (var tokenSource = new CancellationTokenSource(TimeSpan.FromSeconds(10)))
        {
          try
          {
            response = await HttpClient.GetAsync($"https://api.betterttv.net/3/cached/frankerfacez/{endpoint}", tokenSource.Token);
          }
          catch (Exception exc)
          {
            if (exc is TaskCanceledException)
            {
              Logger.Instance.Log(Logger.Levels.WARN, "TwitchClient", $"Request to FFZ endpoint: https://api.betterttv.net/3/cached/frankerfacez/{endpoint} timed out. Skipping...\n{exc}");
            }
            else
            {
              Logger.Instance.Log(Logger.Levels.ERROR, "TwitchClient", $"Request to FFZ endpoint: https://api.betterttv.net/3/cached/frankerfacez/{endpoint} errored out. Skipping...\n{exc}");
            }
            continue;
          }
        }

        if (!response.IsSuccessStatusCode)
        {
          if (response.StatusCode == HttpStatusCode.NotFound)
          {
            Logger.Instance.Log(Logger.Levels.INFO, "TwitchClient", $"Could not find FFZ endpoint: https://api.betterttv.net/3/cached/frankerfacez/{endpoint}. Skipping...");
            continue;
          }
          else
          {
            Logger.Instance.Log(Logger.Levels.WARN, "TwitchClient", $"Unhandled HTTP status code: {response.StatusCode}");
            continue;
          }
        }

        byte[] responseBody = await response.Content.ReadAsByteArrayAsync();

        object json = JSON.Parse(responseBody.GetStringFromUTF8()).Result;

        if (json is Godot.Collections.Array emotes)
        {
          foreach (Godot.Collections.Dictionary emote in emotes)
          {
            string id = emote["id"].ToString();
            string emoteCode = (string)emote["code"];

            Godot.Collections.Dictionary images = emote["images"] as Godot.Collections.Dictionary;

            string[] imageUrls = new string[3]
            {
              (string)images["1x"],
              images["2x"] != null ? (string)images["2x"] : (string)images["1x"],
              images["4x"] != null ? (string)images["4x"] : images["2x"] != null ? (string)images["2x"] : (string)images["1x"]
          };

            int scale = images["4x"] != null ? 1 : images["2x"] != null ? 2 : 4;

            Emote e = new Emote(emoteCode, imageUrls, id, EmoteProvider.FFZ, scale);
            emotesDownloaded.Add(e);

            string emoteKey = e.ToString();
            if (!_emotes.ContainsKey(emoteKey))
            {
              AddEmote(emoteKey, e);
            }

            // if (!_emotes.ContainsKey(emoteCode))
            // {
            //   AddEmote(emoteCode, e);
            // }
          }
        }
      }

      // BTTV
      foreach (string endpoint in new string[] { "emotes/global", $"users/twitch/{channelId}" })
      {
        HttpResponseMessage response;
        using (var tokenSource = new CancellationTokenSource(TimeSpan.FromSeconds(10)))
        {
          try
          {
            response = await HttpClient.GetAsync($"https://api.betterttv.net/3/cached/{endpoint}", tokenSource.Token);
          }
          catch (Exception exc)
          {
            if (exc is TaskCanceledException)
            {
              Logger.Instance.Log(Logger.Levels.WARN, "TwitchClient", $"Request to BTTV endpoint: https://api.betterttv.net/3/cached/{endpoint} timed out. Skipping...\n{exc}");
            }
            else
            {
              Logger.Instance.Log(Logger.Levels.ERROR, "TwitchClient", $"Request to BTTV endpoint: https://api.betterttv.net/3/cached/{endpoint} errored out. Skipping...\n{exc}");
            }
            continue;
          }
        }

        if (!response.IsSuccessStatusCode)
        {
          if (response.StatusCode == HttpStatusCode.NotFound)
          {
            Logger.Instance.Log(Logger.Levels.INFO, "TwitchClient", $"Could not find BTTV endpoint: https://api.betterttv.net/3/cached/{endpoint}. Skipping...");
            continue;
          }
          else
          {
            Logger.Instance.Log(Logger.Levels.WARN, "TwitchClient", $"Unhandled HTTP status code: {response.StatusCode}");
            continue;
          }
        }

        byte[] responseBody = await response.Content.ReadAsByteArrayAsync();

        object json = JSON.Parse(responseBody.GetStringFromUTF8()).Result;

        if (json is Godot.Collections.Dictionary channel)
        {
          Godot.Collections.Array channelEmotes = channel["channelEmotes"] as Godot.Collections.Array;
          Godot.Collections.Array sharedEmotes = channel["sharedEmotes"] as Godot.Collections.Array;
          json = channelEmotes + sharedEmotes as Godot.Collections.Array;
        }

        if (json is Godot.Collections.Array emotes)
        {
          foreach (Godot.Collections.Dictionary emote in emotes)
          {
            string id = (string)emote["id"];
            string emoteCode = (string)emote["code"];
            string emoteId = (string)emote["id"];
            string[] imageUrls = new string[3]
            {
              $"https://cdn.betterttv.net/emote/{emoteId}/1x",
              $"https://cdn.betterttv.net/emote/{emoteId}/2x",
              $"https://cdn.betterttv.net/emote/{emoteId}/3x"
            };
            //string imageUrl = $"https://cdn.betterttv.net/emote/{emoteId}/3x";

            // "5e76d338d6581c3724c0f0b2" => cvHazmat, "5e76d399d6581c3724c0f0b8" => cvMask, "567b5b520e984428652809b6" => SoSnowy,
            // "5849c9a4f52be01a7ee5f79d" => IceCold, "567b5c080e984428652809ba" => CandyCane, "567b5dc00e984428652809bd" => ReinDeer,
            // "58487cc6f52be01a7ee5f205" => SantaHat, "5849c9c8f52be01a7ee5f79e" => TopHat
            string[] zeroWidthEmoteIds = new string[] {
              "5e76d338d6581c3724c0f0b2", "5e76d399d6581c3724c0f0b8", "567b5b520e984428652809b6", "5849c9a4f52be01a7ee5f79d",
              "567b5c080e984428652809ba","567b5dc00e984428652809bd", "58487cc6f52be01a7ee5f205", "5849c9c8f52be01a7ee5f79e"
            };
            bool isZeroWidth = zeroWidthEmoteIds.Contains(id);

            Emote e = new Emote(emoteCode, imageUrls, id, EmoteProvider.BTTV, 1, isZeroWidth);
            emotesDownloaded.Add(e);

            string emoteKey = e.ToString();
            if (!_emotes.ContainsKey(emoteKey))
            {
              AddEmote(emoteKey, e);
            }

            // if (!_emotes.ContainsKey(emoteCode))
            // {
            //   AddEmote(emoteCode, e);
            // }
          }
        }
      }

      // 7TV
      foreach (string endpoint in new string[] { "emotes/global", $"users/{channelId}/emotes" })
      {
        HttpResponseMessage response;
        using (var tokenSource = new CancellationTokenSource(TimeSpan.FromSeconds(10)))
        {
          try
          {
            response = await HttpClient.GetAsync($"https://api.7tv.app/v2/{endpoint}", tokenSource.Token);
          }
          catch (Exception exc)
          {
            if (exc is TaskCanceledException)
            {
              Logger.Instance.Log(Logger.Levels.WARN, "TwitchClient", $"Request to 7TV endpoint: https://api.7tv.app/v2/{endpoint} timed out. Skipping...\n{exc}");
            }
            else
            {
              Logger.Instance.Log(Logger.Levels.WARN, "TwitchClient", $"Request to 7TV endpoint: https://api.7tv.app/v2/{endpoint} errored out. Skipping...\n{exc}");
            }
            continue;
          }
        }

        if (!response.IsSuccessStatusCode)
        {
          if (response.StatusCode == HttpStatusCode.NotFound)
          {
            Logger.Instance.Log(Logger.Levels.INFO, "TwitchClient", $"Could not find 7TV endpoint: https://api.7tv.app/v2/{endpoint}. Skipping...");
            continue;
          }
          else
          {
            Logger.Instance.Log(Logger.Levels.WARN, "TwitchClient", $"Unhandled HTTP status code: {response.StatusCode}");
            continue;
          }
        }

        byte[] responseBody = await response.Content.ReadAsByteArrayAsync();

        object json = JSON.Parse(responseBody.GetStringFromUTF8()).Result;

        // Make it work like ffz so we will always get same size image if 4x doesn't exist if we notice that some images don't have 4x
        if (json is Godot.Collections.Array emotes)
        {
          foreach (Godot.Collections.Dictionary emote in emotes)
          {
            string id = (string)emote["id"];
            string emoteCode = (string)emote["name"];

            Godot.Collections.Array emoteUrls = (Godot.Collections.Array)emote["urls"];
            //Godot.Collections.Array imageUrlArray = (Godot.Collections.Array)emoteUrls[emoteUrls.Count - 1];
            //int scale = emoteUrls.Count - (emoteUrls.Count - 1);
            //int imageScale = int.Parse((string)imageUrlArray[0]);
            //string imageUrl = (string)imageUrlArray[1];

            Godot.Collections.Array[] imageUrlArrays = new Godot.Collections.Array[3]
            {
              (Godot.Collections.Array)emoteUrls[0],
              (Godot.Collections.Array)emoteUrls[1],
              (Godot.Collections.Array)emoteUrls[3],
            };

            string[] imageUrls = new string[3]
            {
              (string)imageUrlArrays[0][1],
              (string)imageUrlArrays[1][1],
              (string)imageUrlArrays[2][1]
            };

            Godot.Collections.Array visibilitySimple = (Godot.Collections.Array)emote["visibility_simple"];
            bool isZeroWidth = visibilitySimple.Contains("ZERO_WIDTH");

            Emote e = new Emote(emoteCode, imageUrls, id, EmoteProvider.SevenTV, 1, isZeroWidth);
            emotesDownloaded.Add(e);

            string emoteKey = e.ToString();
            if (!_emotes.ContainsKey(emoteKey))
            {
              AddEmote(emoteKey, e);
            }

            // if (!_emotes.ContainsKey(emoteCode))
            // {
            //   AddEmote(emoteCode, e);
            // }
          }
        }
      }
      return emotesDownloaded;
    }

    private async Task DownloadBadges(string channelId)
    {
      foreach (string endpoint in new string[] { $"badges/?broadcaster_id={channelId}", "badges/global" })
      {
        using (var request = new HttpRequestMessage(HttpMethod.Get, $"https://api.twitch.tv/helix/chat/{endpoint}"))
        {
          request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", OAuthToken);
          request.Headers.Add("Client-Id", ClientId);
          HttpResponseMessage response;
          try
          {
            response = await HttpClient.SendAsync(request);
          }
          catch (Exception exc)
          {
            Logger.Instance.Log(Logger.Levels.WARN, "TwitchClient", $"Request to badge endpoint: https://api.twitch.tv/helix/chat/badges timed out. Skipping...\n{exc}");
            return;
          }

          if (!response.IsSuccessStatusCode)
          {
            Logger.Instance.Log(Logger.Levels.WARN, "TwitchClient", $"Unhandled HTTP status code: {response.StatusCode}");
            return;
          }

          byte[] responseBody = await response.Content.ReadAsByteArrayAsync();
          Godot.Collections.Dictionary json = (Godot.Collections.Dictionary)JSON.Parse(responseBody.GetStringFromUTF8()).Result;
          Godot.Collections.Array data = (Godot.Collections.Array)json["data"];

          foreach (Godot.Collections.Dictionary chatBadgeSet in data)
          {
            string setId = (string)chatBadgeSet["set_id"];

            Godot.Collections.Array versions = (Godot.Collections.Array)chatBadgeSet["versions"];
            foreach (Godot.Collections.Dictionary version in versions)
            {
              string id = (string)version["id"];
              string key = $"{setId}:{id}";
              string[] imageUrls = new string[3] { (string)version["image_url_1x"], (string)version["image_url_2x"], (string)version["image_url_4x"] };

              if (!_badges.ContainsKey(key))
              {
                Badge badge = new Badge(setId, id, imageUrls);
                _badges.Add(key, badge);
              }
            }
          }
        }
      }
    }


    /// <summary>
    /// Wrapper to add emotes to either the <see cref="_emotes"/> or <see cref="_temporaryEmotes"/> dictionary. <br/>
    /// <paramref name="temporary"/>: If true, will be added to the <see cref="_temporaryEmotes"/> dictionary.
    /// </summary>
    /// <param name="temporary">If true, will be added to the <see cref="_temporaryEmotes"/> dictionary</param>
    /// <returns><see langword="true"/> if the key/value pair was added to the dictionary successfully; <see langword="false"/> if the key already exists.</returns>
    private bool AddEmote(string key, Emote emote, bool temporary = false)
    {
      bool success = temporary ? _temporaryEmotes.TryAdd(key, emote) : _emotes.TryAdd(key, emote);
      if (success) EmitSignal(temporary ? nameof(TemporaryEmoteAdded) : nameof(EmoteAdded), emote);

      return success;
    }

    /// <summary>
    /// Wrapper to remove emotes from either the <see cref="_emotes"/> or <see cref="_temporaryEmotes"/> dictionary. <br/>
    /// <paramref name="temporary"/>: If true, will be removed from the <see cref="_temporaryEmotes"/> dictionary.
    /// </summary>
    /// <param name="temporary">If true, will be removed from the <see cref="_temporaryEmotes"/> dictionary</param>
    /// <returns><see langword="true"/> if the emote was removed successfully; otherwise <see langword="false"/>.</returns>
    private bool RemoveEmote(string key, bool temporary = false)
    {
      Emote emote;
      bool success = temporary ? _temporaryEmotes.TryRemove(key, out emote) : _emotes.TryRemove(key, out emote);
      if (success) EmitSignal(temporary ? nameof(TemporaryEmoteRemoved) : nameof(EmoteRemoved), emote);

      return success;
    }

    private Emote AddOrUpdateEmote(string key, Emote emote, Func<string, Emote, Emote> updateValueFactory)
    {
      Emote result = _emotes.AddOrUpdate(key, emote, updateValueFactory);

      if (result == emote)
      {
        EmitSignal(nameof(EmoteAdded), result);
      }
      else
      {
        EmitSignal(nameof(EmoteUpdated), emote, result);
      }

      return result;
    }
  }
}
