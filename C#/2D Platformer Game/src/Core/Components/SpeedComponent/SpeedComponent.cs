using Godot;
using ECS;

namespace Core.ECS
{
  public partial class SpeedComponent : Component
  {
    [Export]
    public float Speed { get; set; } = 0F;
  }
}
