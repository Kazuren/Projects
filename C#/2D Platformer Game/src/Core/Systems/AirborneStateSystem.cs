using Godot;
using System;
using System.Collections.Generic;

using Core.Commands;
using ECS;
using EntityComponentSystem = ECS;


namespace Core.ECS
{
  public partial class AirborneStateSystem : EntityComponentSystem.System
  {
    public AirborneStateSystem()
    {
      ComponentSet = new ComponentSet()
      {
        Requirements = new HashSet<int> {
          TypeId<CharacterBodyComponent>.Get(),
        },
        Restrictions = new HashSet<int> { }
      };
    }

    public override void PhysicsUpdate(double delta)
    {
      foreach (Entity entity in Entities)
      {

      }
    }

    public override void Update(double delta)
    {
      foreach (Entity entity in Entities)
      {

      }
    }

    public override void OnEntityAdded(Entity entity)
    {
      CharacterBodyComponent characterBodyComponent = entity.GetComponent<CharacterBodyComponent>();

      characterBodyComponent.TouchedFloor += OnTouchedFloor;
      characterBodyComponent.LeftFloor += OnLeftFloor;

    }

    public override void OnEntityRemoved(Entity entity)
    {
      if (entity.HasComponent<CharacterBodyComponent>())
      {
        CharacterBodyComponent characterBodyComponent = entity.GetComponent<CharacterBodyComponent>();

        characterBodyComponent.TouchedFloor -= OnTouchedFloor;
        characterBodyComponent.LeftFloor -= OnLeftFloor;
      }

    }

    public void OnTouchedFloor(Entity entity)
    {
      entity.TryRemoveComponent<AirborneComponent>();
    }

    public void OnLeftFloor(Entity entity)
    {
      entity.TryAddComponent<AirborneComponent>();
    }
  }
}
