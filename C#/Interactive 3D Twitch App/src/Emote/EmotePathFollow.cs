using Godot;

using System.Collections.Generic;

public class EmotePathFollow : PathFollow
{
  [Signal]
  delegate void PathEnded();
  public float EmoteSpeed { get; set; } = 0.3F;

  public bool InUse { get; set; } = false;

  public Game.Path CurrentPath { get; private set; }
  public Game.Path.Destination CurrentDestination { get; private set; }
  public Game.Path.Route Route { get; private set; }
  public int DestinationIndex { get; private set; } = 0;
  private bool _routeSet = false;

  public override void _Ready()
  {
    Loop = false;
    RotationMode = RotationModeEnum.None;
    //SetProcess(false);
  }

  public override void _Process(float delta)
  {
    if (!_routeSet) { return; }

    float speed = EmoteSpeed * delta;
    Offset += speed;

    if (Offset >= CurrentDestination.UntilOffset && CurrentDestination.ToPath != null)
    {
      // TODO create smooth transition
      CurrentPath.RemoveChild(this);
      CurrentDestination.ToPath.AddChild(this);
      Offset = CurrentDestination.AtOffset;

      DestinationIndex = (DestinationIndex + 1) % Route.Length;
      CurrentDestination = Route[DestinationIndex];
      CurrentPath = CurrentDestination.FromPath;
    }

    if (UnitOffset >= 1 && CurrentDestination.ToPath == null)
    {
      EmitSignal("PathEnded");
    }
  }

  public void SetRoute(Game.Path.Route route)
  {
    Route = route;
    DestinationIndex = 0;
    CurrentDestination = Route[DestinationIndex];
    CurrentPath = CurrentDestination.FromPath;
    CurrentPath.AddChild(this);

    //SetProcess(true);

    _routeSet = true;
  }

  // TODO: before swapping, interpolate between the points for smooth transition
  public void SwapToBranch(Game.Path.Branch branch, float pathRemainderOffset)
  {
    //float pathRemainderOffset = Offset + speed - branch.PathOffset;
    GetParent().RemoveChild(this);
    branch.ToPath.AddChild(this);
    CurrentPath = branch.ToPath;
    Offset = branch.ToPathOffset + pathRemainderOffset;
  }
}


// func setup(entity) -> void:
// 	self.entity = entity
// 	path_follow_2d = PathFollow2D.new()
// 	path_follow_2d.rotate = rotate
// 	path_follow_2d.loop = false#loop
// 	path.add_child(path_follow_2d)
// 	entity.get_parent().remove_child(entity)
// 	path_follow_2d.add_child(entity)
// 	entity.position = Vector2.ZERO

// 	connect("path_ended", self, "_on_path_ended")


// func _physics_process(delta: float) -> void:
// 	time += delta

// 	if !use_unit_offset:
// 	#	var t = ease(time / time_required, ease_curve)
// 		var speed = entity.speed
// 		if reverse:
// 			speed *= -1
// 		path_follow_2d.offset += speed * delta
// 	else:
// 		var t = time / time_required
// 		if reverse:
// 			t = 1 - t
// 		path_follow_2d.unit_offset = ease(t, ease_curve)

// 	if path_follow_2d.unit_offset >= 1 and !reverse:
// 		if loop:
// 			reverse = !reverse
// 		else:
// 			emit_signal("path_ended")
// 	elif path_follow_2d.unit_offset <= 0 and reverse:
// 		if loop:
// 			reverse = !reverse
// 		else:
// 			emit_signal("path_ended")


// func _on_path_ended() -> void:
// 	if kill_on_end:
// 		entity.connect("tree_exiting", self, "_on_entiy_tree_exiting")
// 		entity.health = 0


// func _on_entiy_tree_exiting() -> void:
// 	path_follow_2d.queue_free()
