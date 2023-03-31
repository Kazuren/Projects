using Godot;
using ECS;

namespace Core.ECS;

public partial class StaticBodyComponent : Component
{
  public StaticBody2D Body;

  public override void _Ready()
  {
    Body = GetNode<StaticBody2D>("%StaticBody2D");
  }
}

