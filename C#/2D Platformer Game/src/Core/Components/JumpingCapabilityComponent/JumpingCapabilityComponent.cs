using Godot;
using ECS;

namespace Core.ECS
{
  public partial class JumpingCapabilityComponent : Component
  {
    [Export]
    public float MaxJumpVelocity { get; set; } = 0F;

    [Export]
    public float MinJumpVelocity { get; set; } = 0F;

    [Export]
    public float JumpBuffer { get; set; } = 0F;

    [Export]
    public float StallTime { get; set; } = 0F;

    [Export]
    public float CoyoteTime { get; set; } = 0F;

    [Export]
    public int MaxJumps { get; set; } = 1;

    public int JumpsRemaining { get; set; }

    public JumpingCapabilityComponent()
    {
      JumpsRemaining = MaxJumps;
    }
  }
}
