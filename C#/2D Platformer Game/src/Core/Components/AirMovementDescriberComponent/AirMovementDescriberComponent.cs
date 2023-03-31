using Godot;
using ECS;



namespace Core.ECS
{
  public partial class AirMovementDescriberComponent : Component
  {
    [Export]
    public GravityComponent GravityComponent { get; set; }

    [Export]
    public JumpingCapabilityComponent JumpingCapabilityComponent { get; set; }


    [Export(PropertyHint.Range, "0,100,or_greater,or_lesser")]
    public float MaxJumpHeight
    {
      get => _maxJumpHeight;
      set => SetMaxJumpHeight(value);
    }

    [Export(PropertyHint.Range, "0,100,or_greater,or_lesser")]
    public float MinJumpHeight
    {
      get => _minJumpHeight;
      set => SetMinJumpHeight(value);
    }

    [Export(PropertyHint.Range, "0,100,or_greater,or_lesser")]
    public float JumpTimeToPeak
    {
      get => _jumpTimeToPeak;
      set => SetJumpTimeToPeak(value);
    }

    [Export(PropertyHint.Range, "0,100,or_greater,or_lesser")]
    public float JumpTimeToDescent
    {
      get => _jumpTimeToDescent;
      set => SetJumpTimeToDescent(value);
    }

    [Export(PropertyHint.Range, "0,1,or_greater,or_lesser")]
    public float JumpBuffer
    {
      get => _jumpBuffer;
      set => SetJumpBuffer(value);
    }

    [Export(PropertyHint.Range, "0,1,or_greater,or_lesser")]
    public float StallTime
    {
      get => _stallTime;
      set => SetStallTime(value);
    }

    [Export(PropertyHint.Range, "0,1,or_greater,or_lesser")]
    public float CoyoteTime
    {
      get => _coyoteTime;
      set => SetCoyoteTime(value);
    }

    private float _maxJumpHeight = 0F;
    private float _minJumpHeight = 0F;
    private float _jumpTimeToPeak = 0F;
    private float _jumpTimeToDescent = 0F;
    private float _jumpBuffer = 0F;
    private float _stallTime = 0F;
    private float _coyoteTime = 0F;

    public override void _Ready()
    {
      base._Ready();
      CalculateJumpVelocity();
      CalculateGravity();
    }

    public void SetMaxJumpHeight(float value)
    {
      _maxJumpHeight = value;
      CalculateJumpVelocity();
      CalculateGravity();
    }

    public void SetMinJumpHeight(float value)
    {
      _minJumpHeight = value;
      CalculateJumpVelocity();
      CalculateGravity();
    }

    public void SetJumpTimeToPeak(float value)
    {
      _jumpTimeToPeak = value;
      CalculateJumpVelocity();
      CalculateGravity();
    }

    public void SetJumpTimeToDescent(float value)
    {
      _jumpTimeToDescent = value;

      CalculateGravity();
    }

    public async void SetJumpBuffer(float value)
    {
      _jumpBuffer = value;

      if (!IsInsideTree())
      {
        await ToSignal(this, SignalName.TreeEntered);
      }

      JumpingCapabilityComponent.JumpBuffer = _jumpBuffer;
    }

    public async void SetStallTime(float value)
    {
      _stallTime = value;

      if (!IsInsideTree())
      {
        await ToSignal(this, SignalName.TreeEntered);
      }

      JumpingCapabilityComponent.StallTime = _stallTime;
    }

    public async void SetCoyoteTime(float value)
    {
      _coyoteTime = value;

      if (!IsInsideTree())
      {
        await ToSignal(this, SignalName.TreeEntered);
      }

      JumpingCapabilityComponent.CoyoteTime = _coyoteTime;
    }

    private async void CalculateJumpVelocity()
    {
      if (!IsInsideTree())
      {
        await ToSignal(this, SignalName.TreeEntered);
      }

      JumpingCapabilityComponent.MaxJumpVelocity = ((2F * _maxJumpHeight) / _jumpTimeToPeak) * -1F;
      JumpingCapabilityComponent.MinJumpVelocity = ((2F * _minJumpHeight) / _jumpTimeToPeak) * -1F;
    }

    private async void CalculateGravity()
    {
      if (!IsInsideTree())
      {
        await ToSignal(this, SignalName.TreeEntered);
      }

      GravityComponent.UpGravity = ((-2F * _maxJumpHeight) / (_jumpTimeToPeak * _jumpTimeToPeak)) * -1F;
      GravityComponent.DownGravity = ((-2F * _maxJumpHeight) / (_jumpTimeToDescent * _jumpTimeToDescent)) * -1F;
    }
  }
}
