using Godot;
using System;
using Core;
using System.Reflection;

using CSharpSystem = System;

namespace ECS;

public abstract partial class Component : Node2D, IPoolable, IDisposable
{
  public Component()
  {
    SetProcess(false);
    SetPhysicsProcess(false);
    Name = this.GetType().Name;
  }

  [Signal]
  public delegate void AddedEventHandler(Entity entity);
  [Signal]
  public delegate void RemovedEventHandler(Entity entity);

  public Entity EntityRef { get; set; }

  public virtual void Reset() { EntityRef = null; }
  public virtual void OnComponentAdded(Entity entity) { EntityRef = entity; EmitSignal(SignalName.Added, entity); }
  public virtual void OnComponentRemoved(Entity entity) { EmitSignal(SignalName.Removed, entity); EntityRef = null; }

  public PropertyInfo[] GetProps()
  {
    Type cType = this.GetType();

    PropertyInfo[] props = cType.GetProperties(
      CSharpSystem.Reflection.BindingFlags.Public |
      CSharpSystem.Reflection.BindingFlags.Instance |
      CSharpSystem.Reflection.BindingFlags.DeclaredOnly
    );

    return props;
  }
}
