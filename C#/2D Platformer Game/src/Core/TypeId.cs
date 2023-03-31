using System;
using System.Collections.Generic;
using System.Linq;

namespace Core;

public static class TypeId<T> where T : class
{
  //private static int _id;

  static TypeId()
  {
    //_id = TypeId.Next<T>();
  }

  public static int Get()
  {
    //return _id;

    return TypeId.Get<T>();
  }
}

public static class TypeId
{
  //private static int _nextId = 0;

  private static Dictionary<int, Type> _types = new Dictionary<int, Type>();

  // public static int Next<T>()
  // {
  //   var id = _nextId;
  //   _nextId += 1;

  //   _types.Add(id, typeof(T));

  //   return id;
  // }

  public static Type Get(int id)
  {
    return _types[id];
  }

  public static int Get<T>()
  {
    Type t = typeof(T);
    return Get(t);
  }

  public static int Get(object o)
  {
    Type t = o.GetType();
    return Get(t);
  }

  public static int Get(Type t)
  {
    int hashcode = t.AssemblyQualifiedName.GetHashCode();

    if (!_types.ContainsKey(hashcode))
    {
      _types.Add(hashcode, t);
    }
    return hashcode;
  }
}
