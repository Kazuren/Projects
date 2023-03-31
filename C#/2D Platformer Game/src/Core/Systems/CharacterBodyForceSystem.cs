using Godot;
using System;
using System.Collections.Generic;

using Core.Commands;
using ECS;
using EntityComponentSystem = ECS;


namespace Core.ECS
{
  public partial class CharacterBodyForceSystem : EntityComponentSystem.System
  {
    public CharacterBodyForceSystem()
    {
      ComponentSet = new ComponentSet()
      {
        Requirements = new HashSet<int> {
          TypeId<CharacterBodyComponent>.Get(),
          TypeId<TransformComponent>.Get(),
          TypeId<VelocityComponent>.Get()
        },
        Restrictions = new HashSet<int> { }
      };
    }

    public override void PhysicsUpdate(double delta)
    {
      foreach (Entity entity in Entities)
      {
        CharacterBodyComponent characterBodyComponent = entity.GetComponent<CharacterBodyComponent>();
        TransformComponent transformComponent = entity.GetComponent<TransformComponent>();
        VelocityComponent velocityComponent = entity.GetComponent<VelocityComponent>();

        CharacterBody2D body = characterBodyComponent.Body;

        body.Velocity = velocityComponent.Velocity;

        bool wasOnFloor = body.IsOnFloor();

        body.MoveAndSlide();

        bool isOnFloor = body.IsOnFloor();

        velocityComponent.Velocity = body.GetRealVelocity();

        transformComponent.Transform = body.Transform;

        if (!wasOnFloor && isOnFloor)
        {
          characterBodyComponent.EmitSignal(CharacterBodyComponent.SignalName.TouchedFloor, entity);
        }
        else if (wasOnFloor && !isOnFloor)
        {
          characterBodyComponent.EmitSignal(CharacterBodyComponent.SignalName.LeftFloor, entity);
        }
      }
    }

    public override void Update(double delta)
    {
      foreach (Entity entity in Entities)
      {
        CharacterBodyComponent characterBodyComponent = entity.GetComponent<CharacterBodyComponent>();
        TransformComponent transformComponent = entity.GetComponent<TransformComponent>();
        VelocityComponent velocityComponent = entity.GetComponent<VelocityComponent>();

        CharacterBody2D body = characterBodyComponent.Body;

        transformComponent.Transform = body.Transform;
      }
    }

    public override void OnEntityAdded(Entity entity)
    {

    }

    public override void OnEntityRemoved(Entity entity)
    {

    }
  }
}
