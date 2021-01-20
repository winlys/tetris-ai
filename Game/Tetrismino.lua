--local Game = require 'Game/Game'
--local TetrisBoard = require 'Game/TetrisBoard'
local Key = require 'Input/Key'
local InputManager = require 'Input/InputManager'

Tetrismino = {}

Tetrismino.New = function(board, x_position, y_position)
  local this = {}

  this.Board = board
  this.X = x_position
  this.Y = y_position

  this.Forms = {}
  this.CurrentFormID = 1
  this.ID = '0'
  this.SRSData = {
    {{ -1, 0 }, { -1, -1 }, { 0, 2 }, { -1, 2 }},
    {{ 1, 0 }, { 1, 1 }, { 0, -2 }, { 1, -2 }},
    {{ 1, 0 }, { 1, -1 }, { 0, 2 }, { 1, 2 }},
    {{ -1, 0 }, { -1, 1 }, { 0, -2 }, { -1, -2 }}
  }

  this.IsLockDown = false

  -- Timer
  this.OnFloorTimer = 0;
  this.DasDelayTimer = 0;
  this.DasAutoRepeatTimer = 0;
  this.SoftDropTimer = 0;


  -- Rotate       1: Right    2: 180    3: Left
  this.Rotate = function(type)
    if type == 1 or type == 2 or type == 3 then
      local previous_form_id = this.CurrentFormID
      this.CurrentFormID = (this.CurrentFormID + type - 1) % #this.Forms + 1
      this.OnFloorTimer = 0
      this.SRS(previous_form_id, this.CurrentFormID)
    end
  end

  -- SRS
  this.SRS = function(old, new)
    local k = 0
    if new == 2 then
      k = 1
    elseif new == 4 then
      k = 3
    else
      if old == 2 then
        k = 2
      elseif old == 4 then
        k = 4
      end
    end

    if this.IsOverlapping(this.X, this.Y) then
      for i = 1, 4 do
        this.X = this.X + this.SRSData[k][i][1]
        this.Y = this.Y + this.SRSData[k][i][2]
        if this.IsOverlapping(this.X, this.Y) then
          this.X = this.X - this.SRSData[k][i][1]
          this.Y = this.Y - this.SRSData[k][i][2]
        else
          return 0
        end
      end
      this.CurrentFormID = old
      return 0
    else
      return 0
    end
  end

  -- Check if overlapping
  this.IsOverlapping = function(x_pos, y_pos)
    for y = 1, #this.Forms[this.CurrentFormID] do
      for x = 1, #this.Forms[this.CurrentFormID][y] do
        if this.Forms[this.CurrentFormID][y][x] > 0 then
          if y + y_pos - 1 > 40 then return true end
          if y + y_pos - 1 < 1 then return true end
          if (x + x_pos - 1) < 1 or (x + x_pos - 1) > 10 then return true end
          --if this.Board.Data[y_pos] == nil then print('y') end
          --print(this.Board.Data[y + y_pos - 1] == nil)
          if this.Board.Data[y + y_pos - 1][x + x_pos - 1] > 0 then return true end
        end
      end
    end
    return false
  end

  -- Try Move Left
  this.TryMoveLeft = function()
    this.X = this.X - 1
    if this.IsOverlapping(this.X, this.Y) then
      this.X = this.X + 1
    else
      this.OnFloorTimer = 0
    end
  end

  -- Try Move Right
  this.TryMoveRight = function()
    this.X = this.X + 1
    if this.IsOverlapping(this.X, this.Y) then
      this.X = this.X - 1
    else
      this.OnFloorTimer = 0
    end
  end

  -- Try Move Down
  this.TryMoveDown = function()
    this.Y = this.Y + 1
    if this.IsOverlapping(this.X, this.Y) then this.Y = this.Y - 1 end
  end

  -- Hard drop
  this.HardDrop = function()
    while not this.IsOverlapping(this.X, this.Y) do
      this.Y = this.Y + 1
    end
    this.Y = this.Y - 1
    this.IsLockDown = true
  end

  -- Soft drop
  this.SoftDrop = function()
    while not this.IsOverlapping(this.X, this.Y) do
      this.Y = this.Y + 1
    end
    this.Y = this.Y - 1
  end

  -- Check if the piece is on floor for more than 0.5s then place/lock the piece
  this.CheckAndLock = function(dt)
    this.Y = this.Y + 1
    if this.IsOverlapping(this.X, this.Y) then
      this.OnFloorTimer = this.OnFloorTimer + dt
    else
      this.OnFloorTimer = 0
    end
    this.Y = this.Y - 1
    if this.OnFloorTimer >= 0.5 then
      this.IsLockDown = true
    end
  end

  -- Check the piece mobility, useful for t-spin
  this.IsImmobile = function()
    return this.IsOverlapping(this.X - 1, this.Y) and this.IsOverlapping(this.X + 1, this.Y) and this.IsOverlapping(this.X, this.Y + 1)
  end

  -- Update
  this.Update = function(dt)
    if not this.Board.EnableAI then
      -- Das
      if InputManager.Right.IsDown() then
        if this.DasDelayTimer == 0 then this.TryMoveRight() end
        this.DasDelayTimer = this.DasDelayTimer + dt
        if this.DasDelayTimer >= this.Board.Game.DasDelay then
          this.DasDelayTimer = this.Board.Game.DasDelay
          if this.DasAutoRepeatTimer == 0 then this.TryMoveRight() end
          this.DasAutoRepeatTimer = this.DasAutoRepeatTimer + dt
          if this.DasAutoRepeatTimer >= this.Board.Game.DasInterval then this.DasAutoRepeatTimer = 0 end
        end
      elseif InputManager.Left.IsDown() then
        if this.DasDelayTimer == 0 then this.TryMoveLeft() end
        this.DasDelayTimer = this.DasDelayTimer + dt
        if this.DasDelayTimer >= this.Board.Game.DasDelay then
          this.DasDelayTimer = this.Board.Game.DasDelay
          if this.DasAutoRepeatTimer == 0 then this.TryMoveLeft() end
          this.DasAutoRepeatTimer = this.DasAutoRepeatTimer + dt
          if this.DasAutoRepeatTimer >= this.Board.Game.DasInterval then this.DasAutoRepeatTimer = 0 end
        end
      else
        this.DasDelayTimer = 0
        this.DasAutoRepeatTimer = 0
      end

      -- Hard drop
      if InputManager.Space.JustDown() then this.HardDrop() end

      -- Soft drop
      if InputManager.Down.IsDown() then
        if InputManager.Down.JustDown() then this.TryMoveDown() end
        this.SoftDropTimer = this.SoftDropTimer + dt
        if this.SoftDropTimer >= this.Board.Game.SoftDropInterval then
          this.SoftDropTimer = 0
          this.TryMoveDown()
        end
      end

      -- Rotating
      if InputManager.Up.JustDown() then this.Rotate(1) end
      if InputManager.Z.JustDown() then this.Rotate(3) end
    end

    -- Check and lock piece
    this.CheckAndLock(dt)
    if this.IsLockDown then this.Board.HoldCounter = 0 end
  end

  -- Draw
  this.Draw = function()
    -- Find ghost piece y position
    local y_test = this.Y
    while not this.IsOverlapping(this.X, y_test) do
      y_test = y_test + 1
    end
    y_test = y_test - 1

    -- Draw the piece and ghost piece
    for y = 1, #this.Forms[this.CurrentFormID] do
      for x = 1, #this.Forms[this.CurrentFormID][y] do
        if this.Forms[this.CurrentFormID][y][x] > 0 then
          if not this.IsLockDown then
            love.graphics.setColor(0.250980, 0.250980, 0.250980, 0.250980)
            love.graphics.rectangle('fill', x + this.X - 2 + 5, y + y_test - 2, 1, 1)
          end
          love.graphics.setColor(
            this.Board.Game.Colors[this.Forms[this.CurrentFormID][y][x]][1],
            this.Board.Game.Colors[this.Forms[this.CurrentFormID][y][x]][2],
            this.Board.Game.Colors[this.Forms[this.CurrentFormID][y][x]][3],
            this.Board.Game.Colors[this.Forms[this.CurrentFormID][y][x]][4]
          )
          love.graphics.rectangle('fill', x + this.X - 2 + 5, y + this.Y - 2, 1, 1)
        end
      end
    end
    love.graphics.setColor(1, 1, 1, 1)
  end

  return this
end

return Tetrismino
