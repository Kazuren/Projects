using Godot;
using System;
using System.Collections.Generic;

using Core.Commands;
using ECS;
using EntityComponentSystem = ECS;


namespace Core.ECS
{

  public partial class AnimationSystem : EntityComponentSystem.System
  {
    public enum AnimationStates
    {
      Idle,
      Walk
    }

    public AnimationSystem()
    {
      ComponentSet = new ComponentSet()
      {
        Requirements = new HashSet<int> {
          TypeId<AnimationComponent>.Get(),
          TypeId<CommandListenerComponent>.Get()
        },
        Restrictions = new HashSet<int> { }
      };
    }

    public override void PhysicsUpdate(double delta)
    {
      foreach (Entity entity in Entities)
      {
        //GD.Print(entity);
        AnimationComponent animationComponent = entity.GetComponent<AnimationComponent>();
        AnimationTree animationTree = animationComponent.AnimationTree;
        AnimationNode animationNode = animationTree.TreeRoot;
        //animationNode.SetParameter('Speed', 1);

        if (entity.HasComponent<WalkingComponent>())
        {
          animationTree.Set("parameters/State/current", Variant.From(AnimationStates.Walk));
        }
        else
        {
          animationTree.Set("parameters/State/current", Variant.From(AnimationStates.Idle));
        }
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
