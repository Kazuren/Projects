using Godot;
using ImageMagick;
using System.Collections.Generic;

using System;
using System.Threading;
using System.Diagnostics;
using System.Threading.Tasks;
using System.Threading.Tasks.Dataflow;

using System.Linq;


namespace Twitch
{
  public class Emote : Godot.Reference
  {
    /// <summary>
    /// The maximum lifetime of the Emote before the <see cref="Textures"/> List gets cleared. <br/>
    /// </summary>
    private const float MaximumLifetime = 3600; // 1 Hour

    private static TransformBlock<DownloadParameters, TexturePair> _emoteTextureProducer;

    static Emote()
    {
      _emoteTextureProducer = new TransformBlock<DownloadParameters, TexturePair>(
        p => Download(p.Emote, p.scale),
        new ExecutionDataflowBlockOptions
        {
          BoundedCapacity = -1,
          MaxDegreeOfParallelism = Math.Max(1, System.Environment.ProcessorCount - 1),
          CancellationToken = CancellationToken.None
        }
      );
    }

    public static string GenerateEmoteKey(string code, string id, EmoteProvider provider)
    {
      return $"{code}:{provider}:{id}";
    }

    public Emote(string code, string[] imageUrls, string id, EmoteProvider provider, int scale = 1, bool zeroWidth = false)
    {
      Code = code;
      ImageUrls = imageUrls;
      Id = id;
      Provider = provider;
      Scale = scale;
      ZeroWidth = zeroWidth;
    }

    private class TexturePair
    {
      public ImageTexture Texture { get; set; }
      public ImageTexture Texture2D { get; set; }
    };
    private class DownloadParameters
    {
      public Emote Emote { get; set; }
      public int scale { get; set; }
    }

    public ImageTexture Texture
    {
      get =>
        TextureLists[2].Count == Frames[2] ? TextureLists[2][GetCurrentFrame(3)] :
        TextureLists[1].Count == Frames[1] ? TextureLists[1][GetCurrentFrame(2)] :
        TextureLists[0].Count == Frames[0] ? TextureLists[0][GetCurrentFrame(1)] : null;
    }
    public ImageTexture Texture2D
    {
      get =>
        TextureLists2D[2].Count == Frames[2] ? TextureLists2D[2][GetCurrentFrame(3)] :
        TextureLists2D[1].Count == Frames[1] ? TextureLists2D[1][GetCurrentFrame(2)] :
        TextureLists2D[0].Count == Frames[0] ? TextureLists2D[0][GetCurrentFrame(1)] : null;
    }

    /// <summary>
    /// The lifetime of the Emote. The <see cref="Textures"/> List gets cleared if it's less than zero. <br/>
    /// Gets reset when the emote's <see cref="Texture"/> is get.
    /// </summary>
    public float Lifetime { get; private set; } = MaximumLifetime;
    public string Id { get; private set; }
    public EmoteProvider Provider { get; private set; }
    public string Code { get; private set; }
    public int Scale { get; private set; } = 1;
    public bool ZeroWidth { get; private set; } = false;
    public bool QueuedForDeletion { get; private set; } = false;
    public bool CurrentlyInUse
    {
      get => References > 0;
    }
    public uint References { get; set; } = 0;

    public List<ImageTexture>[] TextureLists { get; private set; } = new List<ImageTexture>[3]
    {
      new List<ImageTexture>(),
      new List<ImageTexture>(),
      new List<ImageTexture>()
    };
    public List<ImageTexture>[] TextureLists2D { get; private set; } = new List<ImageTexture>[3]
    {
      new List<ImageTexture>(),
      new List<ImageTexture>(),
      new List<ImageTexture>()
    };

    public int[] Frames { get; private set; } = new int[3] { -1, -1, -1 };
    public float TotalAnimationTime { get; private set; } = -1.0F;
    public float AnimationTime { get; private set; } = 0.0F;

    //TODO: somehow cache for the frame if performance becomes troublesome?
    public int GetCurrentFrame(int scale = 3)
    {
      List<ImageTexture> textureList = TextureLists[scale - 1];
      if (textureList.Count != Frames[scale - 1]) { return -1; }
      float timeCount = 0.0F;
      int i = 0;

      while (timeCount < AnimationTime)
      {
        ImageTexture texture = textureList[i];

        timeCount += (float)texture.GetMeta("AnimationDelay", 0.0F);
        if (timeCount > AnimationTime || Mathf.IsEqualApprox(timeCount, AnimationTime)) { return i; }
        else { i++; } //(i + 1) % textureList.Count
      }

      return i;
    }

