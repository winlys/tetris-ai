local Node = require "AI/MCTS_2/Node"
local Evaluator = require "AI/MCTS_2/Evaluator"
local Tree = require "AI/MCTS_2/Tree"
local TetrisBoard = require "Game/TetrisBoard"

local AI = {}

AI.New = function()
  local this = {}

  this.Evaluator = Evaluator.New()
  this.Tree = Tree.New(this)

  -- parameter
  this.Depth = 5
  this.MaxNode = 1600
  this.ExpandRate = 0

  this.Board = TetrisBoard.New()

  this.SetBoardState = function(board_data, current_piece, hold_piece, next_piece, is_b2b_ready, ren_counter, garbage)
    this.Board = TetrisBoard.New() -- renew board

    -- set data
    --this.Board.Data = {}
    --for i = 1, 40 do this.Board.Data[i] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } end
    for i = 1, 20 do
      for k = 1, 10 do
        this.Board.Data[i + 20][k] = board_data[i][k]
      end
    end

    -- set current piece
    TetrisBoard.CreateCurrentPiece(this.Board, current_piece)

    -- set hold piece
    this.Board.HoldPieceID = hold_piece

    -- set next piece queue
    for i = 1, #next_piece do this.Board.NextPiece[i] = next_piece[i] end

    -- set b2b and ren and garbage
    this.Board.IsB2bReady = is_b2b_ready
    this.Board.RENCounter = ren_counter
    this.Board.GarbageCounter = garbage
  end

  this.BoardAttemp = function(queue)
    for i = 1, #queue do
      if queue[i] == 'L' then this.Board.CurrentPiece.TryMoveLeft()
      elseif queue[i] == 'R' then this.Board.CurrentPiece.TryMoveRight()
      elseif queue[i] == 'HD' then this.Board.CurrentPiece.HardDrop()
      elseif queue[i] == 'SD' then this.Board.CurrentPiece.HardDrop()
      elseif queue[i] == 'RR' then this.Board.CurrentPiece.Rotate(1)
      elseif queue[i] == 'RL' then this.Board.CurrentPiece.Rotate(3)
      elseif queue[i] == 'Hold' then
        if this.Board.HoldPieceID == '0' then
          this.Board.HoldPieceID = this.Board.CurrentPiece.ID
          TetrisBoard.CreateCurrentPiece(this.Board, this.Board.NextPiece[1])
          table.remove(this.Board.NextPiece, 1)
        else
          local place_holder = this.Board.HoldPieceID
          this.Board.HoldPieceID = this.Board.CurrentPiece.ID
          TetrisBoard.CreateCurrentPiece(this.Board, place_holder)
          --table.remove(this.Board.NextPiece, 1)
        end
      end
    end

    local is_t_spin = TetrisBoard.IsTSpin(this.Board)
    TetrisBoard.PlacePiece(this.Board)
    local line_clear_list = TetrisBoard.LineClearList(this.Board)
    local count_garbage = TetrisBoard.CountGarbage(this.Board, line_clear_list, is_t_spin)
    local b2b = this.Board.IsB2bReady
    local ren = this.Board.RENCounter

    TetrisBoard.CreateCurrentPiece(this.Board, this.Board.NextPiece[1])
    table.remove(this.Board.NextPiece, 1)

    -- clear line
    TetrisBoard.ClearLine(this.Board, line_clear_list)

    -- Place garbage
    if #line_clear_list < 1 then
      --TetrisBoard.PlaceGarbage(this.Board)
      for i = 1, this.Board.GarbageCounter do
        table.remove(this.Board.Data, 1)
        table.insert(this.Board.Data, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1})
      end
      this.Board.GarbageCounter = 0
    else
      if this.Board.GarbageCounter > count_garbage then
        this.Board.GarbageCounter = this.Board.GarbageCounter - count_garbage
      else
        this.Board.GarbageCounter = 0
      end
    end

    local data = TetrisBoard.NormalizeBoard(this.Board)

    return {data, is_t_spin, #line_clear_list, count_garbage, b2b, ren}
  end

  this.SetParameter = function(depth, max_node)
    this.Depth = depth
    this.MaxNode = max_node
  end

  -- find move
  this.FindMove = function(board_data, current_piece, hold_piece, next_piece, is_b2b_ready, ren_counter, garbage)
    this.SetBoardState(board_data, current_piece, hold_piece, next_piece, is_b2b_ready, ren_counter, garbage)
    --this.Tree = Tree.New(this)
    --this.Tree.Root.Children = {}

    if #this.Tree.Root.Children == 0 then
      this.Tree.Root.Expand(current_piece, hold_piece, next_piece)
    else
      if this.Tree.Root.Children[this.Tree.Root.BestPathIndex].IsSameDataAs(board_data) then
        this.Tree.Renew()
      else
        this.Tree = Tree.New(this)
        this.Tree.Root.Expand(current_piece, hold_piece, next_piece)
      end
    end

    --[[ MCTS
    while this.Tree.Root.Visit <= this.MaxNode do
      this.SetBoardState(board_data, current_piece, hold_piece, next_piece, is_b2b_ready, ren_counter)

      local leaf_node = this.Tree.Root

      -- find leaf node
      --local count = 0
      --local state = nil
      while #leaf_node.Children > 0 do
        --count = count + 1
        leaf_node = leaf_node.GetBestChild()
        local state = this.BoardAttemp(leaf_node.Path)
        for i = 1, 20 do
          for k = 1, 10 do
            leaf_node.State.Data[i][k] = state[1][i][k]
          end
        end
        leaf_node.State.WasTSpin = state[2]
        leaf_node.State.LineCleared = state[3]
        leaf_node.State.LineSent = state[4]
        leaf_node.State.IsB2bReady = state[5]
        leaf_node.State.RENCounter = state[6]
      end

      if leaf_node.Visit == 0 then
        leaf_node.Score = this.Evaluator.Evaluate(leaf_node)
        leaf_node.Visit = 1
      else
        local expanded = leaf_node.Expand(this.Board.CurrentPiece.ID, this.Board.HoldPieceID, this.Board.NextPiece)
        if expanded then
          leaf_node = leaf_node.GetBestChild()
          local state = this.BoardAttemp(leaf_node.Path)
          for i = 1, 20 do
            for k = 1, 10 do
              leaf_node.State.Data[i][k] = state[1][i][k]
            end
          end
          leaf_node.State.WasTSpin = state[2]
          leaf_node.State.LineCleared = state[3]
          leaf_node.State.LineSent = state[4]
          leaf_node.State.IsB2bReady = state[5]
          leaf_node.State.RENCounter = state[6]
          leaf_node.Score = this.Evaluator.Evaluate(leaf_node)
          leaf_node.Visit = 1
        else
          leaf_node.Visit = leaf_node.Visit + 1
        end
      end

      leaf_node.Backpropagate()
    end--]]

    --[[ 1 depth search
    for i = 1, #this.Tree.Root.Children do
      this.SetBoardState(board_data, current_piece, hold_piece, next_piece, is_b2b_ready, ren_counter)
      local state = this.BoardAttemp(this.Tree.Root.Children[i].Path)
      this.Tree.Root.Children[i].State.Data = state[1]
      this.Tree.Root.Children[i].State.WasTSpin = state[2]
      this.Tree.Root.Children[i].State.LineCleared = state[3]
      this.Tree.Root.Children[i].State.LineSent = state[4]
      this.Tree.Root.Children[i].State.IsB2bReady = state[5]
      this.Tree.Root.Children[i].State.RENCounter = state[6]
      this.Tree.Root.Children[i].Visit = 1

      this.Tree.Root.Children[i].Score = this.Evaluator.Evaluate(this.Tree.Root.Children[i])
      --print(this.Tree.Root.Children[i].Score)
    end--]]

    -- MCTS 2
    while this.Tree.Root.Visit <= this.MaxNode do
      this.SetBoardState(board_data, current_piece, hold_piece, next_piece, is_b2b_ready, ren_counter, garbage) -- reset board to root state

      -- Reset locked for multithread
      for i = 1, #this.Tree.Root.Children do
        this.Tree.Root.Children[i].IsBeingChecked = false
      end

      -- Selection (find leaf node)
      local leaf_node = this.Tree.Root
      while #leaf_node.Children ~= 0 do
        leaf_node = leaf_node.GetBestChild()
        local state = this.BoardAttemp(leaf_node.Path)
        for i = 1, 20 do
          for k = 1, 10 do
            leaf_node.State.Data[i][k] = state[1][i][k]
          end
        end
        leaf_node.State.WasTSpin = state[2]
        leaf_node.State.LineCleared = state[3]
        leaf_node.State.LineSent = state[4]
        leaf_node.State.IsB2bReady = state[5]
        leaf_node.State.RENCounter = state[6]
      end

      -- Expansion
      if leaf_node.Visit == 0 then -- If leaf node hadn't be evaluate then evaluate
        leaf_node.Score = this.Evaluator.Evaluate(leaf_node) -- Rollout :)
        leaf_node.Visit = 1
        table.insert(this.Tree.EndNodes, leaf_node)
        leaf_node.TreeEndNodeIndex = #this.Tree.EndNodes
      else
        table.remove(this.Tree.EndNodes, leaf_node.TreeEndNodeIndex)
        leaf_node.Expand(this.Board.CurrentPiece.ID, this.Board.HoldPieceID, this.Board.NextPiece)
        leaf_node = leaf_node.GetBestChild()
        local state = this.BoardAttemp(leaf_node.Path)
        for i = 1, 20 do
          for k = 1, 10 do
            leaf_node.State.Data[i][k] = state[1][i][k]
          end
        end
        leaf_node.State.WasTSpin = state[2]
        leaf_node.State.LineCleared = state[3]
        leaf_node.State.LineSent = state[4]
        leaf_node.State.IsB2bReady = state[5]
        leaf_node.State.RENCounter = state[6]
        leaf_node.Score = this.Evaluator.Evaluate(leaf_node) -- Rollout :)
        leaf_node.Visit = 1
        table.insert(this.Tree.EndNodes, leaf_node)
        leaf_node.TreeEndNodeIndex = #this.Tree.EndNodes
      end

      -- Backpropagate
      leaf_node.Backpropagate()
    end--]]


    -- find best action
    --[[ will change later to find the action lead to the best state instead of action with best average score
    local best_node = this.Tree.Root.Children[1]
    for i = 2, #this.Tree.Root.Children do
      if this.Tree.Root.Children[i].Visit > 0 and this.Tree.Root.Children[i].Score / this.Tree.Root.Children[i].Visit > best_node.Score / best_node.Visit then
        best_node = this.Tree.Root.Children[i]
      end
    end--]]

    local best_node = this.Tree.EndNodes[1]
    for i = 2, #this.Tree.EndNodes do
      if this.Tree.EndNodes[i].Score > best_node.Score then
        best_node = this.Tree.EndNodes[i]
      end
    end--]]

    while best_node.Parent ~= this.Tree.Root do
      best_node = best_node.Parent
    end

    for i = 1, #this.Tree.Root.Children do
      if best_node == this.Tree.Root.Children[i] then this.Tree.Root.BestPathIndex = i end
    end

    --print(best_node.Score)
    return best_node.Path
  end

  --[[ update
  this.Update = function(dt, board)
    if board.IsReadyToAI then
      board.IsReadyToAI = false
      this.Queue = {}
      this.Queue = this.FindMove(TetrisBoard.NormalizeBoard(board), board.CurrentPiece.ID, board.HoldPieceID, board.NextPiece, board.IsB2bReady, board.RENCounter, board.GarbageCounter)
    end
  end--]]

  return this
end

return AI
