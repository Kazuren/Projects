using Godot;
using Core;
using Core.ECS;
using ECS;

namespace Core.ECS
{
  public partial class CameraComponent : Component
  {
    public const int PIXELS_PER_PIXEL = 3;
    public CameraComponent() : base()
    {
    }

    public override void _Ready()
    {
      base._Ready();
      Camera = GetNode<Camera2D>("%Camera2D");
      float factor = 1.0F / PIXELS_PER_PIXEL;
      Camera.Zoom = new Vector2(factor, factor);
    }

    public Camera2D Camera { get; set; }

    public override void OnComponentAdded(Entity entity)
    {
      Camera.Enabled = true;
    }

    public override void OnComponentRemoved(Entity entity)
    {
      Camera.Enabled = false;
    }

    public void SetZoom()
    {

    }
  }
}
