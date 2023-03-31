using Godot;
using System.Text.Json.Serialization;

using Core.ECS;
using ECS;

namespace Core.Commands;

public class MoveCommand : Command
{
  public float Direction { get; private set; }

  public MoveCommand(float direction)
  {
    Direction = direction;
  }
  public override void Execute(Entity entity)
  {
    VelocityComponent velocityComponent = entity.GetComponent<VelocityComponent>();
    SpeedComponent speedComponent = entity.GetComponent<SpeedComponent>();

    velocityComponent.Velocity = velocityComponent.Velocity with { X = Direction * speedComponent.Speed };

    if (!entity.HasComponent<WalkingComponent>())
    {
      entity.AddComponentImmediate<WalkingComponent>();
    }

    OnCommandExecuted(this);
  }

  public override int GetHashCode()
  {
    return this.GetType().AssemblyQualifiedName.GetHashCode();
  }
}
