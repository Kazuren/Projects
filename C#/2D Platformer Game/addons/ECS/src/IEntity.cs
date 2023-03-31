using System;

namespace ECS;

public interface IEntity : IEquatable<IEntity>
{
  string Id { get; }
  TComponent AddComponent<TComponent>() where TComponent : Component, new();
  void RemoveComponent<TComponent>() where TComponent : Component;
  bool HasComponent<TComponent>() where TComponent : Component;
  TComponent GetComponent<TComponent>() where TComponent : Component;
  void Delete();
}

