Key = {}

Key.New = function(k)
  local this = {}

  this.String = k
  this.DownCounter = 0
  this.UpCounter = 0
  this.IsVirtuallyPressed = false

  -- Check if key is down
  this.IsDown = function()
    return love.keyboard.isDown(this.String) or this.IsVirtuallyPressed
  end

  -- Check if key is up
  this.IsUp = function()
    return not this.IsDown()
  end

  -- Check if key was just pressed
  this.JustDown = function()
    if this.IsDown() then
      this.DownCounter = this.DownCounter + 1
    else
      this.DownCounter = 0
    end
    this.DownCounter = math.min(this.DownCounter, 2)
    return this.DownCounter == 1
  end

  -- Check if key was just released
  this.JustUp = function()
    if this.IsUp() then
      this.UpCounter = this.UpCounter + 1
    else
      this.UpCounter = 0
    end
    this.UpCounter = math.min(this.UpCounter, 2)
    return this.UpCounter == 1
  end

  this.PressVirtually = function()
    this.IsVirtuallyPressed = true
  end

  this.ReleasedVirtually = function()
    this.IsVirtuallyPressed = false
  end

  return this
end

return Key
