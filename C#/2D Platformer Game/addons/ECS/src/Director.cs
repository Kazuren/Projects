using Godot;

namespace ECS;

public class Director
{
  public Entity EntityFromScene(PackedScene scene)
  {
    return scene.Instantiate<Entity>();
  }

  // public void MakePlayer(EntityBuilder builder)
  // {
  //   Texture texture = ResourceLoader.Load<Texture>("res://src/Assets/temp.png");
  //   RenderingComponent renderingComponent = builder.AddRenderingComponent(texture);
  //   builder.AddTransformComponent(new Vector2(32, 32));
  //   builder.AddSpeedComponent(3.25F * Utility.Math.MetersToPixels);

  //   builder.AddComponent<PlayerInputComponent>();
  //   builder.AddComponent<CommandListenerComponent>();
  //   builder.AddComponent<VelocityComponent>();
  //   builder.AddComponent<CameraComponent>();
  //   builder.AddComponent<LookAtMouseComponent>();

  //   Shape2D shape = new RectangleShape2D() { Extents = new Vector2(8, 8) };
  //   builder.AddPhysicsBodyComponent(shape, RigidBody2D.ModeEnum.Character);


  //   AnimationComponent animationComponent = builder.AddComponent<AnimationComponent>();
  //   Animation walkAnimation = new Animation();
  //   int trackIdx = walkAnimation.AddTrack(Animation.TrackType.Value);


  //   walkAnimation.TrackSetPath(trackIdx, new NodePath($"../{renderingComponent.Name}/{renderingComponent.Sprite.Name}:texture"));
  //   walkAnimation.Loop = true;
  //   walkAnimation.Length = 1;
  //   walkAnimation.TrackInsertKey(trackIdx, 0.5F, texture);
  //   animationComponent.AnimationPlayer.AddAnimation("walk", walkAnimation);

  //   ResourceSaver.Save("test.tres", walkAnimation);
  // }
}
