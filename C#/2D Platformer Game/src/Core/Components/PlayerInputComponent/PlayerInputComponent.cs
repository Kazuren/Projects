using Godot;

using System.Collections.Generic;

using Core.Input;
using ECS;

namespace Core.ECS
{
  public partial class PlayerInputComponent : Component
  {
    public List<InputData> InputsPressed { get; set; } = new List<InputData>();
    public List<InputData> InputsReleased { get; set; } = new List<InputData>();
  }
}
