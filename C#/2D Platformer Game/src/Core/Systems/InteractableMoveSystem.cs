using Godot;
using System;
using System.Collections.Generic;
using ECS;
using EntityComponentSystem = ECS;


namespace Core.ECS
{
  public partial class InteractableMoveSystem : EntityComponentSystem.System
  {
    public InteractableMoveSystem()
    {
      ComponentSet = new ComponentSet()
      {
        Requirements = new HashSet<int>() { TypeId<InteractableComponent>.Get(), TypeId<TransformComponent>.Get() },
        Restrictions = new HashSet<int>() { }
      };
    }

    public override void PhysicsUpdate(double delta)
    {
      foreach (Entity entity in Entities)
      {
        TransformComponent transformComponent = entity.GetComponent<TransformComponent>();
        InteractableComponent interactableComponent = entity.GetComponent<InteractableComponent>();

        interactableComponent.Area2D.Transform = transformComponent.Transform;
      }
    }
  }
}
