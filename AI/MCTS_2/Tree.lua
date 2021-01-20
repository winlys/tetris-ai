local Node = require "AI/MCTS_2/Node"

local Tree = {}

Tree.New = function(ai)
  local this = {}

  this.Root = Node.New(this) -- root node

  this.AI = ai

  this.EndNodes = {}

  this.Renew = function()
    -- change root node to the chosen child of root node
    --[[for i = 1, #this.EndNodes do
      this.EndNodes[i].Expandable = true
    end]]
    this.EndNodes = {}
    this.Root = this.Root.Children[this.Root.BestPathIndex]
    this.Root.Visit = 0
    this.Root.Revive()
  end

  return this
end

return Tree
