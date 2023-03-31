using System;
using System.Collections.Concurrent;
using System.Threading;
using System.Threading.Tasks;

using System.Collections.Generic;

using Godot;

using System.IO;

using Path = System.IO.Path;

namespace Core
{
  public static class ObjectPool
  {
    private static Dictionary<int, ConcurrentBag<IPoolable>> _pools =
        new Dictionary<int, ConcurrentBag<IPoolable>>();

    public static TPoolable Get<TPoolable>() where TPoolable : class, IPoolable, new()
    {
      ConcurrentBag<IPoolable> pool = GetPool(TypeId<TPoolable>.Get());
      bool poolHadItem = pool.TryTake(out var item);
      if (!poolHadItem)
      {
        item = new TPoolable();
      }
      return (TPoolable)item;
    }

    public static TPoolable Get<TPoolable>(string pathToScene) where TPoolable : class, IPoolable, new()
    {
      ConcurrentBag<IPoolable> pool = GetPool(TypeId<TPoolable>.Get());
      bool poolHadItem = pool.TryTake(out var item);
      if (!poolHadItem)
      {
        item = ResourceLoader.Load<PackedScene>(pathToScene).Instantiate<TPoolable>();
      }
      return (TPoolable)item;
    }

    public static void Recycle<TPoolable>(TPoolable item) where TPoolable : class, IPoolable, new()
    {
      Recycle(TypeId<TPoolable>.Get(), item);
    }

    public static void Recycle(int typeId, IPoolable item)
    {
      ConcurrentBag<IPoolable> pool = GetPool(typeId);
      item.Reset();

      if (pool.Count >= 100)
      {
        if (item is GodotObject o) { o.Dispose(); o.Free(); }
        return;
      }
      pool.Add(item);
    }

    private static ConcurrentBag<IPoolable> GetPool(int typeId)
    {
      bool poolExists = _pools.TryGetValue(typeId, out var pool);
      if (!poolExists)
      {
        pool = new ConcurrentBag<IPoolable>();
        _pools.Add(typeId, pool);
      }
      return pool;
    }
  }
}
