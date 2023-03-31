using Godot;
using System;
using System.Collections.Generic;
using ECS;
using EntityComponentSystem = ECS;


namespace Core.ECS
{
  public partial class CameraMoveSystem : EntityComponentSystem.System
  {
    public CameraMoveSystem()
    {
      ComponentSet = new ComponentSet()
      {
        Requirements = new HashSet<int>() { TypeId<CameraComponent>.Get(), TypeId<TransformComponent>.Get() },
        Restrictions = new HashSet<int>() { }
      };
    }

    public override void PhysicsUpdate(double delta)
    {
      foreach (Entity entity in Entities)
      {
        TransformComponent transformComponent = entity.GetComponent<TransformComponent>();
        CameraComponent cameraComponent = entity.GetComponent<CameraComponent>();

        cameraComponent.Camera.Transform = transformComponent.Transform;
      }
    }
  }
}