    public string[] ImageUrls { get; private set; }

    private Task<TexturePair>[] _downloadTasks = new Task<TexturePair>[3];

    public void Update(float delta)
    {
      IEnumerable<List<ImageTexture>> textureLists = TextureLists.Concat(TextureLists2D);
      //List<EmoteTexture> textureList = textureLists.FirstOrDefault(t => t.Count > 0);
      bool texturesExist = TextureLists.Any(l => l.Count > 0);

      if (texturesExist)
      {
        Lifetime -= delta;
        if (Lifetime <= 0)
        {
          foreach (List<ImageTexture> list in textureLists)
          {
            Frames = new int[3] { -1, -1, -1 };
            TotalAnimationTime = -1.0F;
            AnimationTime = 0.0F;
            list.Clear();
          }
          Logger.Instance.Log(Logger.Levels.INFO, "TwitchEmote", $"Deleted {this}'s texture because it exceeded its lifetime.");
          if (Provider == EmoteProvider.Twitch)
          {
            QueueForDeletion();
            Logger.Instance.Log(Logger.Levels.INFO, "TwitchEmote", $"Also queued {this} for deletion because it's a twitch emote.");
          }
        }
      }

      if (CurrentlyInUse && TotalAnimationTime > 0 && Frames.Any(f => f > 1))
      {
        AnimationTime = (AnimationTime + delta) % TotalAnimationTime;
      }
    }

    public ImageTexture GetTexture(int scale = 3)
    {
      List<ImageTexture> textureList = TextureLists[scale - 1];
      Task<TexturePair> downloadTask = _downloadTasks[scale - 1];

      Lifetime = MaximumLifetime;

      if (scale < 1) { return null; }

      if (textureList.Count == Frames[scale - 1])
      {
        return textureList[GetCurrentFrame(scale)];
      }

      if (downloadTask == null || downloadTask.IsCompleted)
      {
        bool accepted = _emoteTextureProducer.Post(new DownloadParameters
        {
          Emote = this,
          scale = scale
        });
        if (accepted)
        {
          _downloadTasks[scale - 1] = _emoteTextureProducer.ReceiveAsync();
        }
        else
        {
          throw new Exception("TextureProducer didn't accept item");
        }
      }

      return null;
    }

    public ImageTexture GetTexture2D(int scale = 3)
    {
      List<ImageTexture> textureList = TextureLists2D[scale - 1];
      Task<TexturePair> downloadTask = _downloadTasks[scale - 1];

      Lifetime = MaximumLifetime;

      if (scale < 1) { return null; }

      if (textureList.Count == Frames[scale - 1])
      {
        return textureList[GetCurrentFrame(scale)];
      }

      if (downloadTask == null || downloadTask.IsCompleted)
      {
        bool accepted = _emoteTextureProducer.Post(new DownloadParameters
        {
          Emote = this,
          scale = scale
        });
        if (accepted)
        {
          _downloadTasks[scale - 1] = _emoteTextureProducer.ReceiveAsync();
        }
        else
        {
          throw new Exception("TextureProducer didn't accept item");
        }
      }

      return null;
    }

    public async Task<ImageTexture> GetTextureAsync(int scale = 3)
    {
      List<ImageTexture> textureList = TextureLists[scale - 1];
      Task<TexturePair> downloadTask = _downloadTasks[scale - 1];

      Lifetime = MaximumLifetime;

      if (textureList.Count == Frames[scale - 1])
      {
        return textureList[GetCurrentFrame(scale)]; ;
      }

      if (downloadTask != null && !downloadTask.IsCompleted)
      {
        TexturePair texturePair = await downloadTask;
        return texturePair.Texture;
      }
      else
      {
        await _emoteTextureProducer.SendAsync(new DownloadParameters
        {
          Emote = this,
          scale = scale
        });
        _downloadTasks[scale - 1] = _emoteTextureProducer.ReceiveAsync();
        TexturePair texturePair = await _downloadTasks[scale - 1];
        return texturePair.Texture;
      }
    }

