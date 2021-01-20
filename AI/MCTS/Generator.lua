local TetrisBoard = require 'Game/TetrisBoard'
local Node = require "AI/MCTS/Node"

local Generator = {}

-- L - Move left once
-- R - Move right once
-- D - Move down once
-- HD - Hard drop
-- SD - Soft drop
-- RR - Rotate right
-- RL - Rotate left
-- Hold - Hold piece

Generator.Paths = {
  ['O'] = {
    { 'L', 'L', 'L', 'HD' },
    { 'L', 'L', 'HD' },
    { 'L', 'HD' },
    { 'HD' },
    { 'R', 'HD' },
    { 'R', 'R', 'HD' },
    { 'R', 'R', 'R', 'HD' },
    { 'R', 'R', 'R', 'R', 'HD' },
    { 'R', 'R', 'R', 'R', 'R', 'HD' },
  },
  ['I'] = {
    { 'L', 'L', 'L', 'HD' },
    { 'L', 'L', 'HD' },
    { 'L', 'HD' },
    { 'HD' },
    { 'R', 'HD' },
    { 'R', 'R', 'HD' },
    { 'R', 'R', 'R', 'HD' },

    { 'RR', 'L', 'L', 'L', 'L', 'L', 'HD' },
    { 'RR', 'L', 'L', 'L', 'L', 'HD' },
    { 'RR', 'L', 'L', 'L', 'HD' },
    { 'RR', 'L', 'L', 'HD' },
    { 'RR', 'L', 'HD' },
    { 'RR', 'HD' },
    { 'RR', 'R', 'HD' },
    { 'RR', 'R', 'R', 'HD' },
    { 'RR', 'R', 'R', 'R', 'HD' },
    { 'RR', 'R', 'R', 'R', 'R', 'HD' },
  },
  ['J'] = {
    { 'L', 'L', 'L', 'HD' },
    { 'L', 'L', 'HD' },
    { 'L', 'HD' },
    { 'HD' },
    { 'R', 'HD' },
    { 'R', 'R', 'HD' },
    { 'R', 'R', 'R', 'HD' },
    { 'R', 'R', 'R', 'R', 'HD' },

    { 'RR', 'L', 'L', 'L', 'L', 'HD' },
    { 'RR', 'L', 'L', 'L', 'HD' },
    { 'RR', 'L', 'L', 'HD' },
    { 'RR', 'L', 'HD' },
    { 'RR', 'HD' },
    { 'RR', 'R', 'HD' },
    { 'RR', 'R', 'R', 'HD' },
    { 'RR', 'R', 'R', 'R', 'HD' },
    { 'RR', 'R', 'R', 'R', 'R', 'HD' },

    { 'RL', 'L', 'L', 'L', 'HD' },
    { 'RL', 'L', 'L', 'HD' },
    { 'RL', 'L', 'HD' },
    { 'RL', 'HD' },
    { 'RL', 'R', 'HD' },
    { 'RL', 'R', 'R', 'HD' },
    { 'RL', 'R', 'R', 'R', 'HD' },
    { 'RL', 'R', 'R', 'R', 'R', 'HD' },
    { 'RL', 'R', 'R', 'R', 'R', 'R', 'HD' },

    { 'RR', 'RR', 'L', 'L', 'L', 'HD' },
    { 'RR', 'RR', 'L', 'L', 'HD' },
    { 'RR', 'RR', 'L', 'HD' },
    { 'RR', 'RR', 'HD' },
    { 'RR', 'RR', 'R', 'HD' },
    { 'RR', 'RR', 'R', 'R', 'HD' },
    { 'RR', 'RR', 'R', 'R', 'R', 'HD' },
    { 'RR', 'RR', 'R', 'R', 'R', 'R', 'HD' },
  },
  ['L'] = {
    { 'L', 'L', 'L', 'HD' },
    { 'L', 'L', 'HD' },
    { 'L', 'HD' },
    { 'HD' },
    { 'R', 'HD' },
    { 'R', 'R', 'HD' },
    { 'R', 'R', 'R', 'HD' },
    { 'R', 'R', 'R', 'R', 'HD' },

    { 'RR', 'L', 'L', 'L', 'L', 'HD' },
    { 'RR', 'L', 'L', 'L', 'HD' },
    { 'RR', 'L', 'L', 'HD' },
    { 'RR', 'L', 'HD' },
    { 'RR', 'HD' },
    { 'RR', 'R', 'HD' },
    { 'RR', 'R', 'R', 'HD' },
    { 'RR', 'R', 'R', 'R', 'HD' },
    { 'RR', 'R', 'R', 'R', 'R', 'HD' },

    { 'RL', 'L', 'L', 'L', 'HD' },
    { 'RL', 'L', 'L', 'HD' },
    { 'RL', 'L', 'HD' },
    { 'RL', 'HD' },
    { 'RL', 'R', 'HD' },
    { 'RL', 'R', 'R', 'HD' },
    { 'RL', 'R', 'R', 'R', 'HD' },
    { 'RL', 'R', 'R', 'R', 'R', 'HD' },
    { 'RL', 'R', 'R', 'R', 'R', 'R', 'HD' },

    { 'RR', 'RR', 'L', 'L', 'L', 'HD' },
    { 'RR', 'RR', 'L', 'L', 'HD' },
    { 'RR', 'RR', 'L', 'HD' },
    { 'RR', 'RR', 'HD' },
    { 'RR', 'RR', 'R', 'HD' },
    { 'RR', 'RR', 'R', 'R', 'HD' },
    { 'RR', 'RR', 'R', 'R', 'R', 'HD' },
    { 'RR', 'RR', 'R', 'R', 'R', 'R', 'HD' },
  },
  ['S'] = {
    { 'L', 'L', 'L', 'HD' },
    { 'L', 'L', 'HD' },
    { 'L', 'HD' },
    { 'HD' },
    { 'R', 'HD' },
    { 'R', 'R', 'HD' },
    { 'R', 'R', 'R', 'HD' },
    { 'R', 'R', 'R', 'R', 'HD' },

    { 'RR', 'L', 'L', 'L', 'L', 'HD' },
    { 'RR', 'L', 'L', 'L', 'HD' },
    { 'RR', 'L', 'L', 'HD' },
    { 'RR', 'L', 'HD' },
    { 'RR', 'HD' },
    { 'RR', 'R', 'HD' },
    { 'RR', 'R', 'R', 'HD' },
    { 'RR', 'R', 'R', 'R', 'HD' },
    { 'RR', 'R', 'R', 'R', 'R', 'HD' },
  },
  ['Z'] = {
    { 'L', 'L', 'L', 'HD' },
    { 'L', 'L', 'HD' },
    { 'L', 'HD' },
    { 'HD' },
    { 'R', 'HD' },
    { 'R', 'R', 'HD' },
    { 'R', 'R', 'R', 'HD' },
    { 'R', 'R', 'R', 'R', 'HD' },

    { 'RR', 'L', 'L', 'L', 'L', 'HD' },
    { 'RR', 'L', 'L', 'L', 'HD' },
    { 'RR', 'L', 'L', 'HD' },
    { 'RR', 'L', 'HD' },
    { 'RR', 'HD' },
    { 'RR', 'R', 'HD' },
    { 'RR', 'R', 'R', 'HD' },
    { 'RR', 'R', 'R', 'R', 'HD' },
    { 'RR', 'R', 'R', 'R', 'R', 'HD' },
  },
  ['T'] = {
    ['Normal'] = {
      { 'L', 'L', 'L', 'HD' },
      { 'L', 'L', 'HD' },
      { 'L', 'HD' },
      { 'HD' },
      { 'R', 'HD' },
      { 'R', 'R', 'HD' },
      { 'R', 'R', 'R', 'HD' },
      { 'R', 'R', 'R', 'R', 'HD' },

      { 'RR', 'L', 'L', 'L', 'L', 'HD' },
      { 'RR', 'L', 'L', 'L', 'HD' },
      { 'RR', 'L', 'L', 'HD' },
      { 'RR', 'L', 'HD' },
      { 'RR', 'HD' },
      { 'RR', 'R', 'HD' },
      { 'RR', 'R', 'R', 'HD' },
      { 'RR', 'R', 'R', 'R', 'HD' },
      { 'RR', 'R', 'R', 'R', 'R', 'HD' },

      { 'RL', 'L', 'L', 'L', 'HD' },
      { 'RL', 'L', 'L', 'HD' },
      { 'RL', 'L', 'HD' },
      { 'RL', 'HD' },
      { 'RL', 'R', 'HD' },
      { 'RL', 'R', 'R', 'HD' },
      { 'RL', 'R', 'R', 'R', 'HD' },
      { 'RL', 'R', 'R', 'R', 'R', 'HD' },
      { 'RL', 'R', 'R', 'R', 'R', 'R', 'HD' },

      { 'RR', 'RR', 'L', 'L', 'L', 'HD' },
      { 'RR', 'RR', 'L', 'L', 'HD' },
      { 'RR', 'RR', 'L', 'HD' },
      { 'RR', 'RR', 'HD' },
      { 'RR', 'RR', 'R', 'HD' },
      { 'RR', 'RR', 'R', 'R', 'HD' },
      { 'RR', 'RR', 'R', 'R', 'R', 'HD' },
      { 'RR', 'RR', 'R', 'R', 'R', 'R', 'HD' },
    },
    ['TSD'] = {
      { 'RR', 'L', 'L', 'L', 'L', 'SD', 'RR', 'HD' },
      { 'RR', 'L', 'L', 'L', 'SD', 'RR', 'HD' },
      { 'RR', 'L', 'L', 'SD', 'RR', 'HD' },
      { 'RR', 'L', 'SD', 'RR', 'HD' },
      { 'RR', 'SD', 'RR', 'HD' },
      { 'RR', 'R', 'SD', 'RR', 'HD' },
      { 'RR', 'R', 'R', 'SD', 'RR', 'HD' },
      { 'RR', 'R', 'R', 'R', 'SD', 'RR', 'HD' },
      { 'RR', 'R', 'R', 'R', 'R', 'SD', 'RR', 'HD' },

      { 'RL', 'L', 'L', 'L', 'SD', 'RL', 'HD' },
      { 'RL', 'L', 'L', 'SD', 'RL', 'HD' },
      { 'RL', 'L', 'SD', 'RL', 'HD' },
      { 'RL', 'SD', 'RL', 'HD' },
      { 'RL', 'R', 'SD', 'RL', 'HD' },
      { 'RL', 'R', 'R', 'SD', 'RL', 'HD' },
      { 'RL', 'R', 'R', 'R', 'SD', 'RL', 'HD' },
      { 'RL', 'R', 'R', 'R', 'R', 'SD', 'RL', 'HD' },
      { 'RL', 'R', 'R', 'R', 'R', 'R', 'SD', 'RL', 'HD' },
    },
    ['STSD'] = {
      -- RR RR
      { 'RL', 'L', 'L', 'L', 'SD', 'RR', 'RR', 'HD' },
      { 'RL', 'L', 'L', 'SD', 'RR', 'RR', 'HD' },
      { 'RL', 'L', 'SD', 'RR', 'RR', 'HD' },
      { 'RL', 'SD', 'RR', 'RR', 'HD' },
      { 'RL', 'R', 'SD', 'RR', 'RR', 'HD' },
      { 'RL', 'R', 'R', 'SD', 'RR', 'RR', 'HD' },
      { 'RL', 'R', 'R', 'R', 'SD', 'RR', 'RR', 'HD' },
      { 'RL', 'R', 'R', 'R', 'R', 'SD', 'RR', 'RR', 'HD' },
      { 'RL', 'R', 'R', 'R', 'R', 'R', 'SD', 'RR', 'RR', 'HD' },

      -- RL RL
      { 'RR', 'L', 'L', 'L', 'L', 'SD', 'RL', 'RL', 'HD' },
      { 'RR', 'L', 'L', 'L', 'SD', 'RL', 'RL', 'HD' },
      { 'RR', 'L', 'L', 'SD', 'RL', 'RL', 'HD' },
      { 'RR', 'L', 'SD', 'RL', 'RL', 'HD' },
      { 'RR', 'SD', 'RL', 'RL', 'HD' },
      { 'RR', 'R', 'SD', 'RL', 'RL', 'HD' },
      { 'RR', 'R', 'R', 'SD', 'RL', 'RL', 'HD' },
      { 'RR', 'R', 'R', 'R', 'SD', 'RL', 'RL', 'HD' },
      { 'RR', 'R', 'R', 'R', 'R', 'SD', 'RL', 'RL', 'HD' },

      -- Tuck right RL
      { 'L', 'L', 'L', 'SD', 'R', 'RL', 'HD' },
      { 'L', 'L', 'SD', 'R', 'RL', 'HD' },
      { 'L', 'SD', 'R', 'RL', 'HD' },
      { 'SD', 'R', 'RL', 'HD' },
      { 'R', 'SD', 'R', 'RL', 'HD' },
      { 'R', 'R', 'SD', 'R', 'RL', 'HD' },
      { 'R', 'R', 'R', 'SD', 'R', 'RL', 'HD' },

      -- Tuck left RR
      { 'L', 'L', 'SD', 'L', 'RR', 'HD' },
      { 'L', 'SD', 'L', 'RR', 'HD' },
      { 'SD', 'L', 'RR', 'HD' },
      { 'R', 'SD', 'L', 'RR', 'HD' },
      { 'R', 'R', 'SD', 'L', 'RR', 'HD' },
      { 'R', 'R', 'R', 'SD', 'L', 'RR', 'HD' },
      { 'R', 'R', 'R', 'R', 'SD', 'L', 'RR', 'HD' },
    },
    --['TSTTSD'] = Generator.Paths['STSD']
  },
}

