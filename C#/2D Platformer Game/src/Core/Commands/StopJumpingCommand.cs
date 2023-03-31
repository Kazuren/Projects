using Godot;
using System.Text.Json.Serialization;

using Core.ECS;
using ECS;

namespace Core.Commands;

public class StopJumpingCommand : Command
{
  //public float Direction { get; private set; }

  public StopJumpingCommand()
  {

  }
  public override void Execute(Entity entity)
  {
    if (!entity.HasComponent<JumpingComponent>()) { return; }

    VelocityComponent velocityComponent = entity.GetComponent<VelocityComponent>();
    JumpingCapabilityComponent jumpingCapabilityComponent = entity.GetComponent<JumpingCapabilityComponent>();

    entity.RemoveComponent<JumpingComponent>();

    if (velocityComponent.Velocity.Y < jumpingCapabilityComponent.MinJumpVelocity)
    {
      velocityComponent.Velocity = velocityComponent.Velocity with { Y = jumpingCapabilityComponent.MinJumpVelocity };
    }


    OnCommandExecuted(this);
  }

  public override int GetHashCode()
  {
    return this.GetType().AssemblyQualifiedName.GetHashCode();
  }
}
