#nullable enable

using Godot;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

using Core.ECS;
using ECS;

using System;

namespace Core.Commands;

public class JumpCommand : Command
{
  //public float Direction { get; private set; }

  public JumpCommand()
  {

  }


  public override async void Execute(Entity entity)
  {
    if (entity.HasComponent<JumpingComponent>()) { return; }

    CharacterBodyComponent characterBodyComponent = entity.GetComponent<CharacterBodyComponent>();
    CharacterBody2D body = characterBodyComponent.Body;

    CommandListenerComponent commandListenerComponent = entity.GetComponent<CommandListenerComponent>();
    VelocityComponent velocityComponent = entity.GetComponent<VelocityComponent>();
    JumpingCapabilityComponent jumpingCapabilityComponent = entity.GetComponent<JumpingCapabilityComponent>();

    if (jumpingCapabilityComponent.JumpsRemaining <= 0)
    {
      if (!body.IsOnFloor() && jumpingCapabilityComponent.JumpBuffer > 0) // Jump Buffer
      {
        double buffer = TimeSpan.FromSeconds(jumpingCapabilityComponent.JumpBuffer).TotalMilliseconds;

        SignalAwaiter signalAwaiter = entity.ToSignal(characterBodyComponent, CharacterBodyComponent.SignalName.TouchedFloor);

        Task signalTask = Task.Run(async () => { await signalAwaiter; });
        Task delayTask = Task.Run(async () => { await Task.Delay((int)buffer); });

        Task completedTask = await Task.WhenAny(new Task[] { delayTask, signalTask });

        if (completedTask == signalTask)
        {
          // have to add the command at the end of the frame because the system that executes the Jump Command has already run this frame
          // and adding the command immediately would just clear it at the end of the frame without ever executing.
          commandListenerComponent.AddDeferredCommand(new JumpCommand());
        }
        // else jump buffer is gone, so do nothing
      }
      return;
    }

    jumpingCapabilityComponent.JumpsRemaining -= 1;
    entity.AddComponentImmediate<JumpingComponent>();
    velocityComponent.Velocity = velocityComponent.Velocity with { Y = jumpingCapabilityComponent.MaxJumpVelocity };

    OnCommandExecuted(this);
  }

  public override int GetHashCode()
  {
    return this.GetType().AssemblyQualifiedName.GetHashCode();
  }
}
