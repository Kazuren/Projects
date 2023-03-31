using Godot;
using System;
using System.Collections.Generic;

using Core.Commands;

using System.Linq;
using ECS;
using EntityComponentSystem = ECS;

namespace Core.ECS
{
  public partial class JumpingSystem : EntityComponentSystem.System
  {
    public JumpingSystem()
    {
      ComponentSet = new ComponentSet()
      {
        Requirements = new HashSet<int> {
          TypeId<VelocityComponent>.Get(),
          TypeId<JumpingComponent>.Get(),
          TypeId<JumpingCapabilityComponent>.Get(),
          TypeId<CommandListenerComponent>.Get(),
          TypeId<CharacterBodyComponent>.Get(),
        },
        Restrictions = new HashSet<int> { }
      };
    }

    public override void PhysicsUpdate(double delta)
    {
      foreach (Entity entity in Entities)
      {
        CommandListenerComponent commandListenerComponent = entity.GetComponent<CommandListenerComponent>();
        VelocityComponent velocityComponent = entity.GetComponent<VelocityComponent>();
        CharacterBodyComponent characterBodyComponent = entity.GetComponent<CharacterBodyComponent>();
        JumpingComponent jumpingComponent = entity.GetComponent<JumpingComponent>();

        CharacterBody2D body = characterBodyComponent.Body;

        if (velocityComponent.Velocity.Y >= 0)
        {
          jumpingComponent.StallTimeLeft -= (float)delta;

          velocityComponent.Velocity = velocityComponent.Velocity with { Y = 0 };

          if (jumpingComponent.StallTimeLeft <= 0)
          {
            entity.TryRemoveComponent<JumpingComponent>();
          }
        }
      }
    }

    public override void PhysicsFrameEnd(double delta)
    {
      foreach (Entity entity in Entities)
      {
        // CharacterBodyComponent characterBodyComponent = entity.GetComponent<CharacterBodyComponent>();
        // CharacterBody2D body = characterBodyComponent.Body;

        // if (body.IsOnFloor())
        // {
        //   entity.TryRemoveComponent<JumpingComponent>();
        // }
      }
    }

    public override void OnEntityAdded(Entity entity)
    {
      JumpingCapabilityComponent jumpingCapabilityComponent = entity.GetComponent<JumpingCapabilityComponent>();
      JumpingComponent jumpingComponent = entity.GetComponent<JumpingComponent>();
      jumpingComponent.StallTimeLeft = jumpingCapabilityComponent.StallTime;


      CharacterBodyComponent characterBodyComponent = entity.GetComponent<CharacterBodyComponent>();


      characterBodyComponent.TouchedFloor += OnTouchedFloor;
    }

    public override void OnEntityRemoved(Entity entity)
    {
      if (entity.HasComponent<CharacterBodyComponent>())
      {
        CharacterBodyComponent characterBodyComponent = entity.GetComponent<CharacterBodyComponent>();
        characterBodyComponent.TouchedFloor -= OnTouchedFloor;
      }
    }

    private void OnTouchedFloor(Entity entity)
    {
      entity.TryRemoveComponent<JumpingComponent>();
    }
  }
}
