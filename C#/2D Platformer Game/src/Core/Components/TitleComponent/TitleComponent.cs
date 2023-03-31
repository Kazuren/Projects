using Godot;
using ECS;

namespace Core.ECS
{
  public partial class TitleComponent : Component
  {
    [Export]
    public string Title { get; set; } = "";
  }
}
