using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using MonoCustomResourceRegistry;
using Core;

namespace ECS;

[Tool]
[RegisteredType("System", "res://addons/ECS/Assets/layers.svg", "")]
public abstract partial class System : Node
{
  public World World { get; set; }
  public ComponentSet ComponentSet { get; set; } = new ComponentSet();
  public Archetype Archetype { get; private set; }

  public IEnumerable<Entity> Entities
  {
    get
    {
      foreach (Entity e in Archetype.Entities.Values)
      {
        yield return e;
      }
    }
  }

  public override void _Ready()
  {
    Name = this.GetType().Name;
  }

  public virtual void Update(double delta) { }

  public virtual void PhysicsFrameStart(double delta) { }
  public virtual void PhysicsFrameEnd(double delta) { }
  public virtual void PhysicsUpdate(double delta) { }
  public virtual void UnhandledInput(InputEvent @event) { }
  public virtual void Cleanup() { }
  public virtual void PhysicsCleanup() { }
  public virtual void OnEntityAdded(Entity entity) { }
  public virtual void OnEntityRemoved(Entity entity) { }
  public virtual void Draw() { }

  public void SetArchetype(Archetype archetype)
  {
    if (Archetype != null)
    {
      Archetype.EntityAdded -= OnEntityAdded;
      Archetype.EntityRemoved -= OnEntityRemoved;
    }

    Archetype = archetype;
    archetype.EntityAdded += OnEntityAdded;
    archetype.EntityRemoved += OnEntityRemoved;
  }

  public override int GetHashCode()
  {
    return ComponentSet.GetHashCode();
  }

  public override string ToString()
  {
    return $"[{this.GetType().Name}] -> {Archetype.ToString()}";
  }
}
