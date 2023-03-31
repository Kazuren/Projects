using Godot;
using System;

using System.Collections.Generic;
using System.Linq;
using Game;


namespace Game
{
  public class Path : Godot.Path
  {
    [Export]
    public List<NodePath> BranchNodePaths { get; set; } = new List<NodePath>();

    [Export]
    public bool isFinal { get; set; } = false;

    public List<Branch> Branches { get; set; } = new List<Branch>();
    public List<Branch> IncomingBranches { get; set; } = new List<Branch>();
    public List<OccupiedPeriod> OccupiedPeriods { get; set; } = new List<OccupiedPeriod>();


    //public ImmediateGeometry immediateGeometry { get; set; } = new ImmediateGeometry();

    public class Branch
    {
      public Game.Path FromPath { get; set; }
      public Game.Path ToPath { get; set; }
      public float FromPathOffset { get; set; }
      public float ToPathOffset { get; set; }

      public override string ToString()
      {
        return $"{ToPath.Name}@{FromPathOffset}-{ToPathOffset}";
      }
    }

    public class OccupiedPeriod
    {
      public float Offset { get; set; }
      public DateTime Date { get; set; } = DateTime.Now;
    }

    public class Route
    {
      public int Length { get => Destinations.Count; }
      public Destination this[int i]
      {
        get { return Destinations[i]; }
      }
      public List<Destination> Destinations = new List<Destination>();

      public void AddDestination(Destination destination)
      {
        Destinations.Add(destination);
      }
      public Route Duplicate()
      {
        return new Route() { Destinations = new List<Destination>(Destinations) };
      }

      public override string ToString()
      {
        string toString = "Route:\n" + String.Join(System.Environment.NewLine, Destinations.Select(destination => destination.ToString()));
        return toString;
      }
    }

    public class Destination
    {
      public float FromOffset { get; set; }
      public Game.Path FromPath { get; set; }
      public float UntilOffset { get; set; }
      public Game.Path ToPath { get; set; }
      public float AtOffset { get; set; }

      public override string ToString()
      {
        return $"From: {FromPath.Name} until: {UntilOffset}m, To: {(ToPath != null ? ToPath.Name : null)} at: {AtOffset}m";
      }
    }

    public Route[] CalculateRoutes()
    {
      List<Route> possibleRoutes = new List<Route>();

      RecursiveRouteCreation(this, possibleRoutes);

      return possibleRoutes.ToArray();
    }

    // TODO turn Branch class into Destination class since they share a lot of the same data
    // TODO use the pre constructed Branch instances(Destinations) instead of creating new ones
    // TODO don't duplicate the routes so much, only when needed (I think when it has > 1 branch)
    public void RecursiveRouteCreation(Game.Path path, List<Route> routes, Route route = null, float currentOffset = 0.0F)
    {
      if (route == null) { route = new Route(); }

      if (path.isFinal)
      {
        Route duplicateRoute = route.Duplicate();
        duplicateRoute.AddDestination(new Destination()
        {
          FromOffset = 0.0F,
          FromPath = path,
          UntilOffset = path.Curve.GetBakedLength()
        });
        routes.Add(duplicateRoute);
      }

      // Find all the branches that are in front of the current offset
      IEnumerable<Branch> branches = path.Branches.Where(branch => branch.FromPathOffset > currentOffset || Mathf.IsEqualApprox(branch.FromPathOffset, currentOffset, 0.0001F));

      foreach (Branch branch in branches)
      {
        Route duplicateRoute = route.Duplicate();
        duplicateRoute.AddDestination(new Destination
        {
          FromOffset = currentOffset,
          FromPath = path,
          UntilOffset = branch.FromPathOffset,
          ToPath = branch.ToPath,
          AtOffset = branch.ToPathOffset
        });
        //routes.Add(duplicateRoute);
        RecursiveRouteCreation(branch.ToPath, routes, duplicateRoute, branch.ToPathOffset);
      }
    }

    // offset in meters, speed in m/s
    public long CalculateTimestampAtOffset(float offset, float speed)
    {
      DateTime dateTime = DateTime.UtcNow.AddSeconds(offset / speed);
      long timestamp = DateTimeOffset.UtcNow.AddSeconds(offset / speed).ToUnixTimeMilliseconds();
      return timestamp;
    }


    public override void _Ready()
    {
      Vector3[] points = this.GetPoints();

      // Search for points in our branches with the same location for each point
      foreach (NodePath branchNodePath in BranchNodePaths)
      {
        Game.Path path = GetNode<Game.Path>(branchNodePath);
        Vector3[] branchPoints = path.GetPoints();

        IEnumerable<Vector3> convergePoints = points.Where(p => branchPoints.Contains(p));
        foreach (Vector3 point in convergePoints)
        {
          Vector3 globalPoint = path.ToGlobal(point);
          Vector3 pathLocalPoint = this.ToLocal(globalPoint);
          Vector3 branchLocalPoint = path.ToLocal(globalPoint);
          Branch branch = new Branch
          {
            FromPath = this,
            ToPath = path,
            FromPathOffset = Curve.GetClosestOffset(pathLocalPoint),
            ToPathOffset = path.Curve.GetClosestOffset(branchLocalPoint)
          };
          Branches.Add(branch);
          path.IncomingBranches.Add(branch);
          //branch.IncomingBranches.Add()
        }
      }

      // AddChild(immediateGeometry);
      // SpatialMaterial m = new SpatialMaterial();
      // m.FlagsUsePointSize = true;
      // m.ParamsPointSize = 1.0F;
      // m.VertexColorUseAsAlbedo = true;
      // m.FlagsUnshaded = true;
      // m.AlbedoColor = Colors.White;
      // immediateGeometry.MaterialOverride = m;

      foreach (Branch branch in Branches)
      {
        //GD.Print($"{this.Name}:{branch}");
      }
    }

    public override void _Process(float delta)
    {
      // immediateGeometry.Clear();
      // immediateGeometry.Begin(Mesh.PrimitiveType.Lines);
      // immediateGeometry.SetColor(Colors.LightGoldenrod);


      // foreach (Vector3 point in Curve.GetBakedPoints())
      // {
      //   immediateGeometry.AddVertex(point);
      // }

      // immediateGeometry.End();
    }

    public PathFollow[] GetPathFollows()
    {
      List<PathFollow> pathFollows = new List<PathFollow>();

      foreach (Node child in GetChildren())
      {
        if (child is PathFollow pathFollow)
        {
          pathFollows.Add(pathFollow);
        }
      }

      return pathFollows.ToArray();
    }
  }
}
