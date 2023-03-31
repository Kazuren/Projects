using Godot;
using Core.Commands;
using ECS;

namespace Core.ECS
{
  public class Interaction
  {
    public Entity Source { get; set; }
    public Entity Target { get; set; }
    public Command Command { get; set; }
    public string Description { get; set; }
  }
}
