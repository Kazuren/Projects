using Godot;
using System;
using System.Collections.Generic;

using Core.Commands;
using ECS;
using EntityComponentSystem = ECS;

namespace Core.ECS
{
  public partial class WalkSystem : EntityComponentSystem.System
  {
    public WalkSystem()
    {
      ComponentSet = new ComponentSet()
      {
        Requirements = new HashSet<int> {
          TypeId<CommandListenerComponent>.Get(),
          TypeId<WalkingComponent>.Get(),
          TypeId<VelocityComponent>.Get()
    },
        Restrictions = new HashSet<int> { }
      };
    }

    public override void PhysicsUpdate(double delta)
    {

      foreach (Entity entity in Entities)
      {
        CommandListenerComponent commandListenerComponent = entity.GetComponent<CommandListenerComponent>();
        if (!commandListenerComponent.HasCommand<MoveCommand>())
        {
          entity.RemoveComponent<WalkingComponent>();
        }
      }
    }

    public override void OnEntityAdded(Entity entity)
    {

    }

    public override void OnEntityRemoved(Entity entity)
    {
      if (entity.HasComponent<VelocityComponent>())
      {
        VelocityComponent velocityComponent = entity.GetComponent<VelocityComponent>();

        velocityComponent.Velocity = velocityComponent.Velocity with { X = 0 };
      }
    }
  }
}