Generator.SimulatingBoard = TetrisBoard.New()

Generator.SimulatingBoard.SetState = function(node)
  TetrisBoard.CreateCurrentPiece(Generator.SimulatingBoard, node.State.CurrentPiece)
  for i = 1, 20 do
    Generator.SimulatingBoard.Data[i + 20] = node.State.Data[i]
  end
  Generator.SimulatingBoard.IsB2bReady = node.State.IsB2bReady
  Generator.SimulatingBoard.RENCounter = node.State.RENCounter
end

Generator.SimulatingBoard.MovePieceWithQueue = function(queue)
  for i = 1, #queue do
    if queue[i] == 'L' then Generator.SimulatingBoard.CurrentPiece.TryMoveLeft()
    elseif queue[i] == 'R' then Generator.SimulatingBoard.CurrentPiece.TryMoveRight()
    elseif queue[i] == 'D' then Generator.SimulatingBoard.CurrentPiece.TryMoveDown()
    elseif queue[i] == 'HD' then Generator.SimulatingBoard.CurrentPiece.HardDrop()
    elseif queue[i] == 'SD' then Generator.SimulatingBoard.CurrentPiece.HardDrop()
    elseif queue[i] == 'RR' then Generator.SimulatingBoard.CurrentPiece.Rotate(1)
    elseif queue[i] == 'RL' then Generator.SimulatingBoard.CurrentPiece.Rotate(3)
    end
  end
