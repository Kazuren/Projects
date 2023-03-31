using Godot;
using System;
using System.Collections.Generic;
using ECS;
using EntityComponentSystem = ECS;

namespace Core.ECS
{
  public partial class TransformSyncSystem : EntityComponentSystem.System
  {
    public TransformSyncSystem()
    {
      ComponentSet = new ComponentSet()
      {
        Requirements = new HashSet<int> { TypeId<TransformComponent>.Get() },
        Restrictions = new HashSet<int> { }
      };
    }

    public override void OnEntityAdded(Entity entity)
    {
      TransformComponent transformComponent = entity.GetComponent<TransformComponent>();

      transformComponent.Transform = entity.Transform;
      entity.Transform = new Transform2D(0, Vector2.Zero);
      //RigidBody2D body = physicsBodyComponent.RigidBody;

      //body.Transform = transformComponent.Transform;

      //Physics2DServer.BodySetState(body, Physics2DServer.BodyState.Transform, transformComponent.Transform);
    }

    public override void Update(double delta)
    {
      //base.Update(delta);
      //World.Update();
    }

    public override void Draw()
    {
      //World world = World;
      foreach (Entity entity in Entities)
      {
        continue;
        // TransformComponent transformComponent = entity.GetComponent<TransformComponent>();
        // PhysicsBodyComponent physicsBodyComponent = entity.GetComponent<PhysicsBodyComponent>();

        // Transform2D transform = transformComponent.Transform;

        // world.DrawSetTransform(transform.origin, transform.Rotation, transform.Scale);

        // int shapeCount = physicsBodyComponent.GetShapeCount();
        // for (int i = 0; i < shapeCount; i++)
        // {
        //   ShapeData shapeData = physicsBodyComponent.GetShapeData(i);
        //   Shape2D shape = shapeData.Shape;
        //   Transform2D shapeTransform = shapeData.Transform == null ? new Transform2D() : shapeData.Transform.Value;

        //   if (shape is RectangleShape2D rectShape)
        //   {
        //     Rect2 rect2 = new Rect2() { Size = rectShape.Extents, Position = shapeTransform.origin - rectShape.Extents / 2 };
        //     world.DrawRect(rect2, Colors.Red, false, 1, false);
        //   }
        // }
      }

      //world.DrawSetTransform(Vector2.Zero, 0, Vector2.One);
    }
  }
}