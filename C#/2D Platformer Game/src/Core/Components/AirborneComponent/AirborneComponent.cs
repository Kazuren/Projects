using Godot;
using ECS;

namespace Core.ECS
{
  public partial class AirborneComponent : Component
  {
    public float Airtime { get; set; } = 0F;

    public override void Reset()
    {
      Airtime = 0F;
      base.Reset();
    }
  }
}
