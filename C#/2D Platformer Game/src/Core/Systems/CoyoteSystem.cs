using Godot;
using System;
using System.Collections.Generic;
using ECS;
using EntityComponentSystem = ECS;

namespace Core.ECS
{
  public partial class CoyoteSystem : EntityComponentSystem.System
  {
    public CoyoteSystem()
    {
      ComponentSet = new ComponentSet()
      {
        Requirements = new HashSet<int>() {
          TypeId<AirborneComponent>.Get(),
          TypeId<JumpingCapabilityComponent>.Get(),
          TypeId<VelocityComponent>.Get(),
          TypeId<CoyoteComponent>.Get(),
          TypeId<WalkingComponent>.Get()
        },
        Restrictions = new HashSet<int>()
        {
          TypeId<JumpingComponent>.Get()
        }
      };
    }

    public override void PhysicsUpdate(double delta)
    {
      foreach (Entity entity in Entities)
      {
        JumpingCapabilityComponent jumpingCapabilityComponent = entity.GetComponent<JumpingCapabilityComponent>();
        AirborneComponent airborneComponent = entity.GetComponent<AirborneComponent>();
        VelocityComponent velocityComponent = entity.GetComponent<VelocityComponent>();

        if (airborneComponent.Airtime <= jumpingCapabilityComponent.CoyoteTime)
        {
          velocityComponent.Velocity = velocityComponent.Velocity with { Y = 0 };
        }
        else
        {
          entity.RemoveComponent<CoyoteComponent>();
        }
      }
    }

    public override void OnEntityAdded(Entity entity)
    {
    }


    public override void OnEntityRemoved(Entity entity)
    {
      if (entity.HasComponent<CoyoteComponent>())
      {
        entity.RemoveComponent<CoyoteComponent>();
      }

      if (!entity.HasComponent<JumpingCapabilityComponent>()) { return; }

      if (!entity.HasComponent<JumpingComponent>())
      {
        JumpingCapabilityComponent jumpingCapabilityComponent = entity.GetComponent<JumpingCapabilityComponent>();
        jumpingCapabilityComponent.JumpsRemaining -= 1;
      }
    }

  }
}
