using System;
using System.Collections.Generic;
using Godot;

using System.Text.RegularExpressions;
using System.Linq;

using System.Net;
using System.Net.Http;
using System.Net.Security;
using System.Net.WebSockets;

using System.Text;

static class Utility
{
  public enum DrawOrder
  {
    Character,
    Object,
    Weapon,
  }

  public static class Math
  {
    public static readonly float MetersToPixels = 16F;
    public static readonly float PixelsToMeters = 1F / MetersToPixels;
  }

  public class PointComparer : EqualityComparer<Vector3>
  {
    private float _tolerance = Mathf.Epsilon;

    public PointComparer(float tolerance = Mathf.Epsilon)
    {
      _tolerance = tolerance;
    }

    public override bool Equals(Vector3 p1, Vector3 p2)
    {
      //if (p1 == null && p2 == null) { return true; }
      //if (p1 == null || p2 == null) { return false; }

      if (
        Mathf.IsEqualApprox(p1.X, p2.X, _tolerance) &&
        Mathf.IsEqualApprox(p1.Y, p2.Y, _tolerance) &&
        Mathf.IsEqualApprox(p1.Z, p2.Z, _tolerance)
      ) { return true; }

      return false;
    }

    public override int GetHashCode(Vector3 p)
    {
      // Read for hashcode: https://stackoverflow.com/questions/263400/what-is-the-best-algorithm-for-overriding-gethashcode/263416#263416
      return p.GetHashCode();
    }
  }

  public static string AddSpacesToSentence(string text)
  {
    if (string.IsNullOrWhiteSpace(text))
      return "";
    StringBuilder newText = new StringBuilder(text.Length * 2);
    newText.Append(text[0]);
    for (int i = 1; i < text.Length; i++)
    {
      if (char.IsUpper(text[i]) && text[i - 1] != ' ')
        newText.Append(' ');
      newText.Append(text[i]);
    }
    return newText.ToString();
  }

  public static void NestedPrint(Dictionary<string, object> dict, int level = 0)
  {
    foreach (var item in dict)
    {
      if (item.Value is Dictionary<string, object> nested)
      {
        GD.Print($"{new string(' ', level)}{item.Key}:");
        NestedPrint(nested, level + 1);
      }
      else
      {
        GD.Print($"{new string(' ', level)}{item.Key} = {item.Value}");
      }
    }
  }

  public static T[] GetChildren<T>(this Node node)
  {
    List<T> childrenList = new List<T>();

    foreach (Node child in node.GetChildren())
    {
      if (child is T c)
      {
        childrenList.Add(c);
      }
    }

    return childrenList.ToArray();
  }

  public static Node[] GetChildrenRecursive(this Node node)
  {
    List<Node> childrenList = new List<Node>();

    foreach (Node child in node.GetChildren())
    {
      childrenList.Add(child);
      child.GetChildrenRecursive(childrenList);
    }

    return childrenList.ToArray();
  }

  public static T[] GetChildrenRecursive<T>(this Node node)
  {
    List<T> childrenList = new List<T>();

    foreach (Node child in node.GetChildren())
    {
      if (child is T tChild)
      {
        childrenList.Add(tChild);
      }
      child.GetChildrenRecursive<T>(childrenList);
    }

    return childrenList.ToArray();
  }

  private static void GetChildrenRecursive(this Node node, List<Node> childrenList)
  {
    foreach (Node child in node.GetChildren())
    {
      childrenList.Add(child);
      child.GetChildrenRecursive(childrenList);
    }
  }

  private static void GetChildrenRecursive<T>(this Node node, List<T> childrenList)
  {
    foreach (Node child in node.GetChildren())
    {
      if (child is T tChild)
      {
        childrenList.Add(tChild);
      }
      child.GetChildrenRecursive<T>(childrenList);
    }
  }

  public static void QueueFreeChildren(this Node node)
  {
    foreach (Node child in node.GetChildren())
    {
      child.QueueFree();
    }
  }

  public static List<Node> RemoveChildren(this Node node)
  {
    List<Node> children = new List<Node>(node.GetChildCount());

    foreach (Node child in node.GetChildren())
    {
      node.RemoveChild(child);
      children.Add(child);
    }

    return children;
  }

  public static T PickRandom<T>(this IList<T> list, Random rng)
  {
    return list[rng.Next(list.Count)];
  }

  public static void Shuffle<T>(this Random rng, T[] array)
  {
    int n = array.Length;
    while (n > 1)
    {
      int k = rng.Next(n--);
      T temp = array[n];
      array[n] = array[k];
      array[k] = temp;
    }
  }

  /// <summary>
  /// 
  /// </summary>
  /// <param name="rng"></param>
  /// <returns>Random float in the range [-1, 1)</returns>
  public static float NextFloatM1P1(this Random rng)
  {
    return rng.NextFloat() * 2.0F - 1.0F;
  }

  public static float NextFloat(this Random rng)
  {
    return (float)rng.NextDouble();
  }

  public static float NextFloatInRange(this Random rng, float min, float max)
  {
    return rng.NextFloat() * (max - min) + min;
  }

  public static int IndexOf<TSource>(this IEnumerable<TSource> source, Func<TSource, bool> predicate)
  {
    var index = 0;
    foreach (var item in source)
    {
      if (predicate.Invoke(item))
      {
        return index;
      }
      index++;
    }

    return -1;
  }
}
