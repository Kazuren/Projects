using Godot;
using System;
using System.Collections.Generic;

namespace Game
{
  public static class PathExtensions
  {
    public static Vector3[] GetPoints(this Path path)
    {
      int count = path.Curve.GetPointCount();
      Vector3[] points = new Vector3[count];

      for (int i = 0; i < count; i++)
      {
        Vector3 point = path.Curve.GetPointPosition(i);
        points[i] = point;
      }

      return points;
    }
  }
}
