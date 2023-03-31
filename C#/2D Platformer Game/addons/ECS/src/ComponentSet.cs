using System;
using System.Collections.Generic;
using System.Linq;
using Core;

namespace ECS;

public class ComponentSet : IEquatable<ComponentSet>
{
  public ComponentSet()
  {
    UpdateHashCode();
  }

  public HashSet<int> Requirements { get; set; } = new HashSet<int>();
  public HashSet<int> Restrictions { get; set; } = new HashSet<int>();

  private int _hashCode = 0;

  public bool Check(Entity entity)
  {
    foreach (int requirement in Requirements)
    {
      if (!entity.HasComponent(requirement))
      {
        return false;
      }
    }

    foreach (int restriction in Restrictions)
    {
      if (entity.HasComponent(restriction))
      {
        return false;
      }
    }

    return true;
  }

  public void AddRequirement<TComponent>() where TComponent : Component
  {
    int typeId = TypeId<TComponent>.Get();
    if (!Requirements.Contains(typeId))
    {
      Requirements.Add(TypeId<TComponent>.Get());
      UpdateHashCode();
    }
  }

  public bool IsSubsetOf(ComponentSet otherComponentSet)
  {
    bool compatible = Requirements.IsSubsetOf(otherComponentSet.Requirements) && !Restrictions.Any(r => otherComponentSet.Requirements.Contains(r));
    return compatible;
  }

  public void AddRestriction<TComponent>() where TComponent : Component
  {
    var typeId = TypeId<TComponent>.Get();
    if (!Restrictions.Contains(typeId))
    {
      Restrictions.Add(TypeId<TComponent>.Get());
      UpdateHashCode();
    }
  }

  private void UpdateHashCode()
  {
    _hashCode = GetHashCode();
  }


  public bool Equals(ComponentSet other)
  {
    return _hashCode == other._hashCode;
  }

  public override int GetHashCode()
  {
    //return _stringSignature.GetHashCode();

    unchecked // Overflow is fine, just wrap
    {
      int hash = 17;
      // Suitable nullity checks etc, of course :)
      hash = hash * 23 + (Requirements.Count > 0 ? Requirements.Aggregate((sum, i) => unchecked(sum + i)) : 0);
      hash = hash * 23 + (Restrictions.Count > 0 ? Restrictions.Aggregate((sum, i) => unchecked(sum + i)) : 0);
      return hash;
    }
  }

  public override string ToString()
  {
    return string.Join(", ", Requirements.Select(i => TypeId.Get(i).Name + $"({i})")) + " [+|-] " + string.Join(", ", Restrictions.Select(i => TypeId.Get(i).Name + $"({i})"));
  }
}
