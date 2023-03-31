using Godot;
using Core;
using Core.ECS;
using ECS;


namespace Core.ECS;

public partial class AnimationComponent : Component
{
  public AnimationComponent() : base()
  {
  }

  public override void _Ready()
  {
    base._Ready();
    AnimationPlayer = GetNode<AnimationPlayer>("%AnimationPlayer");
    AnimationTree = GetNode<AnimationTree>("%AnimationTree");
  }

  public AnimationPlayer AnimationPlayer { get; set; }
  public AnimationTree AnimationTree { get; set; }

  public override void OnComponentAdded(Entity entity)
  {
  }

  public override void OnComponentRemoved(Entity entity)
  {

  }
}

