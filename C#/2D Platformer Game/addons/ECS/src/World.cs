using Godot;
using System;


using System.Collections.Generic;


using System.Linq;

using Core.Collections.Generic;
using Core;

namespace ECS;

public partial class World : Node2D
{
  public World()
  {
    Name = "World";
  }

  public Dictionary<string, Entity> Entities { get; private set; } = new Dictionary<string, Entity>();
  public HashSet<Archetype> Archetypes { get; private set; } = new HashSet<Archetype>();
  public ICollection<System> Systems { get; private set; }

  private OrderedDictionary<int, System> _systems { get; set; } = new OrderedDictionary<int, System>();
  private Queue<Entity> _entityRemoveQueue { get; set; } = new Queue<Entity>();
  public Node EntitiesContainer;
  public Node SystemsContainer;

  [Signal]
  public delegate void PhysicsFrameEventHandler();

  [Signal]
  public delegate void EntityAddedEventHandler();

  [Signal]
  public delegate void EntityRemovedEventHandler();

  public override void _Ready()
  {
    Entity[] entities = EntitiesContainer.GetChildren<Entity>();
    System[] systems = SystemsContainer.GetChildren<System>();

    foreach (Entity entity in entities)
    {
      RegisterEntity(entity);
    }

    foreach (System system in systems)
    {
      AddSystem(system);
    }

    base._Ready();
  }
  public override void _EnterTree()
  {
    base._EnterTree();

    Node entityContainer = FindChild("Entities");
    Node systemContainer = FindChild("Systems");

    if (entityContainer == null)
    {
      EntitiesContainer = new Node();
      AddChild(EntitiesContainer);
    }
    else
    {
      EntitiesContainer = entityContainer;
    }

    if (systemContainer == null)
    {
      SystemsContainer = new Node();
      AddChild(SystemsContainer);
    }
    else
    {
      SystemsContainer = systemContainer;
    }

    EntitiesContainer.Name = "Entities";
    SystemsContainer.Name = "Systems";

    Systems = _systems.Values;

  }

  public void SetRootScene(Node root)
  {
    EntitiesContainer.Owner = root;
    SystemsContainer.Owner = root;
  }


  public Entity CreateEntity()
  {
    Entity entity = ObjectPool.Get<Entity>();
    Entities.Add(entity.Id, entity);
    entity.World = this;
    EntitiesContainer.AddChild(entity);

    EmitSignal(SignalName.EntityAdded);

    return entity;
  }

  public void RegisterEntity(Entity entity)
  {
    Entities.Add(entity.Id, entity);
    entity.World = this;

    Entity[] entityChildren = entity.GetChildrenRecursive<Entity>();
    foreach (Entity e in entityChildren)
    {
      Entities.Add(e.Id, e);
      e.World = this;
    }

    if (!entity.IsInsideTree())
    {
      EntitiesContainer.AddChild(entity);
    }

    EmitSignal(SignalName.EntityAdded);
  }


  public void AddSystem(System system)
  {
    system.World = this;
    _systems.Add(TypeId.Get(system), system);

    Archetype archetype = Archetypes.FirstOrDefault(a => a.ComponentSet == system.ComponentSet);

    if (archetype == null)
    {
      archetype = new Archetype() { ComponentSet = system.ComponentSet };
      Archetypes.Add(archetype);
    }

    system.SetArchetype(archetype);

    if (!system.IsInsideTree())
    {
      SystemsContainer.AddChild(system);
    }

    Systems = _systems.Values;
  }

  public void AddSystem<TSystem>() where TSystem : System, new()
  {
    System system = new TSystem();
    AddSystem(system);
  }

  public TSystem GetSystem<TSystem>() where TSystem : System
  {
    int hashCode = TypeId<TSystem>.Get();

    if (!HasSystem<TSystem>())
    {
      throw new Exception(
        $"Trying to get nonexistent System of type {TypeId<TSystem>.Get()}"
      );
    }

    return (TSystem)_systems.GetValue(hashCode);
  }

  public bool HasSystem<TSystem>() where TSystem : System
  {
    int hashCode = TypeId<TSystem>.Get();

    return _systems.ContainsKey(hashCode);
  }

  public IEnumerable<Entity> Query(ComponentSet componentSet)
  {
    foreach (Entity entity in Entities.Values)
    {
      if (componentSet.Check(entity))
      {
        yield return entity;
      }
    }
  }

  public void CommitEntityChanges(Entity entity)
  {
    bool componentsChanged = entity.CommitComponentChanges();

    if (componentsChanged)
    {
      foreach (Archetype archetype in Archetypes)
      {
        archetype.CheckAndAddOrRemoveEntity(entity);
      }
    }

    bool isEntityDeleted = entity.CommitDeleteChanges();
    if (isEntityDeleted)
    {
      foreach (Archetype archetype in Archetypes)
      {
        if (archetype.HasEntity(entity))
        {
          archetype.RemoveEntity(entity);
        }
      }

      _entityRemoveQueue.Enqueue(entity);
    }
  }

  private void CommitChanges()
  {
    foreach (Entity entity in Entities.Values)
    {
      CommitEntityChanges(entity);
    }

    while (_entityRemoveQueue.Count > 0)
    {
      Entity entity = _entityRemoveQueue.Dequeue();

      Entities.Remove(entity.Id);
      RemoveChild(entity);
      ObjectPool.Recycle(entity);

      EmitSignal(SignalName.EntityRemoved);
    }
  }


  public override void _Process(double delta)
  {
    if (Systems != null)
    {

      foreach (System system in Systems)
      {
        system.Update(delta);
      }

      foreach (System system in Systems)
      {
        system.Cleanup();
      }
    }

    QueueRedraw();
  }

  public override void _PhysicsProcess(double delta)
  {
    if (Systems != null)
    {

      foreach (System system in Systems)
      {
        system.PhysicsFrameStart(delta);
      }

      foreach (System system in Systems)
      {
        system.PhysicsUpdate(delta);
      }

      foreach (System system in Systems)
      {
        system.PhysicsFrameEnd(delta);
      }

      foreach (System system in Systems)
      {
        system.PhysicsCleanup();
      }
    }

    CommitChanges();

    EmitSignal("PhysicsFrame");
  }

  public override void _UnhandledInput(InputEvent @event)
  {
    if (Systems != null)
    {

      foreach (System system in Systems)
      {
        system.UnhandledInput(@event);
      }
    }
  }

  public override void _Draw()
  {
    if (Systems != null)
    {

      foreach (System system in Systems)
      {
        system.Draw();
      }
    }
  }

  public override string ToString()
  {
    return base.ToString();
  }
}

