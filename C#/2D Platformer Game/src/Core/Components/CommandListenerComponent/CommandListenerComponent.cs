using Godot;
using System;
using System.Collections.Generic;

using System.Linq;

using Core.Commands;
using ECS;

namespace Core.ECS
{
  public partial class CommandListenerComponent : Component
  {
    public Dictionary<int, Command> Commands = new Dictionary<int, Command>();

    public void AddCommand(Command command)
    {
      Commands.Add(TypeId.Get(command), command);
    }

    public async void AddDeferredCommand(Command command)
    {
      await ToSignal(EntityRef.World, World.SignalName.PhysicsFrame);
      if (!HasCommand(command))
      {
        Commands.Add(TypeId.Get(command), command);
      }
    }

    public void RemoveCommand(Command command)
    {
      Commands.Remove(TypeId.Get(command));
    }
    public void ClearCommands()
    {
      Commands.Clear();
    }

    public bool HasCommand<T>() where T : Command
    {
      return Commands.ContainsKey(TypeId.Get<T>());
    }
    public bool HasCommand(Command command)
    {
      return Commands.ContainsKey(TypeId.Get(command));
    }

    public T GetCommand<T>() where T : Command
    {
      int key = TypeId.Get<T>();

      if (Commands.ContainsKey(key))
      {
        return (T)Commands[key];
      }

      return default(T);
    }

    public override void Reset()
    {
      ClearCommands();
      base.Reset();
    }

    //public override void 
  }
}
