using Godot;
using System;
using System.Collections.Generic;

using Core.Commands;
using ECS;
using EntityComponentSystem = ECS;


namespace Core.ECS
{
  public partial class GravitySystem : EntityComponentSystem.System
  {
    public GravitySystem()
    {
      ComponentSet = new ComponentSet()
      {
        Requirements = new HashSet<int> {
          TypeId<GravityComponent>.Get(),
          TypeId<VelocityComponent>.Get()
        },
        Restrictions = new HashSet<int> { }
      };
    }

    // private void IntegrateForces(PhysicsDirectBodyState2D state, Entity entity)
    // {
    //   CharacterBodyComponent characterBodyComponent = entity.GetComponent<CharacterBodyComponent>();
    //   TransformComponent transformComponent = entity.GetComponent<TransformComponent>();
    //   VelocityComponent velocityComponent = entity.GetComponent<VelocityComponent>();


    //   float delta = state.Step;
    //   Vector2 lv = state.LinearVelocity;
    //   Vector2 g = state.TotalGravity;

    //   //lv += g * delta;
    //   //state.LinearVelocity = lv;

    //   state.LinearVelocity = velocityComponent.Velocity;


    //   velocityComponent.Velocity = Vector2.Zero;

    //   transformComponent.Transform = state.Transform;
    //   physicsBodyComponent.RigidBody.Transform = state.Transform;
    // }

    public override void PhysicsUpdate(double delta)
    {
      foreach (Entity entity in Entities)
      {
        GravityComponent gravityComponent = entity.GetComponent<GravityComponent>();
        VelocityComponent velocityComponent = entity.GetComponent<VelocityComponent>();

        float gravity;
        if (velocityComponent.Velocity.Y < 0)
        {
          gravity = gravityComponent.UpGravity;
        }
        else
        {
          gravity = gravityComponent.DownGravity;
        }

        velocityComponent.Velocity = velocityComponent.Velocity with { Y = velocityComponent.Velocity.Y + gravity * (float)delta };
      }
    }

    public override void Update(double delta)
    {

    }
  }
}
