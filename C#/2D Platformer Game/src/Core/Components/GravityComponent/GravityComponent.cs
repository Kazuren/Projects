using Godot;
using ECS;

namespace Core.ECS
{
  public partial class GravityComponent : Component
  {
    [Export]
    public float UpGravity { get; set; } = 0F;

    [Export]
    public float DownGravity { get; set; } = 0F;
  }
}
