using Godot;
using ECS;

namespace Core.ECS
{
  public partial class VelocityComponent : Component
  {
    public Vector2 Velocity { get; set; } = Vector2.Zero;
  }
}
