--local Game = require "Game/Game"
local Key = require 'Input/Key'
local InputManager = require 'Input/InputManager'
local Tetrismino = require "Game/Tetrismino"
local I = require "Game/Tetrisminoes/I"
local J = require "Game/Tetrisminoes/J"
local L = require "Game/Tetrisminoes/L"
local O = require "Game/Tetrisminoes/O"
local S = require "Game/Tetrisminoes/S"
local T = require "Game/Tetrisminoes/T"
local Z = require "Game/Tetrisminoes/Z"

TetrisBoard = { }

TetrisBoard.New = function()
  local this = {}

  this.Game = {};
  this.Opponent = {};
  this.EnableAI = false

  this.Data = {}
  for i = 1, 40 do
    this.Data[i] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
  end
  this.CurrentPiece = {}
  this.HoldPieceID = '0'
  this.NextPiece = {}

  this.Bag = { 'I', 'J', 'L', 'S', 'T', 'Z', 'O' }

  this.InGameCounter = 0
  this.HoldCounter = 0
  this.LineClearDelayCounter = 0
  --this.NonUpdateCounter = 0
  this.PieceTakenFromBagCounter = 0
  this.RENCounter = 0
  this.GarbageCounter = 0
  this.IsB2bReady = false

  --Graphic
  this.X = 0
  this.Y = 0
  this.Width = 0
  this.Height = 0

  -- Initialize
  this.Initialize = function(game, x_position, y_position, width, height)
    this.Game = game
    this.X = x_position
    this.Y = y_position
    this.Width = width
    this.Height = height

    -- graphic stuffs
    this.Canvas = love.graphics.newCanvas(20, 40)
    this.Quad = love.graphics.newQuad(0, 20, 20, 20, 20, 40)
    this.PictureOfTetrisminoes = love.graphics.newImage('Graphic/Tetrisminos.png')
    this.QuadOfTetrisminoes = {
      ['I'] = love.graphics.newQuad(0, 0, 4, 4, 28, 4),
      ['J'] = love.graphics.newQuad(4, 0, 4, 4, 28, 4),
      ['L'] = love.graphics.newQuad(8, 0, 4, 4, 28, 4),
      ['S'] = love.graphics.newQuad(12, 0, 4, 4, 28, 4),
      ['T'] = love.graphics.newQuad(16, 0, 4, 4, 28, 4),
      ['Z'] = love.graphics.newQuad(20, 0, 4, 4, 28, 4),
      ['O'] = love.graphics.newQuad(24, 0, 4, 4, 28, 4)
    }
    this.a = love.graphics.newQuad(0, 0, 4, 4, 28, 4)

    for i = 1, 40 do
      this.Data[i] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    end

    this.InGameCounter = 0
    this.HoldCounter = 0
    this.LineClearDelayCounter = 0
    --this.NonUpdateCounter = 0
    this.PieceTakenFromBagCounter = 0
    this.RENCounter = 0
    this.GarbageCounter = 0
    this.IsB2bReady = false

    this.CurrentPiece = {}
    this.HoldPieceID = '0'
    this.NextPiece = {}

    TetrisBoard.ShuffleBag(this)
    TetrisBoard.UpdateQueue(this)
    TetrisBoard.ChangeCurrentPiece(this)
  end

  -- Update
  this.Update = function(dt)
    this.LineClearDelayCounter = this.LineClearDelayCounter + dt
    this.LineClearDelayCounter = math.min(this.Game.LineClearDelay + 0.1, this.LineClearDelayCounter)
    if this.LineClearDelayCounter >= this.Game.LineClearDelay then
      --[[if this.NonUpdateCounter > 0 then ]]
      TetrisBoard.ClearLine(this, TetrisBoard.LineClearList(this))
      -- end
      --this.NonUpdateCounter = 0
      this.CurrentPiece.Update(dt)
      if not TetrisBoard.IsGameOver(this) then
        this.InGameCounter = this.InGameCounter + dt
        if this.InGameCounter >= this.Game.GravityInterval then
          this.InGameCounter = 0
          if not InputManager.Down.IsDown() then this.CurrentPiece.TryMoveDown() end
        end
        if InputManager.C.JustDown() then TetrisBoard.Hold(this) end
        if this.CurrentPiece.IsLockDown then
          local is_t_spin = TetrisBoard.IsTSpin(this)
          TetrisBoard.PlacePiece(this)
          local line_clear_list = TetrisBoard.LineClearList(this)
          local count_garbage = TetrisBoard.CountGarbage(this, line_clear_list, is_t_spin)
          if #line_clear_list < 1 then
            TetrisBoard.PlaceGarbage(this)
          else
            if this.GarbageCounter > count_garbage then
              this.GarbageCounter = this.GarbageCounter - count_garbage
            else
              TetrisBoard.SendGarbage(this, count_garbage - this.GarbageCounter)
              this.GarbageCounter = 0
            end
            --this.LineClearDelayCounter = this.Game.LineClearDelay
            this.LineClearDelayCounter = 0
          end--]]
          TetrisBoard.ChangeCurrentPiece(this)
        end
      end
    --else
      --this.NonUpdateCounter = this.NonUpdateCounter + 1
      --this.NonUpdateCounter = math.min(2, this.NonUpdateCounter)
    end
  end

  -- Draw to render target
  this.DrawToCanvas = function()
    love.graphics.setCanvas(this.Canvas)
    love.graphics.clear()

    love.graphics.setColor(1, 1, 1, 0.5)

    -- Draw data
    for y = 1, 40 do
      for x = 1, 10 do
        if this.Data[y][x] > 0 then
          love.graphics.setColor(
            this.Game.Colors[this.Data[y][x]][1],
            this.Game.Colors[this.Data[y][x]][2],
            this.Game.Colors[this.Data[y][x]][3],
            this.Game.Colors[this.Data[y][x]][4]
          )
          love.graphics.rectangle('fill', x + 5 - 1, y - 1, 1, 1)
          love.graphics.setColor(1, 1, 1, 1)
        end
      end
    end

    -- Draw current piece
    this.CurrentPiece.Draw()

    -- Draw hold piece
    if this.HoldPieceID ~= '0' then
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.draw(this.PictureOfTetrisminoes, this.QuadOfTetrisminoes[this.HoldPieceID], 0, 20, 0, 1, 1, 0, 0, 0, 0)
    end

    -- Draw next piece preview
    for i = 0, this.Game.NumberOfPreview - 1 do
      love.graphics.draw(this.PictureOfTetrisminoes, this.QuadOfTetrisminoes[this.NextPiece[i + 1]], 16, 20 + 4 * i, 0, 1, 1)
    end

    -- Draw line clear animation
    local line_clear_list = TetrisBoard.LineClearList(this)
    if this.LineClearDelayCounter >= 0 and #line_clear_list > 0 then
      love.graphics.setColor(
      math.min(1, (this.Game.LineClearDelay - this.LineClearDelayCounter) * 2 / this.Game.LineClearDelay),
      math.min(1, (this.Game.LineClearDelay - this.LineClearDelayCounter) * 2 / this.Game.LineClearDelay),
      math.min(1, (this.Game.LineClearDelay - this.LineClearDelayCounter) * 2 / this.Game.LineClearDelay),
      math.min(1, (this.Game.LineClearDelay - this.LineClearDelayCounter) * 2 / this.Game.LineClearDelay))--]]
      for i = 1, #line_clear_list do
        love.graphics.rectangle('fill', 5, line_clear_list[i] - 1, math.min(1, (this.Game.LineClearDelay - this.LineClearDelayCounter) * 2 / this.Game.LineClearDelay) * 10, 1)
      end
      love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.setCanvas()
  end

  -- Draw
  this.Draw = function()

    -- draw decoration
    love.graphics.setColor(0.95, 0.95, 0.95, 1)
    love.graphics.rectangle('fill', this.X - this.Width / 10, this.Y - 8, this.Width * 1.6 + 8, this.Height + 16)
    love.graphics.rectangle('fill', this.X - this.Width * 0.5 - 8, this.Y - 8, this.Width * 0.5 + 16, this.Height / 5 + 16)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle('fill', this.X, this.Y, this.Width, this.Height)
    love.graphics.rectangle('fill', this.X + this.Width * 11 / 10, this.Y, this.Width / 5 * 2, this.Height)
    love.graphics.rectangle('fill', this.X + this.Width + 8, this.Y, this.Width / 10 - 16, this.Height)
    love.graphics.rectangle('fill', this.X - this.Width / 10 + 8, this.Y, this.Width / 10 - 16, this.Height)
    love.graphics.rectangle('fill', this.X - this.Width / 2, this.Y, this.Width / 5 * 2, this.Height / 5)
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    for i = 1, 9 do love.graphics.rectangle('fill', this.X + this.Width * i / 10 - 2, this.Y, 4, this.Height) end
    for i = 1, 19 do love.graphics.rectangle('fill', this.X, this.Y + this.Height * i / 20 - 2, this.Width, 4) end

    -- draw garbage warning
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle('fill', this.X + this.Width + 8, this.Y + this.Height - this.GarbageCounter * this.Height / 20, this.Width / 10 - 16, this.GarbageCounter * this.Height / 20)
    love.graphics.rectangle('fill', this.X - this.Width / 10 + 8, this.Y + this.Height - this.GarbageCounter * this.Height / 20, this.Width / 10 - 16, this.GarbageCounter * this.Height / 20)

    -- draw the board
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(this.Canvas, this.Quad, this.X - this.Width / 2, this.Y, 0, this.Width / 10, this.Height / 20, 0, 0, 0, 0)
  end

  return this
