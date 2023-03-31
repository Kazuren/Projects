using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

namespace ECS;

public class Archetype
{
  public ComponentSet ComponentSet { get; set; } = new ComponentSet();
  public Dictionary<string, Entity> Entities { get; set; } = new Dictionary<string, Entity>();
  public Dictionary<int, List<Component>> Components { get; set; } = new Dictionary<int, List<Component>>();

  public delegate void EntityAddedHandler(Entity entity);
  public delegate void EntityRemovedHandler(Entity entity);

  public event EntityAddedHandler EntityAdded;
  public event EntityAddedHandler EntityRemoved;

  internal bool Check(Entity entity)
  {
    // foreach (int c in entity.GetComponents())
    // {
    //   // if that Component is in the restrictions, return false
    //   if (ComponentSet.Restrictions.Contains(c))
    //   {
    //     return false;
    //   }

    //   // if that component doesn't exist in the requirements, return false
    //   if (!ComponentSet.Requirements.Contains(c))
    //   {
    //     return false;
    //   }
    // }

    foreach (int requirement in ComponentSet.Requirements)
    {
      if (!entity.HasComponent(requirement))
      {
        return false;
      }
    }

    foreach (int restriction in ComponentSet.Restrictions)
    {
      if (entity.HasComponent(restriction))
      {
        return false;
      }
    }

    return true;
  }

  public void AddEntity(Entity entity)
  {
    Entities.Add(entity.Id, entity);
    EntityAdded?.Invoke(entity);
  }
  public bool HasEntity(Entity entity)
  {
    return Entities.ContainsKey(entity.Id);
  }
  public bool HasEntity(string id)
  {
    return Entities.ContainsKey(id);
  }

  public Entity GetEntity(string id)
  {
    return Entities[id];
  }
  public void RemoveEntity(Entity entity)
  {
    Entities.Remove(entity.Id);
    EntityRemoved?.Invoke(entity);
  }

  public void CheckAndAddOrRemoveEntity(Entity entity)
  {
    if (HasEntity(entity))
    {
      if (!Check(entity))
      {
        RemoveEntity(entity);
      }
    }
    else
    {
      if (Check(entity))
      {
        AddEntity(entity);
      }
    }
  }

  public override int GetHashCode()
  {
    return ComponentSet.GetHashCode();
  }

  public override string ToString()
  {
    return ComponentSet.ToString();
  }
}
