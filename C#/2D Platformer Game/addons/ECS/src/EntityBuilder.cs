using Godot;
using System;
using Core;

namespace ECS;

public class EntityBuilder : IDisposable
{
  private Entity _entity = ObjectPool.Get<Entity>();

  public void Reset()
  {
    _entity = ObjectPool.Get<Entity>();
  }

  public Entity GetEntity()
  {
    Entity entity = _entity;
    Reset();
    return entity;
  }

  // public void AddPhysicsBodyComponent(Shape2D shape, RigidBody2D.ModeEnum mode = RigidBody2D.ModeEnum.Rigid)
  // {
  //   PhysicsBodyComponent physicsBodyComponent = _entity.AddComponent<PhysicsBodyComponent>();
  //   CollisionShape2D collisionShape = new CollisionShape2D() { Shape = shape };
  //   physicsBodyComponent.AddShape(collisionShape);
  //   physicsBodyComponent.RigidBody.Mode = mode;
  // }

  public T AddComponent<T>() where T : Component, new()
  {
    return _entity.AddComponent<T>();
  }

  public void Dispose()
  {
    ObjectPool.Recycle<Entity>(_entity);
  }
}
