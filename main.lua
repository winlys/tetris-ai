math.randomseed(os.time())

local Game = require 'Game/Game'
local TetrisBoard = require 'Game/TetrisBoard'
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
local Node = require "AI/MCTS_2/Node"
local Tree = require "AI/MCTS_2/Tree"
local Evaluator = require "AI/MCTS_2/Evaluator"
local AI = require "AI/MCTS_2/AI" --]]
local TN = require "AI/CLTN/TN"

--[[local Generator = require "AI/MCTS/Generator"
local Evaluator = require "AI/MCTS/Evaluator"
local Node = require "AI/MCTS/Node"
local Tree = require "AI/MCTS/Tree"
local AI = require "AI/MCTS/AI"]]


function love.load(arg)
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.graphics.setBlendMode('alpha')
  canvas = love.graphics.newCanvas(1920, 1080)

  TheGame = Game.New()
  TheGame.Initialize()

  --[[file = io.open("weights.txt", "a")
  file:write("--test1" .. "\n")
  file.close()

  file = io.open("weights.txt", "a")
  file:write("--test2")
  file.close()--]]

  e = TN.New(3, 2)

  --a = e.Population[1]
  a = AI.New()
  a.SetParameter(5, 250)--]]
  c = AI.New()
  c.SetParameter(5, 250)--]]
  e.SaveWeight(1)
  e.SaveWeight(2)
  e.Mutuate(e.Population[1], e.Population[2])
  e.SaveWeight(#e.Population)
end


function love.update(dt)
  if TheGame.Board_2.LineClearDelayCounter >= TheGame.LineClearDelay then
    b = a.FindMove(TetrisBoard.NormalizeBoard(TheGame.Board_2), TheGame.Board_2.CurrentPiece.ID, TheGame.Board_2.HoldPieceID, TheGame.Board_2.NextPiece, TheGame.Board_2.IsB2bReady, TheGame.Board_2.RENCounter, TheGame.Board_2.GarbageCounter)
    for i = 1, #b do
      if b[i] == 'L' then TheGame.Board_2.CurrentPiece.TryMoveLeft()
      elseif b[i] == 'R' then TheGame.Board_2.CurrentPiece.TryMoveRight()
      elseif b[i] == 'D' then TheGame.Board_2.CurrentPiece.TryMoveDown()
      elseif b[i] == 'HD' then TheGame.Board_2.CurrentPiece.HardDrop()
      elseif b[i] == 'SD' then TheGame.Board_2.CurrentPiece.SoftDrop()
      elseif b[i] == 'RR' then TheGame.Board_2.CurrentPiece.Rotate(1)
      elseif b[i] == 'RL' then TheGame.Board_2.CurrentPiece.Rotate(3)
      elseif b[i] == 'Hold' then TetrisBoard.Hold(TheGame.Board_2)
      end
      --love.timer.sleep(0.05)
    end
  end--]]
  if TheGame.Board_1.LineClearDelayCounter >= TheGame.LineClearDelay then
    d = a.FindMove(TetrisBoard.NormalizeBoard(TheGame.Board_1), TheGame.Board_1.CurrentPiece.ID, TheGame.Board_1.HoldPieceID, TheGame.Board_1.NextPiece, TheGame.Board_1.IsB2bReady, TheGame.Board_1.RENCounter, TheGame.Board_1.GarbageCounter)
    for i = 1, #d do
      if d[i] == 'L' then TheGame.Board_1.CurrentPiece.TryMoveLeft()
      elseif d[i] == 'R' then TheGame.Board_1.CurrentPiece.TryMoveRight()
      elseif d[i] == 'D' then TheGame.Board_1.CurrentPiece.TryMoveDown()
      elseif d[i] == 'HD' then TheGame.Board_1.CurrentPiece.HardDrop()
      elseif d[i] == 'SD' then TheGame.Board_1.CurrentPiece.SoftDrop()
      elseif d[i] == 'RR' then TheGame.Board_1.CurrentPiece.Rotate(1)
      elseif d[i] == 'RL' then TheGame.Board_1.CurrentPiece.Rotate(3)
      elseif d[i] == 'Hold' then TetrisBoard.Hold(TheGame.Board_1)
      end
      --love.timer.sleep(0.05)
    end
  end--]]
  --love.timer.sleep(0.1)--]]
  print(a.Tree.Root.Visit)
  TheGame.Update(dt)
  if TetrisBoard.IsGameOver(TheGame.Board_1) or TetrisBoard.IsGameOver(TheGame.Board_2) then
    a.Tree = nil
    a.Tree = Tree.New(a)
    c.Tree = nil
    c.Tree = Tree.New(c)
    TheGame.Board_1.Initialize(TheGame, 272, 140, 400, 800)
    TheGame.Board_2.Initialize(TheGame, 1232, 140, 400, 800)
  end
end


function love.draw()
  love.graphics.clear()

  --love.graphics.setBlendMode('alpha', 'alphamultiply')
  love.graphics.setBlendMode('alpha', 'premultiplied')
  TheGame.DrawToCanvas()

  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  -- draw here

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle('fill', 1920 / 2 - 4, 0, 8, 1080)
  TheGame.Draw()

  -- draw here
  love.graphics.setCanvas()

  -- draw render target
  love.graphics.setColor(1, 1, 1, 1)
  local scale = math.min(love.graphics.getWidth() / 1920, love.graphics.getHeight() / 1080)
  love.graphics.draw(canvas, (love.graphics.getWidth() - 1920 * scale) / 2, (love.graphics.getHeight() - 1080 * scale) / 2, 0, scale, scale)

  love.graphics.setBlendMode('alpha', 'alphamultiply')
  --love.graphics.print(b, 0, 0)
end
