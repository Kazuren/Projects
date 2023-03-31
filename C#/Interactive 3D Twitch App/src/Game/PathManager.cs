using Godot;
using System;
using System.Collections.Generic;

using System.Linq;

namespace Game
{
  public class PathManager : Node
  {
    //[Export]
    //public NodePath RootPathNodePath { get; set; }

    //public Node PathsRoot { get; set; }

    public Game.Path.Route[] Routes { get; private set; }

    public Dictionary<ulong, List<OccupiedPeriod>> PathData = new Dictionary<ulong, List<OccupiedPeriod>>();

    public Godot.Timer OccupiedPeriodCleanupTimer { get; private set; } = new Godot.Timer();

    public struct OccupiedPeriod
    {
      public OccupiedPeriod(long timestamp, float offset)
      {
        this.timestamp = timestamp;
        this.offset = offset;
      }
      public long timestamp { get; set; }
      public float offset { get; set; }
    }

    public override void _Ready()
    {
      // Setup the cleanup timer
      OccupiedPeriodCleanupTimer.Autostart = true;
      OccupiedPeriodCleanupTimer.WaitTime = 10.0F;
      OccupiedPeriodCleanupTimer.OneShot = false;
      AddChild(OccupiedPeriodCleanupTimer);
      OccupiedPeriodCleanupTimer.Connect("timeout", this, nameof(Cleanup));
      //PathsRoot = GetNode<Node>(RootPathNodePath);


      //OccupiedPeriodCleanupTimer.Elapsed += Cleanup;
      //OccupiedPeriodCleanupTimer.AutoReset = true;
      //OccupiedPeriodCleanupTimer.Enabled = true;
    }

    public void Setup(Node rootPathNode)
    {
      Reset();
      CalculateRoutes(rootPathNode);

      // Setup the occupied period data for each path
      foreach (Node node in rootPathNode.GetChildrenRecursive())
      {
        if (node is Path path)
        {
          PathData.Add(path.GetInstanceId(), new List<OccupiedPeriod>());
        }
      }
    }

    /// <summary>
    /// Calculates the routes for each path that is a child of the PathsRoot node
    /// </summary>
    public void CalculateRoutes(Node rootPathNode)
    {
      IEnumerable<Game.Path.Route> routes = new Game.Path.Route[0];

      foreach (Node node in rootPathNode.GetChildren())
      {
        if (node is Path path)
        {
          Game.Path.Route[] pathRoutes = path.CalculateRoutes();
          routes = routes.Concat(pathRoutes);
        }
      }

      Routes = routes.ToArray();
    }

    public void Reset()
    {
      PathData.Clear();
    }

    public void Cleanup()
    {
      long currentTime = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
      foreach (KeyValuePair<ulong, List<OccupiedPeriod>> pathData in PathData)
      {
        List<OccupiedPeriod> occupiedPeriods = pathData.Value;
        occupiedPeriods.RemoveAll(p => p.timestamp < currentTime);
      }
    }

    public void RegisterRoute(Path.Route route, EmotePathFollow pathFollow)
    {
      float totalOffset = 0;
      foreach (Path.Destination destination in route.Destinations)
      {
        ulong fromPathId = destination.FromPath.GetInstanceId();

        // Store the timestamp at key offsets such as the incoming branch offsets
        foreach (Path.Branch branch in destination.FromPath.IncomingBranches)
        {
          long t = CalculateTimestampAtOffset(totalOffset + branch.ToPathOffset, pathFollow.EmoteSpeed);
          PathData[fromPathId].Add(new OccupiedPeriod(t, branch.ToPathOffset));
        }

        // Increase our offset as if we've walked the destination
        totalOffset += destination.UntilOffset - destination.FromOffset;

        // Store the timestamp at key offset where the destination ends and where the new one begins if any
        long timestamp = CalculateTimestampAtOffset(totalOffset, pathFollow.EmoteSpeed);

        PathData[fromPathId].Add(new OccupiedPeriod(timestamp, destination.UntilOffset));

        if (destination.ToPath != null)
        {
          ulong toPathId = destination.ToPath.GetInstanceId();
          PathData[toPathId].Add(new OccupiedPeriod(timestamp, destination.AtOffset));
        }
      }
    }

    public bool IsRouteValid(Path.Route route, EmotePathFollow pathFollow)
    {
      float totalOffset = 0;

      foreach (Path.Destination destination in route.Destinations)
      {
        // Check if there's any timestamps close to ours at each occupied offset on our destination
        // TODO possibly group the same offsets together so we don't have to calculate the timestamp for the same offset more than once (or cache it)
        ulong fromPathId = destination.FromPath.GetInstanceId();
        bool occupied = PathData[fromPathId].Any(p => IsOccupied(p, destination.FromOffset, totalOffset, pathFollow));

        if (occupied) { return false; }

        // Increase our offset as if we've walked the destination
        totalOffset += destination.UntilOffset - destination.FromOffset;

        // Check if there's any timestamps close to ours at each occupied offset on our destinations next path if any
        if (destination.ToPath != null)
        {
          ulong toPathId = destination.ToPath.GetInstanceId();
          occupied = PathData[toPathId].Any(p => IsOccupied(p, destination.AtOffset, totalOffset, pathFollow));
          if (occupied) { return false; }
        }
      }
      return true;
    }

    public bool IsOccupied(OccupiedPeriod p, float fromOffset, float totalOffset, EmotePathFollow pathFollow)
    {
      long timestamp = CalculateTimestampAtOffset((p.offset - fromOffset) + totalOffset, pathFollow.EmoteSpeed);
      return Math.Abs(p.timestamp - timestamp) < 500;
    }

    public long CalculateTimestampAtOffset(float offset, float speed)
    {
      long timestamp = DateTimeOffset.UtcNow.AddSeconds(offset / speed).ToUnixTimeMilliseconds();
      return timestamp;
    }

  }
}