using Godot;
using System.Collections.Generic;

using System;
using ECS;

namespace Core.ECS
{
  public partial class InteractingCapabilityComponent : Component
  {
    public Area2D Area2D { get; set; }

    public List<Entity> InteractableEntities { get; private set; } = new List<Entity>();

    //public delegate void EntityEnteredInteractionRangeHandler(Entity entity);
    //public delegate void EntityExitedInteractionRangeHandler(Entity entity);

    public delegate void AccessHandler(Entity interactingEntity, Entity interactableEntity);

    public event AccessHandler EntityEnteredInteractionRange;
    public event AccessHandler EntityExitedInteractionRange;

    public event Action<Interaction> InteractionAdded;
    public event Action<Interaction> InteractionRemoved;

    //public InteractionMenu InteractionMenu { get; private set; }

    public List<Interaction> Interactions { get; set; } = new List<Interaction>();


    public override void _Ready()
    {
      base._Ready();
      Area2D = GetNode<Area2D>("%Area2D");

      Area2D.Connect(Area2D.SignalName.AreaEntered, new Callable(this, nameof(OnArea2DAreaEntered)));
      Area2D.Connect(Area2D.SignalName.AreaExited, new Callable(this, nameof(OnArea2DAreaExited)));

      //InteractionMenu = GetNode<InteractionMenu>("%InteractionMenu");
    }

    public void AddInteraction(Interaction interaction)
    {
      Interactions.Add(interaction);
      InteractionAdded?.Invoke(interaction);
    }

    public void RemoveInteraction(Interaction interaction)
    {
      Interactions.Remove(interaction);
      InteractionRemoved?.Invoke(interaction);
    }

    private void OnArea2DAreaEntered(Area2D area)
    {
      InteractableComponent component = (InteractableComponent)area.Owner;

      EntityEnteredInteractionRange?.Invoke(EntityRef, component.EntityRef);

      InteractableEntities.Add(component.EntityRef);
    }

    private void OnArea2DAreaExited(Area2D area)
    {
      InteractableComponent component = (InteractableComponent)area.Owner;

      EntityExitedInteractionRange?.Invoke(EntityRef, component.EntityRef);

      InteractableEntities.Remove(component.EntityRef);
    }

    public override void OnComponentAdded(Entity entity)
    {
      base.OnComponentAdded(entity);
    }

    public override void OnComponentRemoved(Entity entity)
    {
      base.OnComponentRemoved(entity);
    }

    public override void Reset()
    {
      EntityEnteredInteractionRange = null;
      EntityExitedInteractionRange = null;
      InteractionAdded = null;
      InteractionRemoved = null;
      base.Reset();
    }
  }
}
