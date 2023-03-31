using Godot;
using System;
using System.Collections.Generic;

using Core.Commands;

using System.Linq;
using ECS;
using EntityComponentSystem = ECS;

namespace Core.ECS
{
  public partial class MoveSystem : EntityComponentSystem.System
  {
    public MoveSystem()
    {
      ComponentSet = new ComponentSet()
      {
        Requirements = new HashSet<int> {
          TypeId<CharacterBodyComponent>.Get(),
          TypeId<TransformComponent>.Get(),
          TypeId<CommandListenerComponent>.Get(),
          TypeId<VelocityComponent>.Get(),
          TypeId<SpeedComponent>.Get(),
        },
        Restrictions = new HashSet<int> { }
      };
    }

    public override void PhysicsUpdate(double delta)
    {
      foreach (Entity entity in Entities)
      {
        //TransformComponent transformComponent = entity.GetComponent<TransformComponent>();
        CommandListenerComponent commandListenerComponent = entity.GetComponent<CommandListenerComponent>();
        VelocityComponent velocityComponent = entity.GetComponent<VelocityComponent>();
        MoveCommand moveCommand = commandListenerComponent.GetCommand<MoveCommand>();

        if (moveCommand != null)
        {
          moveCommand.Execute(entity);
        }
      }
    }

    public override void OnEntityAdded(Entity entity)
    {

    }

    public override void OnEntityRemoved(Entity entity)
    {

      //Physics2DServer.BodySetForceIntegrationCallback(body, this, nameof(IntegrateForces), entity);
    }
  }
}
