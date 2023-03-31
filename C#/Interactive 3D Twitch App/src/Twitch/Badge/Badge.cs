using Godot;
using System;
using ImageMagick;

using System.Threading.Tasks;

namespace Twitch
{
  public class Badge
  {
    public Badge(string setId, string id, string[] imageUrls, Provider provider = Provider.Twitch)
    {
      SetId = setId;
      Id = id;
      if (imageUrls.Length != 3) { throw new Exception("ImageUrl Array Length != 3"); }
      ImageUrls = imageUrls;
    }
    public string SetId { get; private set; }
    public string Id { get; private set; }
    public Provider Provider { get; private set; } = Provider.Twitch;
    public string[] ImageUrls { get; private set; }
    public ImageTexture[] Textures { get; private set; } = new ImageTexture[3];
    private Task<ImageTexture>[] _downloadTasks = new Task<ImageTexture>[3];

    /// <summary>
    /// Downloads the badge and creates a texture from it.
    /// </summary>
    private async Task<ImageTexture> Download(int scale = 3)
    {
      try
      {
        byte[] responseBody = await Twitch.Client.HttpClient.GetByteArrayAsync(ImageUrls[scale - 1]);

        Image image = new Godot.Image();
        image.LoadPngFromBuffer(responseBody);

        ImageTexture texture = new ImageTexture();
        texture.CreateFromImage(image, (uint)(Godot.Texture.FlagsEnum.Filter | Godot.Texture.FlagsEnum.Mipmaps | Godot.Texture.FlagsEnum.AnisotropicFilter));
        Textures[scale - 1] = texture;
        return texture;
      }
      catch (Exception exc)
      {
        Logger.Instance.Log(Logger.Levels.ERROR, "TwitchBadge", exc.ToString());
        return null;
      }
    }

    public async Task<ImageTexture> GetTextureAsync(int scale = 3)
    {
      Task<ImageTexture> downloadTask = _downloadTasks[scale - 1];

      if (Textures[scale - 1] != null) { return Textures[scale - 1]; }

      if (downloadTask != null && !downloadTask.IsCompleted)
      {
        return await downloadTask;
      }
      else
      {
        downloadTask = Task.Run(() => Download(scale));
        _downloadTasks[scale - 1] = downloadTask;
        return await downloadTask;
      }
    }

    public override string ToString()
    {
      return $"{SetId}:{Id}:{Provider}";
    }
  }
}