end

Generator.ReNewSimulatingBoard = function()
  Generator.SimulatingBoard = TetrisBoard.New()

  Generator.SimulatingBoard.SetState = function(node)
    TetrisBoard.CreateCurrentPiece(Generator.SimulatingBoard, node.State.CurrentPiece)
    for i = 1, 20 do
      Generator.SimulatingBoard.Data[i + 20] = node.State.Data[i]
    end
    Generator.SimulatingBoard.IsB2bReady = node.State.IsB2bReady
    Generator.SimulatingBoard.RENCounter = node.State.RENCounter
  end

  Generator.SimulatingBoard.MovePieceWithQueue = function(queue)
    for i = 1, #queue do
      if queue[i] == 'L' then Generator.SimulatingBoard.CurrentPiece.TryMoveLeft()
      elseif queue[i] == 'R' then Generator.SimulatingBoard.CurrentPiece.TryMoveRight()
      elseif queue[i] == 'D' then Generator.SimulatingBoard.CurrentPiece.TryMoveDown()
      elseif queue[i] == 'HD' then Generator.SimulatingBoard.CurrentPiece.HardDrop()
      elseif queue[i] == 'SD' then Generator.SimulatingBoard.CurrentPiece.HardDrop()
      elseif queue[i] == 'RR' then Generator.SimulatingBoard.CurrentPiece.Rotate(1)
      elseif queue[i] == 'RL' then Generator.SimulatingBoard.CurrentPiece.Rotate(3)
      end
    end
  end
