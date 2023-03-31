using Godot;
using System;
using Core;
using System.Collections.Generic;
using System.Linq;
using ECS;
using EntityComponentSystem = ECS;


namespace Core.ECS
{
  public partial class RenderingSystem : EntityComponentSystem.System
  {

    public RenderingSystem()
    {
      ComponentSet = new ComponentSet()
      {
        Requirements = new HashSet<int> { TypeId<RenderingComponent>.Get(), TypeId<TransformComponent>.Get() },
        Restrictions = new HashSet<int> { }
      };

    }

    public override void Update(double delta)
    {
      foreach (Entity entity in Entities)
      {
        RenderingComponent renderingComponent = entity.GetComponent<RenderingComponent>();
        TransformComponent transformComponent = entity.GetComponent<TransformComponent>();

        Transform2D transform = transformComponent.Transform;
        Sprite2D sprite = renderingComponent.Sprite;

        sprite.Position = transform.Origin;
        sprite.Rotation = transform.Rotation;
      }
    }

    public override void OnEntityAdded(Entity entity)
    {
      base.OnEntityAdded(entity);

      RenderingComponent renderingComponent = entity.GetComponent<RenderingComponent>();
      renderingComponent.Sprite.Visible = true;
    }

    public override void OnEntityRemoved(Entity entity)
    {
      base.OnEntityRemoved(entity);

      if (!entity.HasComponent<RenderingComponent>())
      {
        return;
      }

      RenderingComponent renderingComponent = entity.GetComponent<RenderingComponent>();

      renderingComponent.Sprite.Visible = false;
    }

    public override void Draw()
    {
      base.Draw();

      // World.Material = PixelFilterShaderMaterial;

      // foreach (Entity entity in Entities)
      // {
      //   RenderingComponent renderingComponent = entity.GetComponent<RenderingComponent>();
      //   TransformComponent transformComponent = entity.GetComponent<TransformComponent>();
      //   Vector2 textureSize = renderingComponent.Texture.GetSize();
      //   World.DrawSetTransformMatrix(transformComponent.Transform);
      //   World.DrawTexture(renderingComponent.Texture, -textureSize / 2);
      // }

      // World.DrawSetTransformMatrix(new Transform2D());
    }
  }
}