    public async Task<ImageTexture> GetTexture2DAsync(int scale = 3)
    {
      List<ImageTexture> textureList = TextureLists2D[scale - 1];
      Task<TexturePair> downloadTask = _downloadTasks[scale - 1];

      Lifetime = MaximumLifetime;

      if (textureList.Count == Frames[scale - 1])
      {
        return textureList[GetCurrentFrame(scale)];
      }

      if (downloadTask != null && !downloadTask.IsCompleted)
      {
        TexturePair texturePair = await downloadTask;
        return texturePair.Texture2D;
      }
      else
      {
        await _emoteTextureProducer.SendAsync(new DownloadParameters
        {
          Emote = this,
          scale = scale
        });
        _downloadTasks[scale - 1] = _emoteTextureProducer.ReceiveAsync();
        TexturePair texturePair = await _downloadTasks[scale - 1];
        return texturePair.Texture2D;
      }
    }

    /// <summary>
    /// Downloads an emote and creates a list of textures from that emote
    /// </summary>
    private static async Task<TexturePair> Download(Emote emote, int scale = 3)
    {
      try
      {
        emote.Lifetime = MaximumLifetime;

        byte[] responseBody = await Twitch.Client.HttpClient.GetByteArrayAsync(emote.ImageUrls[scale - 1]);

        bool isNew = emote.TotalAnimationTime == -1;

        List<ImageTexture> textureList = emote.TextureLists[scale - 1];
        List<ImageTexture> textureList2D = emote.TextureLists2D[scale - 1];

        textureList.Clear();
        textureList2D.Clear();

        List<ImageTexture> textures = new List<ImageTexture>();

        // TODO write our own image reader to detect JPG/PNG/GIF/WEBP and feed the resulting data to Godot directly instead of going through ImageMagick
        // bonus is that we can uninstall image magick then

        using (MagickImageCollection images = new MagickImageCollection(responseBody))
        {
          images.Coalesce();
          foreach (IMagickImage frame in images)
          {
            frame.Format = MagickFormat.WebP;
            float animationDelay = frame.AnimationDelay / 100F;

            // takes 1-15ms
            byte[] frameBytes = frame.ToByteArray();

            // Browsers do this for frames that have a delay time <= 0.01
            // So to replicate browsers, we do the same as well.
            if (animationDelay <= 0.01)
            {
              animationDelay = 0.1F;
            }

            Godot.Image image = new Godot.Image();
            image.LoadWebpFromBuffer(frameBytes);

            ImageTexture texture = new ImageTexture();
            texture.SetMeta("AnimationDelay", animationDelay);

            // takes 0-6ms
            texture.CreateFromImage(image, (uint)(Godot.Texture.FlagsEnum.Filter | Godot.Texture.FlagsEnum.Mipmaps | Godot.Texture.FlagsEnum.AnisotropicFilter));
            textures.Add(texture);
          }
        }

        //ImageTexture[] textures = await ImageConverter.CreateTexturesFromBytes(responseBody);

        // TODO make above be "CreateImagesFromBytes"
        // and we create the textures here, because we need to duplicate textures for 2D usage

        Logger.Instance.Log(Logger.Levels.INFO, "TwitchEmote", $"Downloaded and processed emote: {emote}");

        foreach (ImageTexture texture in textures)
        {
          ImageTexture texture2D = (ImageTexture)texture.Duplicate();
          float animationDelay = (float)texture.GetMeta("AnimationDelay", 0.0F);
          texture2D.SetMeta("AnimationDelay", animationDelay);
          textureList.Add(texture);
          textureList2D.Add(texture2D);
        }

        emote.Frames[scale - 1] = textures.Count;

        if (isNew)
        {
          emote.TotalAnimationTime = textureList.Sum(texture => (float)texture.GetMeta("AnimationDelay", 0.0F));
        }

        return new TexturePair()
        {
          Texture = textureList[emote.GetCurrentFrame(scale)],
          Texture2D = textureList2D[emote.GetCurrentFrame(scale)]
        };
      }
      catch (Exception exc)
      {
        Logger.Instance.Log(Logger.Levels.ERROR, "TwitchEmote", exc.ToString());
        // TODO: maybe throw exception instead and require whoever uses this function to try catch
        // ! Anything that expects a texture pair with not null textures will crash! e.g Main.cs "Twitch.EmoteTexture emoteTexture = await twitchEmote.GetTextureAsync(3);"
        return new TexturePair();
      }
    }

    /// <summary>
    /// Queues the emote for deletion by the <see cref="Twitch.Client"/>
    /// </summary>
    public void QueueForDeletion()
    {
      QueuedForDeletion = true;
    }

    public override string ToString()
    {
      return $"{Code}:{Provider}:{Id}";
    }
  }
}
