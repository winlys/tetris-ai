local Node = require "AI/MCTS_2/Node"

local Evaluator = {}

Evaluator.New = function()
  local this = {}

  this.Weights = {
    Bumpiness = -17,
    SpeBumpiness = -2,
    Hole = -42,
    Fullness = 0,
    BlockAboveHole = -4,
    SpeBlockAboveHole = -1,
    AverageHeight = -15,
    ExpAverageHeight = -2,
    HeightCollumn = { -1, -1.1, -1, -2.2, -2.3, -2.2, -2.5, -1.3, -1, -1.1},
    Structure = {
      TSpinDouble = 0,
      STSD = 0,
      TSTTSD = 0
    },
    LineSent = 0,
    BackToBack = 5.2,
    Ren = 0,
    PerfectClear = 999,
    Tetris = 999,
    TSpinSingle = 40.1,
    TSpinDouble = 160,
    TSpinTriple = 300.2,
    Burn1 = 100,
    Burn2 = 200,
    Burn3 = 300,
    WasteStructure = -1,
  }

  -- Evaluate the board
  this.Evaluate = function(node)
    local result = 0

    --[[ game over
    if node.State.Data[1][4] + node.State.Data[1][5] + node.State.Data[1][6] + node.State.Data[1][6] > 0 then
      return -999999
    end]]

    -- line sent
    result = result + node.State.LineSent * this.Weights.LineSent

    -- back to back
    if node.State.IsB2bReady and node.Parent.State.IsB2bReady then result = result + this.Weights.BackToBack end

    -- ren
    result = result + node.State.RENCounter * this.Weights.Ren

    -- perfect clear
    if (node.State.Data[20][1] + node.State.Data[20][2] + node.State.Data[20][3] + node.State.Data[20][4] + node.State.Data[20][5] +
      node.State.Data[20][6] + node.State.Data[20][7] + node.State.Data[20][8] + node.State.Data[20][9] + node.State.Data[20][10]) == 0 then
      result = result + this.Weights.PerfectClear
    end

    --[[ line clear
    result = result + Evaluator.Function.SpecialLineClear(node.State.LineCleared) * this.Weights.SpeLineClear--]]

    -- t spin
    if node.State.WasTSpin then
      if node.State.LineCleared == 1 then result = result + this.Weights.TSpinSingle
      elseif node.State.LineCleared == 2 then result = result + this.Weights.TSpinDouble
      elseif node.State.LineCleared == 3 then result = result + this.Weights.TSpinTriple end
    else
      if node.State.LineCleared == 1 then result = result + this.Weights.Burn1
      elseif node.State.LineCleared == 2 then result = result + this.Weights.Burn2
      elseif node.State.LineCleared == 3 then result = result + this.Weights.Burn3
      elseif node.State.LineCleared == 4 then result = result + this.Weights.Tetris
      end
    end

    -- collumns' height
    local collumn_height = Evaluator.Function.GetCollumnHeight(node.State.Data)
    for i = 1, 10 do
      result = result + collumn_height[i] * this.Weights.HeightCollumn[i]
    end

    -- average height and special average height
    local sum_collumn = 0
    for i = 1, 10 do
      sum_collumn = sum_collumn + collumn_height[i]
    end
    result = result + sum_collumn / 10 * this.Weights.AverageHeight
    result = result + math.exp(math.min(sum_collumn / 10 - 15, 0)) * this.Weights.ExpAverageHeight

    -- hole
    local hole = Evaluator.Function.GetHole(node.State.Data, collumn_height)
    result = result + hole * this.Weights.Hole

    -- bumpiness
    local bumpiness = Evaluator.Function.GetBumpiness(collumn_height)
    result = result + bumpiness[1] * this.Weights.Bumpiness
    result = result + bumpiness[2] * this.Weights.SpeBumpiness

    -- block above hole
    local block_above_hole = Evaluator.Function.GetBlockAboveHole(node.State.Data, collumn_height)
    result = result + block_above_hole[1] * this.Weights.BlockAboveHole
    result = result + block_above_hole[2] * this.Weights.SpeBlockAboveHole

    -- structure
    local structure = Evaluator.Function.GetStructure(node.State.Data, collumn_height)
    node.State.Structure.TSD = structure[1]
    node.State.Structure.STSD = structure[2]
    node.State.Structure.TSTTSD = structure[3]
    result = result + structure[1] * this.Weights.Structure.TSpinDouble
    result = result + structure[2] * this.Weights.Structure.STSD
    result = result + structure[3] * this.Weights.Structure.TSTTSD

    -- waste structure
    local waste_structure = 0
    if node.State.WasTSpin and node.State.LineCleared > 0 then
      waste_structure = 0
    else
      waste_structure = math.max(0, (node.Parent.State.Structure.TSD + node.Parent.State.Structure.STSD + node.Parent.State.Structure.TSTTSD) - (node.State.Structure.TSD + node.State.Structure.STSD + node.State.Structure.TSTTSD))
    end
    result = result + waste_structure * this.Weights.WasteStructure

    -- fullness of the board
    result = result + Evaluator.Function.GetFullness(hole, collumn_height) * this.Weights.Fullness


    return result
    --return Evaluator.Function.GetHole(node.State.Data ,collumn_height) * this.Weights.Hole + node.State.LineCleared * 5 + Evaluator.Function.GetFullness(Evaluator.Function.GetHole(node.State.Data ,collumn_height), collumn_height) * this.Weights.Fullness
    --return -1 * Evaluator.Function.GetHole(node.State.Data ,collumn_height)
  end

  return this
