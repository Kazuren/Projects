using Godot;
using System;
using System.Diagnostics;

namespace GameInterface
{
  public class PerformanceDebugger : Control
  {
    private Label _fpsLabel;
    private Label _staticMemoryLabel;
    private Label _dynamicMemoryLabel;
    private Label _nodeCountLabel;
    private Label _orphanNodeCountLabel;
    private Label _renderObjectsLabel;
    private Label _drawCallsLabel;
    private Label _videoMemoryLabel;

    public override void _Ready()
    {
      _fpsLabel = GetNode<Label>("%FPS");
      _staticMemoryLabel = GetNode<Label>("%StaticMemory");
      _dynamicMemoryLabel = GetNode<Label>("%DynamicMemory");
      _nodeCountLabel = GetNode<Label>("%NodeCount");
      _orphanNodeCountLabel = GetNode<Label>("%OrphanNodeCount");
      _renderObjectsLabel = GetNode<Label>("%RenderObjects");
      _drawCallsLabel = GetNode<Label>("%DrawCalls");
      _videoMemoryLabel = GetNode<Label>("%VideoMemory");
      SetProcess(false);
    }

    public override void _Process(float delta)
    {
      float fps = Performance.GetMonitor(Performance.Monitor.TimeFps);

      int staticMemory = (int)Performance.GetMonitor(Performance.Monitor.MemoryStatic) / 1024 / 1024;
      int staticMemoryMax = (int)Performance.GetMonitor(Performance.Monitor.MemoryStaticMax) / 1024 / 1024;

      int dynamicMemory = (int)Performance.GetMonitor(Performance.Monitor.MemoryDynamic) / 1024 / 1024;
      int dynamicMemoryMax = (int)Performance.GetMonitor(Performance.Monitor.MemoryDynamicMax) / 1024 / 1024;

      float nodeCount = Performance.GetMonitor(Performance.Monitor.ObjectNodeCount);
      float orphanNodeCount = Performance.GetMonitor(Performance.Monitor.ObjectOrphanNodeCount);

      float renderObjectsPerFrame = Performance.GetMonitor(Performance.Monitor.RenderObjectsInFrame);
      float drawCalls = Performance.GetMonitor(Performance.Monitor.RenderDrawCallsInFrame);
      float videoMemory = (float)Performance.GetMonitor(Performance.Monitor.RenderVideoMemUsed) / 1024 / 1024;


      _fpsLabel.Text = $"FPS: {fps}";

      _staticMemoryLabel.Text = $"Static Memory: {staticMemory}/{staticMemoryMax}MB";
      _dynamicMemoryLabel.Text = $"Dynamic Memory: {dynamicMemory}/{dynamicMemoryMax}MB";

      _nodeCountLabel.Text = $"Node Count: {nodeCount}";
      _orphanNodeCountLabel.Text = $"Orphan Node Count: {orphanNodeCount}";

      _renderObjectsLabel.Text = $"Rendered Objects This Frame: {renderObjectsPerFrame}";
      _drawCallsLabel.Text = $"Draw Calls This Frame: {drawCalls}";
      _videoMemoryLabel.Text = $"Video Memory: {videoMemory.ToString("0")}MB";
    }

    public override void _Input(InputEvent @event)
    {
      if (@event is InputEventKey eventKey)
      {
        if (eventKey.Scancode == (int)KeyList.F11 && eventKey.Pressed && !eventKey.Echo)
        {
          Visible = !Visible;
          SetProcess(Visible);
        }
      }
    }
  }
}
