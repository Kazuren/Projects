using Godot;

namespace Core.Design
{
  public static class Theme
  {
    public static readonly Color HighlightColor = new Color("#acb85e");
    public static readonly Color WhiteColor = new Color("#eeeeee");
    public static readonly Color Red = new Color("#e11d48");
    public static readonly Color Green = new Color("#16a34a");
  }

  public static class Drawing
  {
    public static void DrawCircleArcPoly(this CanvasItem canvasItem, Vector2 center, float radius, float angleFrom, float angleTo, Color color)
    {
      int nbPoints = 128;
      Vector2[] pointsArc = new Vector2[nbPoints + 2];
      pointsArc[0] = center;
      Color[] colors = new Color[] { color };

      for (int i = 0; i <= nbPoints; i++)
      {
        float anglePoint = angleFrom + i * (angleTo - angleFrom) / nbPoints - Mathf.Pi / 2;
        pointsArc[i + 1] = center + new Vector2(Mathf.Cos(anglePoint), Mathf.Sin(anglePoint)) * radius;
      }

      canvasItem.DrawPolygon(pointsArc, colors);
    }

    public static Vector2[] GetPointsInArc(Vector2 center, float radius, float angleFrom, float angleTo)
    {
      int nbPoints = 128;
      Vector2[] pointsArc = new Vector2[nbPoints + 2];
      pointsArc[0] = center;
      for (int i = 0; i <= nbPoints; i++)
      {
        float anglePoint = angleFrom + i * (angleTo - angleFrom) / nbPoints - Mathf.Pi / 2;
        pointsArc[i + 1] = center + new Vector2(Mathf.Cos(anglePoint), Mathf.Sin(anglePoint)) * radius;
      }

      return pointsArc;
    }
  }
}
