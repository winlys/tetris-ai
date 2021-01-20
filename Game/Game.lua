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
local AI = require "AI/MCTS/AI"
local Evaluator = require "AI/MCTS/Evaluator"
local Generator = require "AI/MCTS/Generator"
local Node = require "AI/MCTS/Node"
local Tree = require "AI/MCTS/Tree"

return {

  New = function()
    local this = {}

    this.Board_1 = TetrisBoard.New()
    this.Board_2 = TetrisBoard.New()

    -- Changeable parameter
    this.NumberOfPreview = 5
    this.DasDelay = 0.25
    this.DasInterval = 0.03
    this.SoftDropInterval = 0.03
    this.GravityInterval = 0.5
    this.LineClearDelay = 0.5

    -- Color
    this.Colors = {
      {0, 1, 1, 1}, -- Aqua
      {0, 0, 1, 1}, -- Blue
      {1, 0.647058, 0, 1}, -- Orange
      {1, 1, 0, 1}, -- Yellow
      {0.486274, 0.988235, 0, 1}, -- Lawn Green
      {0.6, 0, 1, 1}, -- Purple
      {1, 0, 0, 1}, -- Red
      {0.627451, 0.627451, 0.627451, 1} -- Light Gray
    }


    -- Initialize
    this.Initialize = function()
      this.Board_1.Initialize(this, 272, 140, 400, 800)
      this.Board_2.Initialize(this, 1232, 140, 400, 800)
      this.Board_2.EnableAI = true
      --this.Board_1.EnableAI = true
      TetrisBoard.SetOpponent(this.Board_1, this.Board_2)
    end


    -- Update
    this.Update = function(dt)

      this.Board_1.Update(dt)
      this.Board_2.Update(dt)
      --[[if TetrisBoard.IsGameOver(this.Board_1) or TetrisBoard.IsGameOver(this.Board_2) then
        this.Board_1.Initialize(this, 272, 140, 400, 800)
        this.Board_2.Initialize(this, 1232, 140, 400, 800)
      end]]
    end

    -- Draw to canvas
    this.DrawToCanvas = function()
      this.Board_1.DrawToCanvas()
      this.Board_2.DrawToCanvas()
    end

    -- Draw
    this.Draw = function()
      this.Board_1.Draw()
      this.Board_2.Draw()
    end

    return this
  end

}
