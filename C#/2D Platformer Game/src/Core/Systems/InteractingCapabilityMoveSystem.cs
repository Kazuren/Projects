using Godot;
using System;
using System.Collections.Generic;
using ECS;
using EntityComponentSystem = ECS;

namespace Core.ECS
{
  public partial class InteractingCapabilityMoveSystem : EntityComponentSystem.System
  {
    public InteractingCapabilityMoveSystem()
    {
      ComponentSet = new ComponentSet()
      {
        Requirements = new HashSet<int>() { TypeId<InteractingCapabilityComponent>.Get(), TypeId<TransformComponent>.Get() },
        Restrictions = new HashSet<int>() { }
      };
    }

    public override void PhysicsUpdate(double delta)
    {
      foreach (Entity entity in Entities)
      {
        TransformComponent transformComponent = entity.GetComponent<TransformComponent>();
        InteractingCapabilityComponent interactingCapabilityComponent = entity.GetComponent<InteractingCapabilityComponent>();

        interactingCapabilityComponent.Area2D.Transform = transformComponent.Transform;
      }
    }

  }
}
