local Evaluator = require "AI/MCTS/Evaluator"
--Generator = Generator or require "AI/MCTS/Generator"

local Node = {}

Node.New = function(is_root)
  local this = {}

  this.IsRootNode = is_root

  this.Path = {}

  this.Parent = {}
  this.Children = {}

  this.Score = 0
  this.VisitCount = 0

  this.State = {
    Data = {},
    CurrentPiece = '',
    HoldPiece = '',
    NextPiece = {},

    IsB2bReady = false,
    RENCounter = 0,

    LineCleared = 0,
    LineSent = 0,
    WasTSpin = false,

    Structure = {
      TSpinDouble = 0,
      STSD = 0,
      TSTTSD = 0
    },
  }

  return this
end

Node.Evaluator = Evaluator.New()

-- Link parent and child
Node.Link = function(parent, child)
  child.Parent = parent
  table.insert(parent.Children, child)
end

-- UCB1
Node.CalculateUCB1 = function(node)
  -- Constant c
  local c = math.sqrt(2)

  -- Find visit count of root node
  local root_note = node
  while not root_note.IsRootNode do root_note = root_note.Parent end
  local N = root_note.VisitCount

  -- Calculate UCB1
  if node.VisitCount < 1 then
    return 10000000
  else
    return node.Score / node.VisitCount + c * math.sqrt(math.log(N) / node.VisitCount)
  end
end

-- Backpropagate
Node.Backpropagate = function(node)
  if not node.IsRootNode then
    node.Parent.Score = node.Parent.Score + node.Score
    node.Parent.VisitCount = node.Parent.VisitCount + 1
    Node.Backpropagate(node.Parent)
  end
end

--[[ Node expansion: Find all next move
Node.Expand = function(node)
  Generator.Generate(node)
end]]--

--[[Node rollout: instead of rollout, we evaluate the board state
Node.Rollout = function(node)
  node.Score = Node.Evaluator.Evaluate(node)
  node.VisitCount = node.VisitCount + 1
end]]--

-- Find the child with highest UCB1 score
Node.FindBestChild = function(node)
  local result = 1
  for i = 2, #node.Children do
    if node.Children[i].CurrentPiece ~= nil then
      if Node.CalculateUCB1(node.Children[i]) > Node.CalculateUCB1(node.Children[result]) then result = i end
    end
  end
  return node.Children[result]
end

-- Find the index of the child with highest UCB1 score
Node.FindBestChildIndex = function(node)
  local result = 1
  for i = 2, #node.Children do
    if node.Children[i].CurrentPiece ~= nil then
      if Node.CalculateUCB1(node.Children[i]) > Node.CalculateUCB1(node.Children[result]) then result = i end
    end
  end
  return result
end


return Node
