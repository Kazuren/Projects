using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using Core;

namespace ECS;

public partial class Entity : Node2D, IPoolable, IEntity
{
  public Entity()
  {
    SetProcess(false);
    SetPhysicsProcess(false);
    if (Name == "Entity")
    {
      Name = Id;
    }
  }

  [Signal]
  public delegate void DeletedEventHandler();

  [Signal]
  public delegate void ComponentAddedEventHandler(Component component);

  [Signal]
  public delegate void ComponentRemovedEventHandler(Component component);

  // public event ComponentAddedEventHandler ComponentAdded;
  //public event ComponentRemovedEventHandler ComponentRemoved;

  public string Id { get; private set; } = Guid.NewGuid().ToString();

  public World World { get; set; }

  private Dictionary<int, Component> _components = new Dictionary<int, Component>();

  private Queue<ComponentAddInfo> _componentAddQueue = new Queue<ComponentAddInfo>();
  private Queue<int> _componentRemoveQueue = new Queue<int>();
  private bool _markedForDelete = false;

  private bool _isNew = false;

  public override void _Ready()
  {
    base._Ready();
    _isNew = true;

    Component[] components = this.GetChildren<Component>();

    foreach (Component c in components)
    {
      //RemoveChild(c);

      _components.Add(TypeId.Get(c), c);
      c.OnComponentAdded(this);
      //_componentAddQueue.Enqueue(new ComponentAddInfo(c, TypeId.Get(c)));
    }
  }

  public TComponent AddComponent<TComponent>() where TComponent : Component, new()
  {
    Type tComponent = typeof(TComponent);
    TComponent component = ObjectPool.Get<TComponent>($"res://src/Core/Components/{tComponent.Name}/{tComponent.Name}.tscn");

    _componentAddQueue.Enqueue(new ComponentAddInfo(component, TypeId<TComponent>.Get()));

    return component;
  }

  public TComponent AddComponentImmediate<TComponent>() where TComponent : Component, new()
  {
    TComponent component = AddComponent<TComponent>();

    World.CommitEntityChanges(this);

    return component;
  }

  public TComponent TryAddComponent<TComponent>() where TComponent : Component, new()
  {
    if (!HasComponent<TComponent>())
    {
      return AddComponent<TComponent>();
    }

    return null;
  }

  public void RemoveComponent<TComponent>() where TComponent : Component
  {
    _componentRemoveQueue.Enqueue(TypeId<TComponent>.Get());
  }

  public void RemoveComponentImmediate<TComponent>() where TComponent : Component
  {
    RemoveComponent<TComponent>();
    World.CommitEntityChanges(this);
  }


  public void TryRemoveComponent<TComponent>() where TComponent : Component
  {
    if (HasComponent<TComponent>())
    {
      _componentRemoveQueue.Enqueue(TypeId<TComponent>.Get());
    }
  }

  public TComponent GetComponent<TComponent>() where TComponent : Component
  {
    var success = _components.TryGetValue(TypeId<TComponent>.Get(), out var component);
    if (!success)
    {
      throw new Exception(
          $"Trying to get nonexistent component of type {TypeId<TComponent>.Get()} from entity with id {Id}"
      );
    }

    return (TComponent)component;
  }

  public TComponent TryGetComponent<TComponent>() where TComponent : Component
  {
    var success = _components.TryGetValue(TypeId<TComponent>.Get(), out var component);
    if (!success)
    {
      return null;
    }

    return (TComponent)component;
  }

  public bool HasComponent<TComponent>() where TComponent : Component
  {
    return HasComponent(TypeId<TComponent>.Get());
  }

  public bool HasComponents<T1, T2>() where T1 : Component where T2 : Component
  {
    return
      HasComponent(TypeId<T1>.Get()) &&
      HasComponent(TypeId<T2>.Get());
  }

  public bool HasComponents<T1, T2, T3>() where T1 : Component where T2 : Component where T3 : Component
  {
    return
      HasComponent(TypeId<T1>.Get()) &&
      HasComponent(TypeId<T2>.Get()) &&
      HasComponent(TypeId<T3>.Get());
  }

  public bool HasComponent(int typeId)
  {
    return _components.ContainsKey(typeId);
  }

  public IEnumerable<int> GetComponentKeys()
  {
    foreach (int key in _components.Keys)
    {
      yield return key;
    }
  }

  public IEnumerable<Component> GetComponentValues()
  {
    foreach (Component c in _components.Values)
    {
      yield return c;
    }
  }

  public IEnumerable<KeyValuePair<int, Component>> GetComponents()
  {
    foreach (KeyValuePair<int, Component> c in _components)
    {
      yield return c;
    }
  }

  public void Delete()
  {
    _markedForDelete = true;
  }

  public bool Equals(IEntity other)
  {
    return Id == other.Id;
  }

  public override int GetHashCode()
  {
    return Id.GetHashCode();
  }

  public void Reset()
  {
    Id = Guid.NewGuid().ToString();
    _markedForDelete = false;
  }

  public bool HasComponentChanges()
  {
    return _componentAddQueue.Count > 0 || _componentRemoveQueue.Count > 0;
  }

  public bool CommitComponentChanges()
  {
    bool didChange = _isNew;
    _isNew = false;

    while (_componentAddQueue.Count > 0)
    {
      ComponentAddInfo addInfo = _componentAddQueue.Dequeue();
      if (_components.ContainsKey(addInfo.TypeId))
      {
        throw new Exception(
            $"Inserting duplicate component of type {addInfo.TypeId} into entity with id {Id}"
        );
      }
      _components.Add(addInfo.TypeId, addInfo.Component);
      AddChild(addInfo.Component);
      addInfo.Component.OnComponentAdded(this);

      EmitSignal(SignalName.ComponentAdded, addInfo.Component);

      didChange = true;
    }

    while (_componentRemoveQueue.Count > 0)
    {
      var typeId = _componentRemoveQueue.Dequeue();
      var success = _components.TryGetValue(typeId, out var component);
      if (success)
      {
        RemoveChild(component);
        ObjectPool.Recycle(typeId, component);
        _components.Remove(typeId);
        component.OnComponentRemoved(this);
        EmitSignal(SignalName.ComponentRemoved, component);
      }

      didChange = true;
    }

    return didChange;
  }

  public bool CommitDeleteChanges()
  {
    if (_markedForDelete)
    {
      foreach (var item in _components)
      {
        RemoveChild(item.Value);
        ObjectPool.Recycle(item.Key, item.Value);
        item.Value.OnComponentRemoved(this);
      }

      _components.Clear();
      _componentAddQueue.Clear();
      _componentRemoveQueue.Clear();

      EmitSignal(SignalName.Deleted);

      return true;
    }

    return false;
  }

  public override string ToString()
  {
    return $"[{base.ToString()} ({string.Join(", ", _components.Select(c => c.Key))})]";
  }

  private struct ComponentAddInfo
  {
    public Component Component;
    public int TypeId;

    public ComponentAddInfo(Component component, int typeId)
    {
      Component = component;
      TypeId = typeId;
    }
  }
}
