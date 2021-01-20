local TetrisBoard = require 'Game/TetrisBoard'

local Evaluator = {}

Evaluator.New = function()
  local this = {}

  this.Weights = {
    Bumpiness = -2.4,
    SpeBumpiness = -1.7,
    Hole = -3.4,
    BlockAboveHole = -1.7,
    SpeBlockAboveHole = -1,
    AverageHeight = -3.9,
    ExpAverageHeight = -1,
    HeightCollumn = { -1, -1.2, -1, -2, -3, -2, -2.8, -1, -0.9, -1.2},
    Structure = {
      TSpinDouble = 14,
      STSD = 28,
      TSTTSD = 28
    },
    LineSent = 2.3,
    BackToBack = 5.2,
    Ren = 2,
    PerfectClear = 100,
    TSpinSingle = 12.1,
    TSpinDouble = 41,
    TSpinTriple = 60.2,
    SpeLineClear = 10,
    WasteStructure = -15.2,
  }

  -- Evaluate the board
  this.Evaluate = function(node)
    local score = 0

    -- line sent
    score = score + node.State.LineSent * this.Weights.LineSent

    -- back to back
    local was_b2b = 0
    if node.State.IsB2bReady and node.Parent.State.IsB2bReady then was_b2b = 1 end
    score = score + was_b2b * this.Weights.BackToBack--]]

    -- ren
    score = score + node.State.RENCounter * this.Weights.Ren

    -- perfect clear
    local perfect_clear = 0
    if (node.State.Data[20][1] + node.State.Data[20][2] + node.State.Data[20][3] + node.State.Data[20][4] + node.State.Data[20][5] +
      node.State.Data[20][6] + node.State.Data[20][7] + node.State.Data[20][8] + node.State.Data[20][9] + node.State.Data[20][10]) < 1 then
      perfect_clear = 1
    end
    score = score + perfect_clear * this.Weights.PerfectClear

    -- line clear
    score = score + Evaluator.Function.SpecialLineClear(node) * this.Weights.SpeLineClear

    -- t spin
    if node.State.WasTSpin then
      if node.State.LineCleared == 1 then score = score + this.Weights.TSpinSingle
      elseif node.State.LineCleared == 2 then score = score + this.Weights.TSpinDouble
      elseif node.State.LineCleared == 3 then score = score + this.Weights.TSpinTriple end
    end--]]

    -- collumns' height
    local collumn_height = Evaluator.Function.GetCollumnHeight(node)
    for i = 1, 10 do
      score = score + (collumn_height[i] * this.Weights.HeightCollumn[i])
    end--]]

    -- average height and special average height
    local sum_collumn = 0
    for i = 1, 10 do
      sum_collumn = sum_collumn + collumn_height[i]
    end
    score = score + sum_collumn / 10 * this.Weights.AverageHeight
    score = score + math.exp(sum_collumn / 10 - 15) * this.Weights.ExpAverageHeight--]]

    -- hole
    score = score + Evaluator.Function.GetHole(node.State.Data, collumn_height) * this.Weights.Hole

    -- bumpiness
    local bumpiness = Evaluator.Function.GetBumpiness(collumn_height)
    score = score + bumpiness[1] * this.Weights.Bumpiness
    score = score + bumpiness[2] * this.Weights.SpeBumpiness

    -- block above hole
    local block_above_hole = Evaluator.Function.GetBlockAboveHole(node.State.Data, collumn_height)
    score = score + block_above_hole[1] * this.Weights.BlockAboveHole
    score = score + block_above_hole[2] * this.Weights.SpeBlockAboveHole

    -- structure
    local structure = Evaluator.Function.GetStructure(node.State.Data, collumn_height)
    node.State.Structure.TSpinDouble = structure[1]
    node.State.Structure.STSD = structure[2]
    node.State.Structure.TSTTSD = structure[3]
    score = score + structure[1] * this.Weights.Structure.TSpinDouble
    score = score + structure[2] * this.Weights.Structure.STSD
    score = score + structure[3] * this.Weights.Structure.TSTTSD

    -- waste structure
    local waste_structure = 0
    if node.State.WasTSpin and node.State.LineCleared > 0 then
      waste_structure = 0
    else
      waste_structure = math.max(0, (node.Parent.State.Structure.TSpinDouble + node.Parent.State.Structure.STSD + node.Parent.State.Structure.TSTTSD) - (node.State.Structure.TSpinDouble + node.State.Structure.STSD + node.State.Structure.TSTTSD))
    end
    score = score + waste_structure * this.Weights.WasteStructure
    --]]

    --print(score)

    return score
    --return math.random(1, 100)
  end

  return this
end

