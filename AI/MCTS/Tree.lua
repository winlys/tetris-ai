local Evaluator = require "AI/MCTS/Evaluator"
local Generator = require "AI/MCTS/Generator"
local Node = require "AI/MCTS/Node"

local Tree = {}

Tree.New = function(ai)
  local this = {}

  this.AI = ai

  this.Root = Node.New(true)

  -- Evaluate a node
  this.Evaluate = function(node)
    node.Score = this.AI.Evaluator.Evaluate(node)
    node.VisitCount = node.VisitCount + 1
  end

  return this
end

return Tree
