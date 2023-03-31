using Godot;
using System;
using System.Collections.Generic;
using ECS;
using EntityComponentSystem = ECS;


namespace Core.ECS
{
  public partial class AirborneSystem : EntityComponentSystem.System
  {
    public AirborneSystem()
    {
      ComponentSet = new ComponentSet()
      {
        Requirements = new HashSet<int>() { TypeId<AirborneComponent>.Get() },
        Restrictions = new HashSet<int>() { }
      };
    }

    public override void PhysicsUpdate(double delta)
    {
      foreach (Entity entity in Entities)
      {
        AirborneComponent airborneComponent = entity.GetComponent<AirborneComponent>();
        airborneComponent.Airtime += (float)delta;
      }
    }
  }
}
