using Godot;
using System;
using System.Collections.Generic;
using ECS;
using EntityComponentSystem = ECS;

namespace Core.ECS
{
  public partial class JumpingCapabilitySystem : EntityComponentSystem.System
  {
    public JumpingCapabilitySystem()
    {
      ComponentSet = new ComponentSet()
      {
        Requirements = new HashSet<int>() { TypeId<JumpingCapabilityComponent>.Get(), TypeId<CharacterBodyComponent>.Get(), TypeId<VelocityComponent>.Get() },
        Restrictions = new HashSet<int>() { }
      };
    }

    public override void PhysicsUpdate(double delta)
    {
      foreach (Entity entity in Entities)
      {

      }
    }

    public override void OnEntityAdded(Entity entity)
    {
      JumpingCapabilityComponent jumpingCapabilityComponent = entity.GetComponent<JumpingCapabilityComponent>();
      CharacterBodyComponent characterBodyComponent = entity.GetComponent<CharacterBodyComponent>();


      //characterBodyComponent.Connect(CharacterBodyComponent.SignalName.TouchedFloor, Callable.From<Entity>(OnTouchedFloor));

      //characterBodyComponent.TouchedFloor.Connect()

      characterBodyComponent.TouchedFloor += OnTouchedFloor;
      characterBodyComponent.LeftFloor += OnLeftFloor;

    }


    public override void OnEntityRemoved(Entity entity)
    {
      TransformComponent transformComponent = entity.GetComponent<TransformComponent>();

      if (entity.HasComponent<CharacterBodyComponent>())
      {
        CharacterBodyComponent characterBodyComponent = entity.GetComponent<CharacterBodyComponent>();

        characterBodyComponent.TouchedFloor -= OnTouchedFloor;
        characterBodyComponent.LeftFloor -= OnLeftFloor;
      }

    }

    public void OnTouchedFloor(Entity entity)
    {
      JumpingCapabilityComponent jumpingCapabilityComponent = entity.GetComponent<JumpingCapabilityComponent>();

      jumpingCapabilityComponent.JumpsRemaining = jumpingCapabilityComponent.MaxJumps;
    }

    public void OnLeftFloor(Entity entity)
    {
      VelocityComponent velocityComponent = entity.GetComponent<VelocityComponent>();
      JumpingCapabilityComponent jumpingCapabilityComponent = entity.GetComponent<JumpingCapabilityComponent>();

      // if we're not going upwards
      if (velocityComponent.Velocity.Y >= 0)
      {
        entity.TryAddComponent<CoyoteComponent>();
      }
      // if we didn't leave the floor by jumping
      else if (!entity.HasComponent<JumpingComponent>())
      {
        jumpingCapabilityComponent.JumpsRemaining -= 1;

      }

      //JumpingCapabilityComponent jumpingCapabilityComponent = entity.GetComponent<JumpingCapabilityComponent>();

      //jumpingCapabilityComponent.JumpsRemaining -= 1;
    }
  }
}
