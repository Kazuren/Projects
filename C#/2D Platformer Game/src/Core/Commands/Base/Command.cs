using Godot;
using System;
using ECS;
using Core.ECS;

namespace Core.Commands
{
  public abstract class Command : ICommand
  {
    public abstract void Execute(Entity entity);

    private protected delegate void CommandExecutedHandler(Command command);
    private protected event CommandExecutedHandler CommandExecuted;

    protected void OnCommandExecuted(Command command)
    {
      CommandExecuted?.Invoke(command);
    }
  }
}
