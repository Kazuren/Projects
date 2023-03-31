using Godot;
using System;
using System.Collections.Generic;

using System.Linq;

using Core.Input;
using ECS;
using EntityComponentSystem = ECS;

namespace Core.ECS
{
  public partial class PlayerInputSystem : EntityComponentSystem.System
  {
    public PlayerInputSystem()
    {
      ComponentSet = new ComponentSet()
      {
        Requirements = new HashSet<int> { TypeId<PlayerInputComponent>.Get() },
        Restrictions = new HashSet<int> { }
      };
    }

    private Dictionary<InputAction, string> InputActions { get; } = new Dictionary<InputAction, string>()
    {
      [InputAction.MoveUp] = "move_up",
      [InputAction.MoveDown] = "move_down",
      [InputAction.MoveLeft] = "move_left",
      [InputAction.MoveRight] = "move_right",
      [InputAction.Jump] = "jump",
      [InputAction.Crouch] = "crouch",
    };

    public override void UnhandledInput(InputEvent @event)
    {
      if (@event is InputEventKey keyEvent)
      {
        foreach (KeyValuePair<InputAction, string> kvp in InputActions)
        {
          InputAction action = kvp.Key;
          string value = kvp.Value;

          if (keyEvent.IsActionPressed(value, false))
          {
            InputData inputData = new InputData() { InputAction = action, InputEventKey = keyEvent };
            foreach (Entity entity in Entities)
            {
              PlayerInputComponent playerInputComponent = entity.GetComponent<PlayerInputComponent>();
              List<InputData> inputsPressed = playerInputComponent.InputsPressed;
              inputsPressed.Add(inputData);
            }
            break;
          }
          else if (keyEvent.IsActionReleased(value))
          {
            InputData inputData = new InputData() { InputAction = action, InputEventKey = keyEvent };
            foreach (Entity entity in Entities)
            {
              PlayerInputComponent playerInputComponent = entity.GetComponent<PlayerInputComponent>();
              List<InputData> inputsPressed = playerInputComponent.InputsPressed;
              List<InputData> inputsReleased = playerInputComponent.InputsReleased;

              inputsPressed.Remove(inputData);
              inputsReleased.Add(inputData);
            }
            break;
          }
        }
      }
    }

    public override void Cleanup()
    {
      base.Cleanup();
      foreach (Entity entity in Entities)
      {
        PlayerInputComponent playerInputComponent = entity.GetComponent<PlayerInputComponent>();
        List<InputData> inputsReleased = playerInputComponent.InputsReleased;
        inputsReleased.Clear();

        List<InputData> inputsPressed = playerInputComponent.InputsPressed;

        foreach (InputData d in inputsPressed)
        {
          d.JustPressed = false;
        }
      }
    }

    public override void _Notification(int what)
    {
      switch (what)
      {
        case (int)Node2D.NotificationApplicationFocusOut:
        case (int)Node2D.NotificationWMWindowFocusOut:
          foreach (Entity entity in Entities)
          {
            PlayerInputComponent playerInputComponent = entity.GetComponent<PlayerInputComponent>();
            List<InputData> inputsPressed = playerInputComponent.InputsPressed;
            List<InputData> inputsReleased = playerInputComponent.InputsReleased;

            inputsPressed.Clear();
            inputsReleased.Clear();
          }
          break;
        default:
          break;
      }
    }

  }
}
