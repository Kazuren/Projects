using Godot;
using System;
using System.Collections.Generic;

using Core.Commands;

using System.Linq;
using ECS;
using EntityComponentSystem = ECS;

namespace Core.ECS
{
  public partial class JumpSystem : EntityComponentSystem.System
  {
    public JumpSystem()
    {
      ComponentSet = new ComponentSet()
      {
        Requirements = new HashSet<int> {
          TypeId<VelocityComponent>.Get(),
          TypeId<JumpingCapabilityComponent>.Get(),
          TypeId<CommandListenerComponent>.Get(),
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
        JumpCommand jumpCommand = commandListenerComponent.GetCommand<JumpCommand>();

        if (jumpCommand != null)
        {
          jumpCommand.Execute(entity);
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
