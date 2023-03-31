#if TOOLS

using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

using Core.ECS;

namespace ECS;

[Tool]
public partial class ECS : EditorPlugin
{
  private Node _currentRoot;
  private List<Entity> _entities = new List<Entity>();


  public override void _EnterTree()
  {
    // Initialization of the plugin goes here.

    GD.Print("ECS Plugin initialized");

    AddCustomType(
      "World", "Node2D",
      GD.Load<Script>("res://addons/ECS/src/World.cs"),
      GD.Load<Texture2D>("res://addons/ECS/Assets/globe.svg")
    );

    AddCustomType(
      "Entity", "Node2D",
      GD.Load<Script>("res://addons/ECS/src/Entity.cs"),
      GD.Load<Texture2D>("res://addons/ECS/Assets/user.svg")
    );

  }

  private void OnSceneChanged(Node root)
  {
  }

  private void OnChildEnteredTree(Node child)
  {
  }

  private void OnWorldChildExitingTree(Node child)
  {

  }

  public override void _ForwardCanvasDrawOverViewport(Control viewportControl)
  {
    base._ForwardCanvasDrawOverViewport(viewportControl);

  }

  public override bool _ForwardCanvasGuiInput(InputEvent @event)
  {
    //GD.Print(@event);
    return true;
  }

  public override bool _Handles(GodotObject @object)
  {
    return base._Handles(@object);
  }

  public override void _ExitTree()
  {
    RemoveCustomType("World");
    RemoveCustomType("Entity");
    // Clean-up of the plugin goes here.
  }
}
#endif
