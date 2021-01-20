local TetrisBoard = require 'Game/TetrisBoard'

local Node = {}

Node.New = function(tree)
  local this = {}

  this.Tree = tree

  this.State = {
    Data = {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}},

    IsB2bReady = 0,
    RENCounter = 0,

    LineCleared = 0,
    LineSent = 0,
    WasTSpin = 0,

    Structure = {
      TSD = 0,
      STSD = 0,
      TSTTSD = 0,
    }
  }

  this.Path = {}
  this.BestPathIndex = 0

  this.Children = {}
  this.Parent = nil
  this.GenNo = 0 -- Generation number
  this.TreeEndNodeIndex = 0
  this.Expandable = true
  this.IsBeingChecked = false

  this.Score = 0
  this.Visit = 0

  -- add children
  this.AddChild = function(child)
    child.Parent = this
    table.insert(this.Children, child)
    child.GenNo = this.GenNo + 1
  end

  -- Calculate UCB1
  this.UCB1 = function()
    local C = math.sqrt(2)
    local N = this.Tree.Root.Visit
    if this.Visit == 0 then return nil else return this.Score / this.Visit + C * math.sqrt(math.log(N) / this.Visit) end
  end

  -- Backpropagate
  this.Backpropagate = function()
    if this ~= this.Tree.Root then
      this.Parent.Score = this.Parent.Score + this.Score
      this.Parent.Visit = this.Parent.Visit + 1
      this.Parent.Backpropagate()
    end
  end

  -- Find best child
  this.GetBestChild = function()
    for i = 1, #this.Children do
      if this.Children[i].Visit == 0 then return this.Children[i] end
    end
    local index = 1
    for i = 2, #this.Children do
      if this.Children[i].IsDead() == false and this.Children[i].IsBeingChecked == false and this.Children[i].UCB1() > this.Children[index].UCB1() then index = i end
    end
    return this.Children[index]
  end

  -- FInd out if the node can't be expand
  this.IsDead = function()
    if this.Expandable == false and this.Visit > 0 then return true end

    -- if every child is dead then dead
    if #this.Children > 0 then
      local sum = 0
      for i = 1, #this.Children do
        if this.Children[i].IsDead() then sum = sum + 1 end
      end
      if sum == #this.Children then
        this.Expandable = false
        return true
      else
        this.Expandable = true
      end
    end
    return false
  end

  -- Revive dead nodes
  this.Revive = function()
    this.Expandable = true
    if #this.Children > 0 then
      for i, k in pairs(this.Children) do
        k.Revive()
      end
    end
  end

  -- Find out if two node hade a same data
  this.IsSameDataAs = function(data)
    for i = 1, 20 do
      for k = 1, 10 do
        if this.State.Data[i][k] > 0 and data[i][k] < 1 then return false end
        if this.State.Data[i][k] < 1 and data[i][k] > 0 then return false end
      end
    end
    return true
  end

  -- Expand
  this.Expand = function(current_piece, hold_piece, next_piece)
    if current_piece == nil then return false end

    -- for current piece
    if current_piece ~= 'T' then

      for i = 1, #Node.Paths[current_piece] do
        local child_node = Node.New(this.Tree)
        for k = 1, #Node.Paths[current_piece][i] do table.insert(child_node.Path, Node.Paths[current_piece][i][k]) end
        if #next_piece == 0 then child_node.Dead = true end -- check if dead
        this.AddChild(child_node)
      end

    else

      for i = 1, #Node.Paths['T']['Default'] do
        local child_node = Node.New(this.Tree)
        for k = 1, #Node.Paths['T']['Default'][i] do table.insert(child_node.Path, Node.Paths['T']['Default'][i][k]) end
        if #next_piece == 0 then child_node.Dead = true end -- check if dead
        this.AddChild(child_node)
      end

      -- if there are TSD structure then try TSD
      if this.State.Structure.TSD > 0 then
        for i = 1, #Node.Paths['T']['TSD'] do
          local child_node = Node.New(this.Tree)
          for k = 1, #Node.Paths['T']['TSD'][i] do table.insert(child_node.Path, Node.Paths['T']['TSD'][i][k]) end
          if #next_piece == 0 then child_node.Dead = true end -- check if dead
          this.AddChild(child_node)
        end
      end

      -- if there are STSD/TSTTSD structure then try STSD/TSTTSD
      if this.State.Structure.STSD + this.State.Structure.TSTTSD > 0 then
        for i = 1, #Node.Paths['T']['STSD'] do
          local child_node = Node.New(this.Tree)
          for k = 1, #Node.Paths['T']['STSD'][i] do table.insert(child_node.Path, Node.Paths['T']['STSD'][i][k]) end
          if #next_piece == 0 then child_node.Dead = true end -- check if dead
          this.AddChild(child_node)
        end
      end

    end

    -- for hold piece
    if hold_piece == '0' then -- if there are no hold piece
      if #next_piece > 0 then
        if next_piece[1] ~= 'T' then

          for i = 1, #Node.Paths[next_piece[1]] do
            local child_node = Node.New(this.Tree)
            for k = 1, #Node.Paths[next_piece[1]][i] do table.insert(child_node.Path, Node.Paths[next_piece[1]][i][k]) end
            table.insert(child_node.Path, 1, 'Hold')
            if #next_piece == 1 then child_node.Dead = true end -- check if dead
            this.AddChild(child_node)
          end

        else

          for i = 1, #Node.Paths['T']['Default'] do
            local child_node = Node.New(this.Tree)
            for k = 1, #Node.Paths['T']['Default'][i] do table.insert(child_node.Path, Node.Paths['T']['Default'][i][k]) end
            table.insert(child_node.Path, 1, 'Hold')
            if #next_piece == 1 then child_node.Dead = true end -- check if dead
            this.AddChild(child_node)
          end

          -- if there are TSD structure then try TSD
          if this.State.Structure.TSD > 0 then
            for i = 1, #Node.Paths['T']['TSD'] do
              local child_node = Node.New(this.Tree)
              for k = 1, #Node.Paths['T']['TSD'][i] do table.insert(child_node.Path, Node.Paths['T']['TSD'][i][k]) end
              table.insert(child_node.Path, 1, 'Hold')
              if #next_piece == 1 then child_node.Dead = true end -- check if dead
              this.AddChild(child_node)
            end
          end

          -- if there are STSD/TSTTSD structure then try STSD/TSTTSD
          if this.State.Structure.STSD + this.State.Structure.TSTTSD > 0 then
            for i = 1, #Node.Paths['T']['STSD'] do
              local child_node = Node.New(this.Tree)
              for k = 1, #Node.Paths['T']['STSD'][i] do table.insert(child_node.Path, Node.Paths['T']['STSD'][i][k]) end
              table.insert(child_node.Path, 1, 'Hold')
              if #next_piece == 1 then child_node.Dead = true end -- check if dead
              this.AddChild(child_node)
            end
          end

        end
      end

    else

      if hold_piece ~= 'T' then

        for i = 1, #Node.Paths[hold_piece] do
          local child_node = Node.New(this.Tree)
          for k = 1, #Node.Paths[hold_piece][i] do table.insert(child_node.Path, Node.Paths[hold_piece][i][k]) end
          table.insert(child_node.Path, 1, 'Hold')
          if #next_piece == 0 then child_node.Dead = true end -- check if dead
          this.AddChild(child_node)
        end

      else

        for i = 1, #Node.Paths['T']['Default'] do
          local child_node = Node.New(this.Tree)
          for k = 1, #Node.Paths['T']['Default'][i] do table.insert(child_node.Path, Node.Paths['T']['Default'][i][k]) end
          table.insert(child_node.Path, 1, 'Hold')
          if #next_piece == 0 then child_node.Dead = true end -- check if dead
          this.AddChild(child_node)
        end

        -- if there are TSD structure then try TSD
        if this.State.Structure.TSD > 0 then
          for i = 1, #Node.Paths['T']['TSD'] do
            local child_node = Node.New(this.Tree)
            for k = 1, #Node.Paths['T']['TSD'][i] do table.insert(child_node.Path, Node.Paths['T']['TSD'][i][k]) end
            table.insert(child_node.Path, 1, 'Hold')
            if #next_piece == 0 then child_node.Dead = true end -- check if dead
            this.AddChild(child_node)
          end
        end

        -- if there are STSD/TSTTSD structure then try STSD/TSTTSD
        if this.State.Structure.STSD + this.State.Structure.TSTTSD > 0 then
          for i = 1, #Node.Paths['T']['STSD'] do
            local child_node = Node.New(this.Tree)
            for k = 1, #Node.Paths['T']['STSD'][i] do table.insert(child_node.Path, Node.Paths['T']['STSD'][i][k]) end
            table.insert(child_node.Path, 1, 'Hold')
            if #next_piece == 0 then child_node.Dead = true end -- check if dead
            this.AddChild(child_node)
          end
        end

      end

    end

    return true
  end

  return this
end

Node.Paths = {
  ['O'] = {},
  ['I'] = {},
  ['J'] = {},
  ['L'] = {},
  ['S'] = {},
  ['Z'] = {},
  ['T'] = {
    ['Default'] = {},
    ['TSD'] = {},
    ['STSD'] = {},
  }
}

Node.Paths['O'] = {
  { 'L', 'L', 'L', 'HD' },
  { 'L', 'L', 'HD' },
  { 'L', 'HD' },
  { 'HD' },
  { 'R', 'HD' },
  { 'R', 'R', 'HD' },
  { 'R', 'R', 'R', 'HD' },
  { 'R', 'R', 'R', 'R', 'HD' },
  { 'R', 'R', 'R', 'R', 'R', 'HD' },
}
Node.Paths['I'] = {
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
}
Node.Paths['J'] = {
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
}
Node.Paths['L'] = Node.Paths['J']
Node.Paths['S'] = {
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
}
Node.Paths['Z'] = Node.Paths['S']
Node.Paths['T']['Default'] = Node.Paths['J']
Node.Paths['T']['TSD'] = {
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
}
Node.Paths['T']['STSD'] = {
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
}


return Node
