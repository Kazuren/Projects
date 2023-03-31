using Core.ECS;
using ECS;

namespace Core.Commands
{
  public interface ICommand
  {
    void Execute(Entity entity);
  }
}