Evaluator.Function = {
  SpecialLineClear = function(node)
    if node.State.LineCleared == 0 then
      return 0
    else
      return math.exp(node.State.LineCleared - 2) - 4
    end
  end,

  GetCollumnHeight = function(node)
    local result = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

    for i = 1, 10 do
      local y_test = 0
      while y_test < 20 and node.State.Data[y_test + 1][i] < 1 do
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
        if board_data[k][i] < 1 and board_data[k - 1][i] > 0 then result = result + 1 end
      end
    end

    return result
  end,

  GetBlockAboveHole = function(board_data, collumn_height)
    local result = {0, 0}

    for i = 1, 10 do
      local count = 0
      local detected_hole = false
      for k = 21 - collumn_height[i], 19 do
        if not detected_hole then count = count + 1 end
        if board_data[k][i] > 0 and board_data[k + 1][i] < 1 then detected_hole = true end
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

    -- TSD
    for k = 21 - highest_height, 18 do
      for i = 1, 8 do
        if board_data[k][i] > 0 and board_data[k][i + 1] < 1 and board_data[k][i + 2] < 1
        and board_data[k + 1][i] < 1 and board_data[k + 1][i + 1] < 1 and board_data[k + 1][i + 2] < 1
        and board_data[k + 2][i] > 0 and board_data[k + 2][i + 1] < 1 and board_data[k + 2][i + 2] > 0 then
          result[1] = result[1] + 1
        end
        if board_data[k][i] < 1 and board_data[k][i + 1] < 1 and board_data[k][i + 2] > 0
        and board_data[k + 1][i] < 1 and board_data[k + 1][i + 1] < 1 and board_data[k + 1][i + 2] < 1
        and board_data[k + 2][i] > 0 and board_data[k + 2][i + 1] < 1 and board_data[k + 2][i + 2] > 0 then
          result[1] = result[1] + 1
        end
      end
    end

    -- STSD
    for k = 21 - highest_height, 16 do
      for i = 1, 7 do
        if board_data[k][i] < 1 and board_data[k][i + 1] < 1 and board_data[k][i + 2] > 0
        and board_data[k + 1][i] < 1 and board_data[k + 1][i + 1] < 1 and board_data[k + 1][i + 2] < 1 and board_data[k + 1][i + 3] > 0
        and board_data[k + 2][i] > 0 and board_data[k + 2][i + 1] > 0 and board_data[k + 2][i + 2] < 1 and board_data[k + 2][i + 3] > 0
        and board_data[k + 3][i] > 0 and board_data[k + 3][i + 1] < 1 and board_data[k + 3][i + 2] < 1 and board_data[k + 3][i + 3] > 0
        and board_data[k + 4][i] > 0 and board_data[k + 4][i + 1] < 1 and board_data[k + 4][i + 2] < 1 and board_data[k + 4][i + 3] > 0 then
          result[2] = result[2] + 1
        end
        if board_data[k][i + 1] > 0 and board_data[k][i + 2] < 1 and board_data[k][i + 3] < 1
        and board_data[k + 1][i] > 0 and board_data[k + 1][i + 1] < 1 and board_data[k + 1][i + 2] < 1 and board_data[k + 1][i + 3] < 1
        and board_data[k + 2][i] > 0 and board_data[k + 2][i + 1] < 1 and board_data[k + 2][i + 2] > 0 and board_data[k + 2][i + 3] > 0
        and board_data[k + 3][i] > 0 and board_data[k + 3][i + 1] < 1 and board_data[k + 3][i + 2] < 1 and board_data[k + 3][i + 3] > 0
        and board_data[k + 4][i] > 0 and board_data[k + 4][i + 1] < 1 and board_data[k + 4][i + 2] < 1 and board_data[k + 4][i + 3] > 0 then
          result[2] = result[2] + 1
        end
      end
    end

    -- TSTTSD
    for k = 21 - highest_height, 15 do
      for i = 1, 7 do
        if board_data[k][i + 1] > 0 and board_data[k][i + 2] < 1 and board_data[k][i + 3] < 1
        and board_data[k + 1][i + 1] < 1 and board_data[k + 1][i + 2] < 1 and board_data[k + 1][i + 3] < 1
        and board_data[k + 2][i] > 0 and board_data[k + 2][i + 1] < 1 and board_data[k + 2][i + 2] > 0 and board_data[k + 2][i + 3] > 0
        and board_data[k + 3][i] > 0 and board_data[k + 3][i + 1] < 1 and board_data[k + 3][i + 2] < 1 and board_data[k + 3][i + 3] > 0
        and board_data[k + 4][i] > 0 and board_data[k + 4][i + 1] < 1 and board_data[k + 4][i + 2] > 0 and board_data[k + 4][i + 3] > 0
        and board_data[k + 5][i + 1] > 0 and board_data[k + 5][i + 2] < 1 and board_data[k + 5][i + 3] > 0 then
          result[3] = result[3] + 1
        end
        if board_data[k][i] < 1 and board_data[k][i + 1] < 1 and board_data[k][i + 2] > 0
        and board_data[k + 1][i] < 1 and board_data[k + 1][i + 1] < 1 and board_data[k + 1][i + 2] < 1
        and board_data[k + 2][i] > 0 and board_data[k + 2][i + 1] > 0 and board_data[k + 2][i + 2] < 1 and board_data[k + 2][i + 3] > 0
        and board_data[k + 3][i] > 0 and board_data[k + 3][i + 1] < 1 and board_data[k + 3][i + 2] < 1 and board_data[k + 3][i + 3] > 0
        and board_data[k + 4][i] > 0 and board_data[k + 4][i + 1] > 0 and board_data[k + 4][i + 2] < 1 and board_data[k + 4][i + 3] > 0
        and board_data[k + 5][i] > 0 and board_data[k + 5][i + 1] < 1 and board_data[k + 5][i + 2] > 0 then
          result[3] = result[3] + 1
        end
      end
    end

    return result
  end,
}

return Evaluator
