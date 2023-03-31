using Godot;
using Core;
using Core.ECS;
using ECS;

namespace Core.ECS
{
  public partial class RenderingComponent : Component
  {
    public Sprite2D Sprite { get; set; }
    public RenderingComponent() : base()
    {
    }

    public override void _Ready()
    {
      base._Ready();
      Sprite = GetNode<Sprite2D>("%Sprite");
      Sprite.Visible = false;

    }

    public void SetTexture(Texture2D texture)
    {
      Sprite = GetNode<Sprite2D>("%Sprite");
      Sprite.Texture = texture;
      Sprite.TextureFilter = CanvasItem.TextureFilterEnum.LinearWithMipmaps;
    }
  }
}
