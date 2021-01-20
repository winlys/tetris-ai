local Evaluator = require "AI/MCTS/Evaluator"
local Generator = require "AI/MCTS/Generator"
local Tree = require "AI/MCTS/Tree"
local Node = require "AI/MCTS/Node"

local AI = {}

AI.New = function()
  local this = {}

  this.Evaluator = Evaluator.New()
  this.Tree = Tree.New(this)

  -- parameter
  this.Depth = 0
  this.MaxNode = 0

  this.SetParameter = function(depth, max_node)
    this.Depth = depth
    this.MaxNode = max_node
  end

  this.FindMove = function(board_data, current_piece, hold_piece, next_piece, is_b2b_ready, ren_counter)
    this.Tree.Root = Node.New(true)
    this.Tree.Root.State.Data = board_data
    this.Tree.Root.State.CurrentPiece = current_piece
    this.Tree.Root.State.HoldPiece = hold_piece
    this.Tree.Root.State.NextPiece = next_piece
    this.Tree.Root.State.IsB2bReady = is_b2b_ready
    this.Tree.Root.State.RENCounter = ren_counter
    local structure = Evaluator.Function.GetStructure(board_data, Evaluator.Function.GetCollumnHeight(this.Tree.Root))
    this.Tree.Root.State.Structure.TSpinDouble = structure[1]
    this.Tree.Root.State.Structure.STSD = structure[2]
    this.Tree.Root.State.Structure.TSTTSD = structure[3]

    -- Expand root node
    Generator.Generate(this.Tree.Root)

    --return #this.Tree.Root.Children

    --[[ MCTS
    while this.Tree.Root.VisitCount <= this.MaxNode do
      local leaf_node = this.Tree.Root.Children[Node.FindBestChildIndex(this.Tree.Root)]
      while #leaf_node.Children > 0 do
        leaf_node = Node.FindBestChild(leaf_node)
      end
      if leaf_node.VisitCount == 0 then
        this.Tree.Evaluate(leaf_node)
      else
        Generator.Generate(leaf_node)
        if #leaf_node.Children > 0 then
          leaf_node = Node.FindBestChild(leaf_node)
          this.Tree.Evaluate(leaf_node)
        else
          leaf_node.VisitCount = leaf_node.VisitCount + 1
        end
      end
      Node.Backpropagate(leaf_node)
    end

    -- Find best action
    -- Will change later to find the node with the best child instead of node with the best score
    local best_node = this.Tree.Root.Children[1]
    for i = 2, #this.Tree.Root.Children do
      if this.Tree.Root.Children[i].VisitCount > 0 and this.Tree.Root.Children[i].Score / this.Tree.Root.Children[i].VisitCount > best_node.Score / best_node.VisitCount then
        best_node = this.Tree.Root.Children[i]
      end
    end
    return best_node.Path--]]--
    for i = 1, #this.Tree.Root.Children do
      this.Tree.Root.Children[i].Score = this.Evaluator.Evaluate(this.Tree.Root.Children[i])
      --print(this.Tree.Root.Children[i].State.Data[20][1])
      print(this.Tree.Root.Children[i].Score)
    end
    --if this.Tree.Root.Children[1].State.Data[2] == this.Tree.Root.Children[2].State.Data[2] then print('yes') end
    local best_node = this.Tree.Root.Children[1]
    for i = 2, #this.Tree.Root.Children do
      if this.Tree.Root.Children[i].Score > best_node.Score then
        best_node = this.Tree.Root.Children[i]
      end
    end
    return best_node.Path

  end

  return this
end

return AI
