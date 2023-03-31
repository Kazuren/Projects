using Godot;
using System;

namespace Core.Input
{
  public class InputData : IEquatable<InputData>
  {
    public InputAction InputAction { get; set; }
    public InputEventKey InputEventKey { get; set; }
    public bool JustPressed { get; set; } = true;

    public override bool Equals(object obj)
    {
      return obj != null && obj is InputData d && this.InputAction == d.InputAction;
    }

    public bool Equals(InputData d)
    {
      return d != null && this.InputAction == d.InputAction;
    }

    public override int GetHashCode()
    {
      return InputAction.GetHashCode();
    }
  }
}