end

Generator.Generate = function(node)
  if node.State.CurrentPiece == nil then return false end

  Generator.ReNewSimulatingBoard()

  -- if #nextpiece >= 0
  -- Generate move for current piece
  if node.State.CurrentPiece ~= 'T' then
    for i = 1, #Generator.Paths[node.State.CurrentPiece] do
      local child_node = Node.New(false)
      for k = 1, #Generator.Paths[node.State.CurrentPiece][i] do table.insert(child_node.Path, Generator.Paths[node.State.CurrentPiece][i][k]) end -- Set path
      --child_node.Path = Generator.Paths[node.State.CurrentPiece][i] -- Set path
      child_node.State.CurrentPiece = node.State.NextPiece[1] -- Set current piece
      child_node.State.HoldPiece = node.State.HoldPiece -- Set hold piece
      for k = 2, #node.State.NextPiece do child_node.State.NextPiece[k - 1] = node.State.NextPiece[k] end -- Set nect piece queue
      -- Set data, line clear, line sent, ...
      Generator.SimulatingBoard.SetState(node)
      Generator.SimulatingBoard.MovePieceWithQueue(child_node.Path)
      child_node.State.WasTSpin = TetrisBoard.IsTSpin(Generator.SimulatingBoard)
      local line_clear_list = TetrisBoard.LineClearList(Generator.SimulatingBoard)
      child_node.State.LineCleared = #line_clear_list
      child_node.State.LineSent = TetrisBoard.CountGarbage(Generator.SimulatingBoard, line_clear_list, child_node.State.WasTSpin)
      child_node.State.IsB2bReady = Generator.SimulatingBoard.IsB2bReady
      child_node.State.RENCounter = Generator.SimulatingBoard.RENCounter
      for j = 1, 20 do child_node.State.Data[j] = Generator.SimulatingBoard.Data[j + 20] end
      Node.Link(node, child_node)
    end
  else
    for i = 1, #Generator.Paths['T']['Normal'] do
      local child_node = Node.New(false)
      for k = 1, #Generator.Paths['T']['Normal'][i] do table.insert(child_node.Path, Generator.Paths['T']['Normal'][i][k]) end -- Set path
      --child_node.Path = Generator.Paths['T']['Normal'][i] -- Set path
      child_node.State.CurrentPiece = node.State.NextPiece[1] -- Set current piece
      child_node.State.HoldPiece = node.State.HoldPiece -- Set hold piece
      for k = 2, #node.State.NextPiece do child_node.State.NextPiece[k - 1] = node.State.NextPiece[k] end -- Set nect piece queue
      -- Set data, line clear, line sent, ...
      Generator.SimulatingBoard.SetState(node)
      Generator.SimulatingBoard.MovePieceWithQueue(child_node.Path)
      child_node.State.WasTSpin = TetrisBoard.IsTSpin(Generator.SimulatingBoard)
      local line_clear_list = TetrisBoard.LineClearList(Generator.SimulatingBoard)
      child_node.State.LineCleared = #line_clear_list
      child_node.State.LineSent = TetrisBoard.CountGarbage(Generator.SimulatingBoard, line_clear_list, child_node.State.WasTSpin)
      child_node.State.IsB2bReady = Generator.SimulatingBoard.IsB2bReady
      child_node.State.RENCounter = Generator.SimulatingBoard.RENCounter
      for j = 1, 20 do
        child_node.State.Data[j] = {}
        for m = 1, 10 do
          child_node.State.Data[j][m] = Generator.SimulatingBoard.Data[j + 20][m]
        end
      end
      Node.Link(node, child_node)
    end
    if node.State.Structure.TSpinDouble > 0 then
      for i = 1, #Generator.Paths['T']['TSD'] do
        local child_node = Node.New(false)
        for k = 1, #Generator.Paths['T']['TSD'][i] do table.insert(child_node.Path, Generator.Paths['T']['TSD'][i][k]) end -- Set path
        --child_node.Path = Generator.Paths['T']['TSD'][i] -- Set path
        child_node.State.CurrentPiece = node.State.NextPiece[1] -- Set current piece
        child_node.State.HoldPiece = node.State.HoldPiece -- Set hold piece
        for k = 2, #node.State.NextPiece do child_node.State.NextPiece[k - 1] = node.State.NextPiece[k] end -- Set nect piece queue
        -- Set data, line clear, line sent, ...
        Generator.SimulatingBoard.SetState(node)
        Generator.SimulatingBoard.MovePieceWithQueue(child_node.Path)
        child_node.State.WasTSpin = TetrisBoard.IsTSpin(Generator.SimulatingBoard)
        local line_clear_list = TetrisBoard.LineClearList(Generator.SimulatingBoard)
        child_node.State.LineCleared = #line_clear_list
        child_node.State.LineSent = TetrisBoard.CountGarbage(Generator.SimulatingBoard, line_clear_list, child_node.State.WasTSpin)
        child_node.State.IsB2bReady = Generator.SimulatingBoard.IsB2bReady
        child_node.State.RENCounter = Generator.SimulatingBoard.RENCounter
        for j = 1, 20 do
          child_node.State.Data[j] = {}
          for m = 1, 10 do
           child_node.State.Data[j][m] = Generator.SimulatingBoard.Data[j + 20][m]
          end
        end
        Node.Link(node, child_node)
      end
    end
    if node.State.Structure.STSD > 0 or node.State.Structure.TSTTSD > 0 then
      for i = 1, #Generator.Paths['T']['STSD'] do
        local child_node = Node.New(false)
        for k = 1, #Generator.Paths['T']['STSD'][i] do table.insert(child_node.Path, Generator.Paths['T']['STSD'][i][k]) end -- Set path
        --child_node.Path = Generator.Paths['T']['STSD'][i] -- Set path
        child_node.State.CurrentPiece = node.State.NextPiece[1] -- Set current piece
        child_node.State.HoldPiece = node.State.HoldPiece -- Set hold piece
        for k = 2, #node.State.NextPiece do child_node.State.NextPiece[k - 1] = node.State.NextPiece[k] end -- Set nect piece queue
        -- Set data, line clear, line sent, ...
        Generator.SimulatingBoard.SetState(node)
        Generator.SimulatingBoard.MovePieceWithQueue(child_node.Path)
        child_node.State.WasTSpin = TetrisBoard.IsTSpin(Generator.SimulatingBoard)
        local line_clear_list = TetrisBoard.LineClearList(Generator.SimulatingBoard)
        child_node.State.LineCleared = #line_clear_list
        child_node.State.LineSent = TetrisBoard.CountGarbage(Generator.SimulatingBoard, line_clear_list, child_node.State.WasTSpin)
        child_node.State.IsB2bReady = Generator.SimulatingBoard.IsB2bReady
        child_node.State.RENCounter = Generator.SimulatingBoard.RENCounter
        for j = 1, 20 do
          child_node.State.Data[j] = {}
          for m = 1, 10 do
           child_node.State.Data[j][m] = Generator.SimulatingBoard.Data[j + 20][m]
          end
        end
        Node.Link(node, child_node)
      end
    end
  end

  -- Hold and generate move for hold piece
  if node.State.HoldPiece == '0' then
    -- if #nextpiece >= 1
    if #node.State.NextPiece >= 1 then
      if node.State.NextPiece[1] ~= 'T' then
        for i = 1, #Generator.Paths[node.State.NextPiece[1]] do
          local child_node = Node.New(false)
          for k = 1, #Generator.Paths[node.State.NextPiece[1]][i] do table.insert(child_node.Path, Generator.Paths[node.State.NextPiece[1]][i][k]) end -- Set path
          --child_node.Path = Generator.Paths[node.State.NextPiece[1]][i] -- Set path
          table.insert(child_node.Path, 1, 'Hold') -- Add 'hold' to path
          child_node.State.CurrentPiece = node.State.NextPiece[2] -- Set current piece
          child_node.State.HoldPiece = node.State.CurrentPiece -- Set hold piece
          for k = 3, #node.State.NextPiece do child_node.State.NextPiece[k - 2] = node.State.NextPiece[k] end -- Set nect piece queue
          -- Set data, line clear, line sent, ...
          Generator.SimulatingBoard.SetState(node)
          TetrisBoard.CreateCurrentPiece(Generator.SimulatingBoard, node.State.NextPiece[1])
          Generator.SimulatingBoard.MovePieceWithQueue(child_node.Path)
          child_node.State.WasTSpin = TetrisBoard.IsTSpin(Generator.SimulatingBoard)
          local line_clear_list = TetrisBoard.LineClearList(Generator.SimulatingBoard)
          child_node.State.LineCleared = #line_clear_list
          child_node.State.LineSent = TetrisBoard.CountGarbage(Generator.SimulatingBoard, line_clear_list, child_node.State.WasTSpin)
          child_node.State.IsB2bReady = Generator.SimulatingBoard.IsB2bReady
          child_node.State.RENCounter = Generator.SimulatingBoard.RENCounter
          for j = 1, 20 do
            child_node.State.Data[j] = {}
            for m = 1, 10 do
              child_node.State.Data[j][m] = Generator.SimulatingBoard.Data[j + 20][m]
            end
          end
          Node.Link(node, child_node)
        end
      else
        for i = 1, #Generator.Paths['T']['Normal'] do
          local child_node = Node.New(false)
          for k = 1, #Generator.Paths['T']['Normal'][i] do table.insert(child_node.Path, Generator.Paths['T']['Normal'][i][k]) end -- Set path
          --child_node.Path = Generator.Paths['T']['Normal'][i] -- Set path
          table.insert(child_node.Path, 1, 'Hold') -- Add 'hold' to path
          child_node.State.CurrentPiece = node.State.NextPiece[2] -- Set current piece
          child_node.State.HoldPiece = node.State.CurrentPiece -- Set hold piece
          for k = 3, #node.State.NextPiece do child_node.State.NextPiece[k - 2] = node.State.NextPiece[k] end -- Set nect piece queue
          -- Set data, line clear, line sent, ...
          Generator.SimulatingBoard.SetState(node)
          TetrisBoard.CreateCurrentPiece(Generator.SimulatingBoard, node.State.NextPiece[1])
          Generator.SimulatingBoard.MovePieceWithQueue(child_node.Path)
          child_node.State.WasTSpin = TetrisBoard.IsTSpin(Generator.SimulatingBoard)
          local line_clear_list = TetrisBoard.LineClearList(Generator.SimulatingBoard)
          child_node.State.LineCleared = #line_clear_list
          child_node.State.LineSent = TetrisBoard.CountGarbage(Generator.SimulatingBoard, line_clear_list, child_node.State.WasTSpin)
          child_node.State.IsB2bReady = Generator.SimulatingBoard.IsB2bReady
          child_node.State.RENCounter = Generator.SimulatingBoard.RENCounter
          for j = 1, 20 do
            child_node.State.Data[j] = {}
            for m = 1, 10 do
             child_node.State.Data[j][m] = Generator.SimulatingBoard.Data[j + 20][m]
            end
          end
          Node.Link(node, child_node)
        end
        if node.State.Structure.TSpinDouble > 0 then
          for i = 1, #Generator.Paths['T']['TSD'] do
            local child_node = Node.New(false)
            for k = 1, #Generator.Paths['T']['TSD'][i] do table.insert(child_node.Path, Generator.Paths['T']['TSD'][i][k]) end -- Set path
            --child_node.Path = Generator.Paths['T']['TSD'][i] -- Set path
            table.insert(child_node.Path, 1, 'Hold') -- Add 'hold' to path
            child_node.State.CurrentPiece = node.State.NextPiece[2] -- Set current piece
            child_node.State.HoldPiece = node.State.CurrentPiece -- Set hold piece
            for k = 3, #node.State.NextPiece do child_node.State.NextPiece[k - 2] = node.State.NextPiece[k] end -- Set nect piece queue
            -- Set data, line clear, line sent, ...
            Generator.SimulatingBoard.SetState(node)
            TetrisBoard.CreateCurrentPiece(Generator.SimulatingBoard, node.State.NextPiece[1])
            Generator.SimulatingBoard.MovePieceWithQueue(child_node.Path)
            child_node.State.WasTSpin = TetrisBoard.IsTSpin(Generator.SimulatingBoard)
            local line_clear_list = TetrisBoard.LineClearList(Generator.SimulatingBoard)
            child_node.State.LineCleared = #line_clear_list
            child_node.State.LineSent = TetrisBoard.CountGarbage(Generator.SimulatingBoard, line_clear_list, child_node.State.WasTSpin)
            child_node.State.IsB2bReady = Generator.SimulatingBoard.IsB2bReady
            child_node.State.RENCounter = Generator.SimulatingBoard.RENCounter
            for j = 1, 20 do
              child_node.State.Data[j] = {}
              for m = 1, 10 do
               child_node.State.Data[j][m] = Generator.SimulatingBoard.Data[j + 20][m]
              end
            end
            Node.Link(node, child_node)
          end
        end
        if node.State.Structure.STSD > 0 or node.State.Structure.TSTTSD > 0 then
          for i = 1, #Generator.Paths['T']['STSD'] do
            local child_node = Node.New(false)
            for k = 1, #Generator.Paths['T']['STSD'][i] do table.insert(child_node.Path, Generator.Paths['T']['STSD'][i][k]) end -- Set path
            --child_node.Path = Generator.Paths['T']['STSD'][i] -- Set path
            table.insert(child_node.Path, 1, 'Hold') -- Add 'hold' to path
            child_node.State.CurrentPiece = node.State.NextPiece[2] -- Set current piece
            child_node.State.HoldPiece = node.State.CurrentPiece -- Set hold piece
            for k = 3, #node.State.NextPiece do child_node.State.NextPiece[k - 2] = node.State.NextPiece[k] end -- Set nect piece queue
            -- Set data, line clear, line sent, ...
            Generator.SimulatingBoard.SetState(node)
            TetrisBoard.CreateCurrentPiece(Generator.SimulatingBoard, node.State.NextPiece[1])
            Generator.SimulatingBoard.MovePieceWithQueue(child_node.Path)
            child_node.State.WasTSpin = TetrisBoard.IsTSpin(Generator.SimulatingBoard)
            local line_clear_list = TetrisBoard.LineClearList(Generator.SimulatingBoard)
            child_node.State.LineCleared = #line_clear_list
            child_node.State.LineSent = TetrisBoard.CountGarbage(Generator.SimulatingBoard, line_clear_list, child_node.State.WasTSpin)
            child_node.State.IsB2bReady = Generator.SimulatingBoard.IsB2bReady
            child_node.State.RENCounter = Generator.SimulatingBoard.RENCounter
            for j = 1, 20 do
              child_node.State.Data[j] = {}
              for m = 1, 10 do
               child_node.State.Data[j][m] = Generator.SimulatingBoard.Data[j + 20][m]
              end
            end
            Node.Link(node, child_node)
          end
        end
      end
    end
  else
    -- if nextpiece >= 0
    if node.State.HoldPiece ~= 'T' then
      for i = 1, #Generator.Paths[node.State.HoldPiece] do
        local child_node = Node.New(false)
        for k = 1, #Generator.Paths[node.State.HoldPiece][i] do table.insert(child_node.Path, Generator.Paths[node.State.HoldPiece][i][k]) end -- Set path
        --child_node.Path = Generator.Paths[node.State.HoldPiece][i] -- Set path
        table.insert(child_node.Path, 1, 'Hold') -- Add 'hold' to path
        child_node.State.CurrentPiece = node.State.NextPiece[1] -- Set current piece
        child_node.State.HoldPiece = node.State.CurrentPiece -- Set hold piece
        for k = 2, #node.State.NextPiece do child_node.State.NextPiece[k - 1] = node.State.NextPiece[k] end -- Set nect piece queue
        -- Set data, line clear, line sent, ...
        Generator.SimulatingBoard.SetState(node)
        TetrisBoard.CreateCurrentPiece(Generator.SimulatingBoard, node.State.HoldPiece)
        Generator.SimulatingBoard.MovePieceWithQueue(child_node.Path)
        child_node.State.WasTSpin = TetrisBoard.IsTSpin(Generator.SimulatingBoard)
        local line_clear_list = TetrisBoard.LineClearList(Generator.SimulatingBoard)
        child_node.State.LineCleared = #line_clear_list
        child_node.State.LineSent = TetrisBoard.CountGarbage(Generator.SimulatingBoard, line_clear_list, child_node.State.WasTSpin)
        child_node.State.IsB2bReady = Generator.SimulatingBoard.IsB2bReady
        child_node.State.RENCounter = Generator.SimulatingBoard.RENCounter
        for j = 1, 20 do
          child_node.State.Data[j] = {}
          for m = 1, 10 do
           child_node.State.Data[j][m] = Generator.SimulatingBoard.Data[j + 20][m]
          end
        end
        Node.Link(node, child_node)
      end
    else
      for i = 1, #Generator.Paths['T']['Normal'] do
        local child_node = Node.New(false)
        for k = 1, #Generator.Paths['T']['Normal'][i] do table.insert(child_node.Path, Generator.Paths['T']['Normal'][i][k]) end -- Set path
        --child_node.Path = Generator.Paths['T']['Normal'][i] -- Set path
        table.insert(child_node.Path, 1, 'Hold') -- Add 'hold' to path
        child_node.State.CurrentPiece = node.State.NextPiece[1] -- Set current piece
        child_node.State.HoldPiece = node.State.CurrentPiece -- Set hold piece
        for k = 2, #node.State.NextPiece do child_node.State.NextPiece[k - 1] = node.State.NextPiece[k] end -- Set nect piece queue
        -- Set data, line clear, line sent, ...
        Generator.SimulatingBoard.SetState(node)
        TetrisBoard.CreateCurrentPiece(Generator.SimulatingBoard, node.State.HoldPiece)
        Generator.SimulatingBoard.MovePieceWithQueue(child_node.Path)
        child_node.State.WasTSpin = TetrisBoard.IsTSpin(Generator.SimulatingBoard)
        local line_clear_list = TetrisBoard.LineClearList(Generator.SimulatingBoard)
        child_node.State.LineCleared = #line_clear_list
        child_node.State.LineSent = TetrisBoard.CountGarbage(Generator.SimulatingBoard, line_clear_list, child_node.State.WasTSpin)
        child_node.State.IsB2bReady = Generator.SimulatingBoard.IsB2bReady
        child_node.State.RENCounter = Generator.SimulatingBoard.RENCounter
        for j = 1, 20 do
          child_node.State.Data[j] = {}
          for m = 1, 10 do
           child_node.State.Data[j][m] = Generator.SimulatingBoard.Data[j + 20][m]
          end
        end
        Node.Link(node, child_node)
      end
      if node.State.Structure.TSpinDouble > 0 then
        for i = 1, #Generator.Paths['T']['TSD'] do
          local child_node = Node.New(false)
          for k = 1, #Generator.Paths['T']['TSD'][i] do table.insert(child_node.Path, Generator.Paths['T']['TSD'][i][k]) end -- Set path
          --child_node.Path = Generator.Paths['T']['TSD'][i] -- Set path
          table.insert(child_node.Path, 1, 'Hold') -- Add 'hold' to path
          child_node.State.CurrentPiece = node.State.NextPiece[1] -- Set current piece
          child_node.State.HoldPiece = node.State.CurrentPiece -- Set hold piece
          for k = 2, #node.State.NextPiece do child_node.State.NextPiece[k - 1] = node.State.NextPiece[k] end -- Set nect piece queue
          -- Set data, line clear, line sent, ...
          Generator.SimulatingBoard.SetState(node)
          TetrisBoard.CreateCurrentPiece(Generator.SimulatingBoard, node.State.HoldPiece)
          Generator.SimulatingBoard.MovePieceWithQueue(child_node.Path)
          child_node.State.WasTSpin = TetrisBoard.IsTSpin(Generator.SimulatingBoard)
          local line_clear_list = TetrisBoard.LineClearList(Generator.SimulatingBoard)
          child_node.State.LineCleared = #line_clear_list
          child_node.State.LineSent = TetrisBoard.CountGarbage(Generator.SimulatingBoard, line_clear_list, child_node.State.WasTSpin)
          child_node.State.IsB2bReady = Generator.SimulatingBoard.IsB2bReady
          child_node.State.RENCounter = Generator.SimulatingBoard.RENCounter
          for j = 1, 20 do
            child_node.State.Data[j] = {}
            for m = 1, 10 do
             child_node.State.Data[j][m] = Generator.SimulatingBoard.Data[j + 20][m]
            end
          end
          Node.Link(node, child_node)
        end
      end
      if node.State.Structure.STSD > 0 or node.State.Structure.TSTTSD > 0 then
        for i = 1, #Generator.Paths['T']['STSD'] do
          local child_node = Node.New(false)
          for k = 1, #Generator.Paths['T']['STSD'][i] do table.insert(child_node.Path, Generator.Paths['T']['STSD'][i][k]) end -- Set path
          --child_node.Path = Generator.Paths['T']['STSD'][i] -- Set path
          table.insert(child_node.Path, 1, 'Hold') -- Add 'hold' to path
          child_node.State.CurrentPiece = node.State.NextPiece[1] -- Set current piece
          child_node.State.HoldPiece = node.State.CurrentPiece -- Set hold piece
          for k = 2, #node.State.NextPiece do child_node.State.NextPiece[k - 1] = node.State.NextPiece[k] end -- Set nect piece queue
          -- Set data, line clear, line sent, ...
          Generator.SimulatingBoard.SetState(node)
          TetrisBoard.CreateCurrentPiece(Generator.SimulatingBoard, node.State.HoldPiece)
          Generator.SimulatingBoard.MovePieceWithQueue(child_node.Path)
          child_node.State.WasTSpin = TetrisBoard.IsTSpin(Generator.SimulatingBoard)
          local line_clear_list = TetrisBoard.LineClearList(Generator.SimulatingBoard)
          child_node.State.LineCleared = #line_clear_list
          child_node.State.LineSent = TetrisBoard.CountGarbage(Generator.SimulatingBoard, line_clear_list, child_node.State.WasTSpin)
          child_node.State.IsB2bReady = Generator.SimulatingBoard.IsB2bReady
          child_node.State.RENCounter = Generator.SimulatingBoard.RENCounter
          for j = 1, 20 do
            child_node.State.Data[j] = {}
            for m = 1, 10 do
             child_node.State.Data[j][m] = Generator.SimulatingBoard.Data[j + 20][m]
            end
          end
          Node.Link(node, child_node)
        end
      end
    end
  end
end

return Generator
