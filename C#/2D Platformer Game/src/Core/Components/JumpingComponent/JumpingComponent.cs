using Godot;
using Core;
using Core.ECS;
using ECS;

namespace Core.ECS
{
  public partial class JumpingComponent : Component
  {
    public float StallTimeLeft { get; set; } = 0F;
  }
}
