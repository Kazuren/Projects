using Godot;
using System;
using System.Collections.Generic;

using System.Linq;

namespace Game
{
  public class Scene3D : Spatial
  {
    [Export]
    private NodePath pathsRoot { get; set; }

    [Export]
    private List<NodePath> animationPlayers { get; set; } = new List<NodePath>();

    [Export]
    private NodePath twitchChatQuad { get; set; }

    public Node PathRoot { get; private set; }
    public MeshInstance TwitchChatQuad { get; private set; }


    public override void _Ready()
    {
      PathRoot = GetNode<Node>(pathsRoot);
      TwitchChatQuad = GetNode<MeshInstance>(twitchChatQuad);

      foreach (NodePath animationPlayerNodePath in animationPlayers)
      {
        AnimationPlayer animationPlayer = GetNode<AnimationPlayer>(animationPlayerNodePath);

        string[] animations = animationPlayer.GetAnimationList();
        string animation = animations.First(a => a != "RESET");

        animationPlayer.Play(animation);
      }
    }
  }
}