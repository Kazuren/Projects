using Godot;
using ImageMagick;
using System.Collections.Generic;

using System;
using System.Threading;
using System.Diagnostics;
using System.Threading.Tasks;
using System.Threading.Tasks.Dataflow;

namespace Twitch
{
  public static class ImageConverter
  {

    static ImageConverter()
    {
      _transformBlock = new TransformBlock<byte[], ImageTexture[]>(
        bytes => _createTexturesFromBytes(bytes),
        new ExecutionDataflowBlockOptions
        {
          BoundedCapacity = -1,
          MaxDegreeOfParallelism = 1,
          CancellationToken = CancellationToken.None
        }
      );
    }
    private static TransformBlock<byte[], ImageTexture[]> _transformBlock;

    public static async Task<ImageTexture[]> CreateTexturesFromBytes(byte[] bytes)
    {
      // await _transformBlock.SendAsync(bytes);

      // return await _transformBlock.ReceiveAsync();
      try
      {
        await _transformBlock.SendAsync(bytes);

        return await _transformBlock.ReceiveAsync();
      }
      catch (Exception exc)
      {
        GD.Print(exc);
        throw exc;
      }
    }

    private static ImageTexture[] _createTexturesFromBytes(byte[] bytes)
    {
      try
      {
        List<ImageTexture> textures = new List<ImageTexture>();
        using (MagickImageCollection images = new MagickImageCollection(bytes))
        {
          images.Coalesce();

          foreach (IMagickImage frame in images)
          {
            frame.Format = MagickFormat.WebP;
            float animationDelay = frame.AnimationDelay / 100F;
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
            texture.CreateFromImage(image, (uint)(Godot.Texture.FlagsEnum.Filter | Godot.Texture.FlagsEnum.Mipmaps | Godot.Texture.FlagsEnum.AnisotropicFilter));
            textures.Add(texture);
          }
        }
        return textures.ToArray();
      }
      catch (Exception exc)
      {
        Logger.Instance.Log(Logger.Levels.ERROR, "ImageConverter", exc.ToString());
        throw exc;
      }
    }
  }
}