end

-- Normalize Board
TetrisBoard.NormalizeBoard = function(board)
  local result = {}
  for i = 1, 20 do
    result[i] = {0,0,0,0,0,0,0,0,0,0}
    for k = 1, 10 do
      result[i][k] = math.min(1, board.Data[i + 20][k])
    end
  end
  return result
end

-- SetOpponent
TetrisBoard.SetOpponent = function(board_1 , board_2)
  board_1.Opponent = board_2
  board_2.Opponent = board_1
end

-- Shuffle Bag of 7
TetrisBoard.ShuffleBag = function(board)
  local n = 7;
  while (n > 1) do
    n = n - 1
    local k = love.math.random(1, n + 1)
    local place_holder = board.Bag[k];
    board.Bag[k] = board.Bag[n];
    board.Bag[n] = place_holder;
  end
end

-- Update the next piece queue
TetrisBoard.UpdateQueue = function(board)
  local n = #board.NextPiece
  for i = 1, board.Game.NumberOfPreview - n do
    board.NextPiece[#board.NextPiece + 1] = board.Bag[board.PieceTakenFromBagCounter + 1]
    board.PieceTakenFromBagCounter = board.PieceTakenFromBagCounter + 1
    if board.PieceTakenFromBagCounter >= 7 then
      board.PieceTakenFromBagCounter = 0
      TetrisBoard.ShuffleBag(board)
    end
  end
end

-- Set current piece by char
TetrisBoard.CreateCurrentPiece = function(board, piece)
  if piece == 'I' then board.CurrentPiece = I.New(board, 4, 19)
  elseif piece == 'J' then board.CurrentPiece = J.New(board, 4, 19)
  elseif piece == 'L' then board.CurrentPiece = L.New(board, 4, 19)
  elseif piece == 'S' then board.CurrentPiece = S.New(board, 4, 19)
  elseif piece == 'T' then board.CurrentPiece = T.New(board, 4, 19)
  elseif piece == 'Z' then board.CurrentPiece = Z.New(board, 4, 19)
  elseif piece == 'O' then board.CurrentPiece = O.New(board, 5, 19)
  end
end

-- Change current piece
TetrisBoard.ChangeCurrentPiece = function(board)
  TetrisBoard.CreateCurrentPiece(board, board.NextPiece[1])

  table.remove(board.NextPiece, 1)
  TetrisBoard.UpdateQueue(board)
end

-- Hold the current piece
TetrisBoard.Hold = function(board)
  if board.HoldCounter == 0 then
    board.HoldCounter = 1
    if board.HoldPieceID == '0' then
      board.HoldPieceID = board.CurrentPiece.ID
      TetrisBoard.ChangeCurrentPiece(board)
    else
      local place_holder = board.HoldPieceID
      board.HoldPieceID = board.CurrentPiece.ID
      TetrisBoard.CreateCurrentPiece(board, place_holder)
    end
  end
end

-- Place piece into the board
TetrisBoard.PlacePiece = function(board)
  for y = 1, #board.CurrentPiece.Forms[board.CurrentPiece.CurrentFormID] do
    for x = 1, #board.CurrentPiece.Forms[board.CurrentPiece.CurrentFormID][y] do
      if board.CurrentPiece.Forms[board.CurrentPiece.CurrentFormID][y][x] > 0 then
        --print(board.CurrentPiece.Y)
        --print(board.Data[y + board.CurrentPiece.Y - 1] == nil)
        board.Data[y + board.CurrentPiece.Y - 1][x + board.CurrentPiece.X - 1] = board.CurrentPiece.Forms[board.CurrentPiece.CurrentFormID][y][x]
      end
    end
  end
end

-- Check if game over
TetrisBoard.IsGameOver = function(board)
  return board.CurrentPiece.IsLockDown and board.CurrentPiece.Y <= 19
end

-- Check if t-spin
TetrisBoard.IsTSpin = function(board)
  return board.CurrentPiece.ID == 'T' and board.CurrentPiece.IsImmobile()
end

-- Find the list of lines cleared
TetrisBoard.LineClearList = function(board)
  --TetrisBoard.PlacePiece(board)
  local result = {}
  for y = 21, 40 do
    local row_product = 1
    for i = 1, 10 do row_product = row_product * board.Data[y][i] end
    if row_product > 0 then result[#result + 1] = y end
  end
  return result
end

-- Count number of garbage sent
TetrisBoard.CountGarbage = function(board, line_clear_list, is_t_spin)
  local result = 0

  if is_t_spin then
    if #line_clear_list > 0 then
      result = #line_clear_list * 2
      if board.IsB2bReady then result = result + 1 end
      board.IsB2bReady = true
    end
  else
    if #line_clear_list == 1 then
      board.IsB2bReady = false
    elseif #line_clear_list == 2 then
      result = 1
      board.IsB2bReady = false
    elseif #line_clear_list == 3 then
      result = 2
      board.IsB2bReady = false
    elseif #line_clear_list == 4 then
      result = 4
      if board.IsB2bReady then result = result + 1 end
      board.IsB2bReady = true
    end
  end

  --TetrisBoard.ClearLine(board, line_clear_list)

  -- Check if perfect clear

  --[[local row_sum = 0
  for i = 1, 10 do row_sum = row_sum + board.Data[40][i] end
  if row_sum == 0 then result = 10 end]]

  local full_row_count = 0
  for i = 21, 40 do
    local sum_row = 0
    for k = 1, 10 do
      if board.Data[i][k] > 0 then sum_row = sum_row + 1 end
    end
    if sum_row == 0 or sum_row == 10 then full_row_count = full_row_count + 1 end
  end
  if full_row_count == 20 then result = 10 end

  -- REN implementation
  if #line_clear_list > 0 then
    board.RENCounter = board.RENCounter + 1
  elseif #line_clear_list == 0 then
    board.RENCounter = 0
  end
  if board.RENCounter < 10 and board.RENCounter > 0 then
    result = result + (board.RENCounter - (board.RENCounter % 2)) / 2
  elseif board.RENCounter == 10 then
    result = result + 4
  elseif board.RENCounter > 10 then
    result = result + 5
  end

  return result
end

-- Clear line
TetrisBoard.ClearLine = function(board, line_clear_list)
  for k = 1, #line_clear_list do
    for i = line_clear_list[k], 2, -1 do
      board.Data[i] = board.Data[i - 1]
    end
    board.Data[1] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
  end
end

-- Send garbage to opponent
TetrisBoard.SendGarbage = function(board, garbage_count)
  board.Opponent.GarbageCounter = board.Opponent.GarbageCounter + garbage_count
end

-- Place garbage to board
TetrisBoard.PlaceGarbage = function(board)
  local garbage_counter = 0
  local garbages = {}

  --[[if board.GarbageCounter <= 4 then
    local a_garbage_line = {8, 8, 8, 8, 8, 8, 8, 8, 8, 8}
    a_garbage_line[love.math.random(1, 10)] = 0
    for i = 1, board.GarbageCounter do garbages[#garbages + 1] = a_garbage_line end
  else
    while garbage_counter < board.GarbageCounter do
      local garbage_hole_distribution = { 1, 1, 2, 2, 3, 4, 4, 4 }
      local to_add = math.min(board.GarbageCounter - garbage_counter, garbage_hole_distribution[love.math.random(1, 8)])
      local a_garbage_line = {8, 8, 8, 8, 8, 8, 8, 8, 8, 8}
      a_garbage_line[love.math.random(1, 10)] = 0
      for i = 1, to_add do garbages[#garbages + 1] = a_garbage_line end
      garbage_counter = garbage_counter + to_add
    end
  end

  --for i = #garbages + 1, 40 do board.Data[i - #garbages] = board.Data[i] end
  --for i = 1, #garbages do board.Data[41 - i] = garbages[i] end
  for i = 1, #garbages do
    table.remove(board.Data, 1)
    table.insert(board.Data, garbages[i])
  end--]]

  if board.GarbageCounter <= 4 then
    local a_hold_pos = love.math.random(1, 10)
    for i = 1, board.GarbageCounter do garbages[#garbages + 1] = a_hold_pos end
  else
    while garbage_counter < board.GarbageCounter do
      local garbage_hole_distribution = { 1, 1, 2, 2, 3, 4, 4, 4 }
      local to_add = math.min(board.GarbageCounter - garbage_counter, garbage_hole_distribution[love.math.random(1, 8)])
      local a_hold_pos = love.math.random(1, 10)
      for i = 1, to_add do garbages[#garbages + 1] = a_hold_pos end
      garbage_counter = garbage_counter + to_add
    end
  end

  for i = #garbages + 1, 40 do
    for k = 1, 10 do
      board.Data[i - #garbages][k] = board.Data[i][k]
    end
  end
  --for i = 1, #garbages do board.Data[41 - i] = garbages[i] end
  for i = 1, #garbages do
    for k = 1, 10 do
      board.Data[41 - i][k] = 8
    end
    board.Data[41 - i][garbages[i]] = 0
  end

  board.GarbageCounter = 0
end

return TetrisBoard