end

Evaluator.Function = {
  SpecialLineClear = function(line_cleared)
    if line_cleared == 0 then
      return 0
    else
      return math.exp(line_cleared - 2) - 4
    end
  end,

  --[[GetCollumnHeight = function(node)
    local result = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

    for i = 1, 10 do
      local y_test = 0
      while y_test < 20 and node.State.Data[y_test + 1][i] do
        y_test = y_test + 1
      end
      result[i] = 20 - y_test
    end

    return result
  end,]]

  GetCollumnHeight = function(board_data)
    local result = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

    for i = 1, 10 do
      local y_test = 0
      while y_test < 20 and board_data[y_test + 1][i] == 0 do
        y_test = y_test + 1
      end
      result[i] = 20 - y_test
    end

    return result
  end,

  GetBumpiness = function(collumn_height)
    local result = {0, 0} -- 1st value: normal Bumpiness    2nd value: sum of square bumpiness

    for i = 1, 9 do
      result[1] = result[1] + math.abs(collumn_height[i] - collumn_height[i + 1])
      result[2] = result[2] + ((collumn_height[i] - collumn_height[i + 1]) * (collumn_height[i] - collumn_height[i + 1]))
    end

    return result
  end,

  GetHole = function(board_data, collumn_height)
    local result = 0

    for i = 1, 10 do
      for k = 22 - collumn_height[i], 20 do
        if board_data[k][i] == 0 then
          result = result + 1
        end
      end
    end

    return result
  end,

  GetFullness = function(hole, collumn_height)
    local sum = 0
    for i = 1, 10 do sum = sum + collumn_height[i] end
    return 1 - (hole / sum)
  end,

  GetBlockAboveHole = function(board_data, collumn_height)
    local result = {0, 0}

    for i = 1, 10 do
      local count = 0
      local detected_hole = false
      for k = 21 - collumn_height[i], 19 do
        if not detected_hole then count = count + 1 end
        if board_data[k][i] > 0 and board_data[k + 1][i] == 0 then detected_hole = true end
      end
      if detected_hole then
        result[1] = result[1] + count
        result[2] = result[2] + count * count
      end
    end

    return result
  end,

  GetStructure = function(board_data, collumn_height)
    local result = {0, 0, 0} --1: TSD     2: STSD     3: TSTTSD

    local highest_height = 0
    for i = 1, 10 do highest_height = math.max(highest_height, collumn_height[i]) end
    --return highest_height

    -- TSD
    for k = 21 - highest_height, 18 do
      for i = 1, 8 do
        if board_data[k][i] > 0 and board_data[k][i + 1] == 0 and board_data[k][i + 2] == 0
        and board_data[k + 1][i] == 0 and board_data[k + 1][i + 1] == 0 and board_data[k + 1][i + 2] == 0
        and board_data[k + 2][i] > 0 and board_data[k + 2][i + 1] == 0 and board_data[k + 2][i + 2] > 0 then
          if collumn_height[i + 1] < 20 - k and collumn_height[i + 2] < 20 - k then
            result[1] = result[1] + 1
          end
        end
        if board_data[k][i] == 0 and board_data[k][i + 1] == 0 and board_data[k][i + 2] > 0
        and board_data[k + 1][i] == 0 and board_data[k + 1][i + 1] == 0 and board_data[k + 1][i + 2] == 0
        and board_data[k + 2][i] > 0 and board_data[k + 2][i + 1] == 0 and board_data[k + 2][i + 2] > 0 then
          if collumn_height[i] < 20 - k and collumn_height[i + 1] < 20 - k then
            result[1] = result[1] + 1
          end
        end
      end
    end

    -- STSD
    for k = 21 - highest_height, 16 do
      for i = 1, 7 do
        if board_data[k][i] == 0 and board_data[k][i + 1] == 0 and board_data[k][i + 2] > 0
        and board_data[k + 1][i] == 0 and board_data[k + 1][i + 1] == 0 and board_data[k + 1][i + 2] == 0 and board_data[k + 1][i + 3] > 0
        and board_data[k + 2][i] > 0 and board_data[k + 2][i + 1] > 0 and board_data[k + 2][i + 2] == 0 and board_data[k + 2][i + 3] > 0
        and board_data[k + 3][i] > 0 and board_data[k + 3][i + 1] == 0 and board_data[k + 3][i + 2] == 0 and board_data[k + 3][i + 3] > 0
        and board_data[k + 4][i] > 0 and board_data[k + 4][i + 1] == 0 and board_data[k + 4][i + 2] == 0 and board_data[k + 4][i + 3] > 0 then
          if collumn_height[i] < 20 - k and collumn_height[i + 1] < 20 - k then
            result[2] = result[2] + 1
          end
        end
        if board_data[k][i + 1] > 0 and board_data[k][i + 2] == 0 and board_data[k][i + 3] == 0
        and board_data[k + 1][i] > 0 and board_data[k + 1][i + 1] == 0 and board_data[k + 1][i + 2] == 0 and board_data[k + 1][i + 3] == 0
        and board_data[k + 2][i] > 0 and board_data[k + 2][i + 1] == 0 and board_data[k + 2][i + 2] > 0 and board_data[k + 2][i + 3] > 0
        and board_data[k + 3][i] > 0 and board_data[k + 3][i + 1] == 0 and board_data[k + 3][i + 2] == 0 and board_data[k + 3][i + 3] > 0
        and board_data[k + 4][i] > 0 and board_data[k + 4][i + 1] == 0 and board_data[k + 4][i + 2] == 0 and board_data[k + 4][i + 3] > 0 then
          if collumn_height[i + 2] < 20 - k and collumn_height[i + 3] < 20 - k then
            result[2] = result[2] + 1
          end
        end
      end
    end

    -- TSTTSD
    for k = 21 - highest_height, 15 do
      for i = 1, 7 do
        if board_data[k][i + 1] > 0 and board_data[k][i + 2] == 0 and board_data[k][i + 3] == 0
        and board_data[k + 1][i + 1] == 0 and board_data[k + 1][i + 2] == 0 and board_data[k + 1][i + 3] == 0
        and board_data[k + 2][i] > 0 and board_data[k + 2][i + 1] == 0 and board_data[k + 2][i + 2] > 0 and board_data[k + 2][i + 3] > 0
        and board_data[k + 3][i] > 0 and board_data[k + 3][i + 1] == 0 and board_data[k + 3][i + 2] == 0 and board_data[k + 3][i + 3] > 0
        and board_data[k + 4][i] > 0 and board_data[k + 4][i + 1] == 0 and board_data[k + 4][i + 2] > 0 and board_data[k + 4][i + 3] > 0
        and board_data[k + 5][i + 1] > 0 and board_data[k + 5][i + 2] == 0 and board_data[k + 5][i + 3] > 0 then
          if collumn_height[i + 2] < 20 - k and collumn_height[i + 3] < 20 - k then
            result[3] = result[3] + 1
          end
        end
        if board_data[k][i] == 0 and board_data[k][i + 1] == 0 and board_data[k][i + 2] > 0
        and board_data[k + 1][i] == 0 and board_data[k + 1][i + 1] == 0 and board_data[k + 1][i + 2] == 0
        and board_data[k + 2][i] > 0 and board_data[k + 2][i + 1] > 0 and board_data[k + 2][i + 2] == 0 and board_data[k + 2][i + 3] > 0
        and board_data[k + 3][i] > 0 and board_data[k + 3][i + 1] == 0 and board_data[k + 3][i + 2] == 0 and board_data[k + 3][i + 3] > 0
        and board_data[k + 4][i] > 0 and board_data[k + 4][i + 1] > 0 and board_data[k + 4][i + 2] == 0 and board_data[k + 4][i + 3] > 0
        and board_data[k + 5][i] > 0 and board_data[k + 5][i + 1] == 0 and board_data[k + 5][i + 2] > 0 then
          if collumn_height[i] < 20 - k and collumn_height[i + 1] < 20 - k then
            result[3] = result[3] + 1
          end
        end
      end
    end

    return result--]]
  end,
}

return Evaluator
