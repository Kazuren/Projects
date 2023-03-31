using Godot;
using Core;
using Core.ECS;

using ECS;

namespace Core.ECS
{
  public partial class CharacterBodyComponent : Component
  {
    [Signal]
    public delegate void TouchedFloorEventHandler(Entity entity);

    [Signal]
    public delegate void LeftFloorEventHandler(Entity entity);

    public CharacterBody2D Body { get; set; }

    public override void _Ready()
    {
      Body = GetNode<CharacterBody2D>("%CharacterBody2D");
    }

    public override void Reset()
    {
      backing_TouchedFloor = null;
      backing_LeftFloor = null;
    }
  }
}
