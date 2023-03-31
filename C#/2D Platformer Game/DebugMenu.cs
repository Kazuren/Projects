using Godot;
using System;
using System.Collections.Generic;

using System.Reflection;

using ECS;
using World = ECS.World;

public partial class DebugMenu : Control
{

  public World World { get => _world; set => SetWorld(value); }

  private World _world;

  public Tree Tree { get; set; }

  public override void _Ready()
  {
    base._Ready();
    Tree = GetNode<Tree>("%Tree");
  }

  private void SetWorld(World value)
  {
    _world = value;

    Tree.Clear();

    TreeItem root = Tree.CreateItem();

    foreach (Entity entity in _world.Entities.Values)
    {
      AddEntityToTree(entity);
    }
  }

  public override void _PhysicsProcess(double delta)
  {
    if (World == null) { return; }

    TreeItem root = Tree.GetRoot();

    Godot.Collections.Array<TreeItem> children = root.GetChildren();
    foreach (TreeItem child in children)
    {
      UpdateTreeItem(child);
    }
  }

  private void UpdateTreeItem(TreeItem treeItem)
  {
    if (!treeItem.HasMeta("TreeItemObject")) { return; }

    Variant treeItemObject = treeItem.GetMeta("TreeItemObject", default(Variant));
    object obj = treeItemObject.Obj;
    if (obj == null) { return; }

    switch (obj)
    {
      case Component c:
        UpdateComponentTreeItemValues(treeItem, c);
        break;
      default:
        break;
    }

    Godot.Collections.Array<TreeItem> children = treeItem.GetChildren();
    foreach (TreeItem child in children)
    {
      UpdateTreeItem(child);
    }
  }

  private void AddEntityToTree(Entity entity)
  {
    TreeItem root = Tree.GetRoot();

    TreeItem entityItem = Tree.CreateItem(root);
    entityItem.SetMeta("TreeItemObject", Variant.From<Entity>(entity));

    entityItem.SetText(0, entity.Name);


    foreach (KeyValuePair<int, Component> kvp in entity.GetComponents())
    {
      int key = kvp.Key;
      Component c = kvp.Value;

      AddComponentTreeItem(entityItem, c);
    }

    Callable componentAddedCallable = Callable.From((Component c) =>
    {
      AddComponentTreeItem(entityItem, c);
    });

    entity.Connect(Entity.SignalName.ComponentAdded, componentAddedCallable);

    entity.Connect(Entity.SignalName.Deleted, Callable.From(() =>
    {
      entityItem.Free();
      entity.Disconnect(Entity.SignalName.ComponentAdded, componentAddedCallable);
    }), (uint)ConnectFlags.OneShot);
  }

  private void SetPropItemValues(TreeItem propItem, PropertyInfo prop, object value)
  {
    propItem.SetText(0, prop.Name);
    switch (value)
    {
      case null:
        propItem.SetText(1, "null");
        break;
      case Vector2 v:
        propItem.SetText(1, $"({v.X.ToString("0.00")}, {v.Y.ToString("0.00")})");
        break;
      case float f:
        propItem.SetText(1, f.ToString("0.00"));
        break;
      default:
        propItem.SetText(1, value.ToString());
        break;
    }

    propItem.SetText(2, value.GetType().Name);
  }

  private void AddComponentTreeItem(TreeItem entityItem, Component c)
  {
    TreeItem componentItem = Tree.CreateItem(entityItem);
    componentItem.SetMeta("TreeItemObject", Variant.From<Component>(c));

    componentItem.SetText(0, c.Name);

    PropertyInfo[] props = c.GetProps();

    foreach (PropertyInfo prop in props)
    {
      object propValue = prop.GetValue(c, null);

      TreeItem propItem = Tree.CreateItem(componentItem);

      SetPropItemValues(propItem, prop, propValue);
    }

    c.Connect(Component.SignalName.Removed, Callable.From(
      (Entity e) => { componentItem.Free(); }
    ), (uint)ConnectFlags.OneShot);
  }

  private void UpdateComponentTreeItemValues(TreeItem componentItem, Component c)
  {
    componentItem.SetText(0, c.Name);

    PropertyInfo[] props = c.GetProps();

    for (int i = 0; i < props.Length; i++)
    {
      PropertyInfo prop = props[i];

      object propValue = prop.GetValue(c, null);

      TreeItem propItem = componentItem.GetChild(i);

      SetPropItemValues(propItem, prop, propValue);
    }
  }

  public override void _Input(InputEvent @event)
  {
    if (@event.IsActionPressed("toggle_debug", false))
    {
      Visible = !Visible;
    }
  }
}
