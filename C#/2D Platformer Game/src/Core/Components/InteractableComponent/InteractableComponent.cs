using Godot;
using ECS;

namespace Core.ECS
{
  public partial class InteractableComponent : Component
  {
    public Area2D Area2D;

    public override void _Ready()
    {
      base._Ready();
      Area2D = GetNode<Area2D>("%Area2D");
    }
  }
}
