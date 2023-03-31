using Godot;
using System;
using Core;

using System.Text.Json;
using System.Text.Json.Serialization;

using System.IO;

using Core.ECS;

using ECS;
using World = ECS.World;

public partial class Main : Node2D
{
  public override void _Ready()
  {

    DebugMenu debugMenu = GetNode<DebugMenu>("%DebugMenu");
    World world = GetNode<World>("%World");

    debugMenu.World = world;

    // Actor player = ResourceLoader.Load<PackedScene>("res://src/Core/Player.tscn").Instance<Actor>();
    // player.AddComponent(new PlayerInputHandler());

    // Camera2D camera2D = new Camera2D();
    // camera2D.Current = true;

    // player.AddChild(camera2D);
    // AddChild(player);
    // camera2D.Zoom = new Vector2(0.1666667F, 0.1666667F);


    // MoveCommand moveCommand = new MoveCommand(Vector2.Right);

    // string fileName = "MoveCommand.json";
    // string jsonString = JsonSerializer.Serialize(moveCommand);
    // System.IO.File.WriteAllText(fileName, jsonString);

    // fileName = "MoveCommand.json";
    // jsonString = System.IO.File.ReadAllText(fileName);
    // moveCommand = JsonSerializer.Deserialize<MoveCommand>(jsonString);

    // GD.Print(moveCommand.Direction);

    PackedScene playerScene = ResourceLoader.Load<PackedScene>("res://src/Entities/Player.tscn");

    //World world = new World();

    Director director = new Director();
    EntityBuilder entityBuilder = new EntityBuilder();

    // world.AddSystem<PlayerInputSystem>();
    // world.AddSystem<InputToCommandSystem>();
    // world.AddSystem<RigidBodyInitializerSystem>();

    // world.AddSystem<MoveSystem>();
    // world.AddSystem<CameraMoveSystem>();
    // world.AddSystem<WalkSystem>();

    // world.AddSystem<InteractingCapabilityMoveSystem>();
    // world.AddSystem<InteractableMoveSystem>();


    // world.AddSystem<AnimationSystem>();

    // world.AddSystem<RenderingSystem>();

    // Entities
    //Entity player = director.EntityFromScene(playerScene);
    //world.RegisterEntity(player);

    //AddChild(world);
  }
}
