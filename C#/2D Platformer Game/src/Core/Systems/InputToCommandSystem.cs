using Godot;
using System;
using System.Collections.Generic;

using System.Linq;

using Core.Input;
using Core.Commands;
using ECS;
using EntityComponentSystem = ECS;


namespace Core.ECS
{
  public partial class InputToCommandSystem : EntityComponentSystem.System
  {
    public InputToCommandSystem()
    {
      ComponentSet = new ComponentSet()
      {
        Requirements = new HashSet<int> { TypeId<PlayerInputComponent>.Get(), TypeId<CommandListenerComponent>.Get() },
        Restrictions = new HashSet<int> { }
      };
    }

    public override void Update(double delta)
    {
      base.Update(delta);

      foreach (Entity entity in Entities)
      {
        PlayerInputComponent playerInputComponent = entity.GetComponent<PlayerInputComponent>();
        CommandListenerComponent commandListenerComponent = entity.GetComponent<CommandListenerComponent>();

        List<InputData> inputsPressed = playerInputComponent.InputsPressed;
        List<InputData> inputsReleased = playerInputComponent.InputsReleased;

        Vector2 directionalInput = Vector2.Zero;

        InputData lastVerticalInputData = inputsPressed.LastOrDefault(d => d.InputAction == InputAction.MoveUp || d.InputAction == InputAction.MoveDown);
        if (lastVerticalInputData != null)
        {
          directionalInput.Y = lastVerticalInputData.InputAction == InputAction.MoveUp ? -1 : 1;
        }

        InputData lastHorizontalInputData = inputsPressed.LastOrDefault(d => d.InputAction == InputAction.MoveLeft || d.InputAction == InputAction.MoveRight);
        if (lastHorizontalInputData != null)
        {
          directionalInput.X = lastHorizontalInputData.InputAction == InputAction.MoveLeft ? -1 : 1;
        }

        //Vector2 direction = new Vector2(directionalInput.X, 0);

        //Vector2 direction = directionalInput.Normalized();

        if (directionalInput.X != 0)
        {
          if (!commandListenerComponent.HasCommand<MoveCommand>())
          {
            MoveCommand command = new MoveCommand(directionalInput.X);
            commandListenerComponent.AddCommand(command);
          }
        }

        InputData jumpInputData = inputsPressed.LastOrDefault(d => d.InputAction == InputAction.Jump);
        if (jumpInputData != null)
        {
          if (jumpInputData.JustPressed)
          {
            if (!commandListenerComponent.HasCommand<JumpCommand>())
            {
              JumpCommand command = new JumpCommand();
              commandListenerComponent.AddCommand(command);
            }
          }
        }
        else if (jumpInputData == null)
        {
          if (entity.HasComponents<JumpingCapabilityComponent, JumpingComponent, VelocityComponent>())
          {
            JumpingCapabilityComponent jumpingCapabilityComponent = entity.GetComponent<JumpingCapabilityComponent>();
            VelocityComponent velocityComponent = entity.GetComponent<VelocityComponent>();
            if (!commandListenerComponent.HasCommand<StopJumpingCommand>())
            {
              StopJumpingCommand command = new StopJumpingCommand();
              commandListenerComponent.AddCommand(command);
            }
          }
        }

        // InputData jumpReleaseInputData = inputsReleased.LastOrDefault(d => d.InputAction == InputAction.Jump);
        // if (jumpReleaseInputData != null)
        // {
        //   StopJumpingCommand command = new StopJumpingCommand();
        //   commandListenerComponent.AddCommand(command);
        // }
      }
    }

    public override void PhysicsCleanup()
    {
      base.PhysicsCleanup();
      foreach (Entity entity in Entities)
      {
        CommandListenerComponent commandListenerComponent = entity.GetComponent<CommandListenerComponent>();
        commandListenerComponent.ClearCommands();
      }
    }
  }
}
