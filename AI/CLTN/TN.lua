local Node = require "AI/MCTS_2/Node"
local Tree = require "AI/MCTS_2/Tree"
local Evaluator = require "AI/MCTS_2/Evaluator"
local AI = require "AI/MCTS_2/AI" --]]

local TN = {}

TN.New = function(num_population, num_generation)
  local this = {}

  this.NumberPopulation = num_population
  this.NumberGeneration = num_generation

  this.Population = {}
  this.Generation = 0

  -- fill population
  for i = 1, this.NumberPopulation do
    local new_ai = AI.New()
    new_ai.SetParameter(5, 250)
    for k,v in pairs(new_ai.Evaluator.Weights) do
      if type(v) ~= "table" then
        new_ai.Evaluator.Weights[k] = math.random(-100, 100)
      end
    end
    for k,v in pairs(new_ai.Evaluator.Weights.HeightCollumn) do new_ai.Evaluator.Weights.HeightCollumn[k] = math.random(-100, 100) end
    for k,v in pairs(new_ai.Evaluator.Weights.Structure) do new_ai.Evaluator.Weights.Structure[k] = math.random(-100, 100) end
    table.insert(this.Population, new_ai)
  end

  -- write weight to file
  this.SaveWeight = function(index)
    local file = io.open("weights.txt", "a")

    --this.Population[index].Evaluator.Weights
    file:write("gen " .. tostring(this.Generation) .. "    child #" .. tostring(index) .. ":" .. "\n")
    file:write(this.Serialize(this.Population[index].Evaluator.Weights))
    file:write("\n")
    file.close()
  end

  -- Serialize table
  this.Serialize = function(o)
    local result = ""
    if type(o) == "number" then
      result = result .. tostring(o)
    elseif type(o) == "string" then
      result = result .. string.format("%q", o)
    elseif type(o) == "table" then
      result = result .. "{"
      for k,v in pairs(o) do
        result = result .. "  [ " .. k .. " ] = "
        result = result .. this.Serialize(v)
      end
      result = result .. "}"
    else
      error("cannot serialize a " .. type(o))
    end
    return result
  end

  -- Mutation
  this.Mutuate = function(ai_1, ai_2)
    local new_ai = AI.New()
    new_ai.SetParameter(5, 250)
    for k,v in pairs(new_ai.Evaluator.Weights) do
      if type(v) ~= "table" then
        local r = math.random(1, 100)
        if r <= 40 then new_ai.Evaluator.Weights[k] = ai_1.Evaluator.Weights[k]
        elseif r <= 80 then new_ai.Evaluator.Weights[k] = ai_2.Evaluator.Weights[k]
        else new_ai.Evaluator.Weights[k] = (ai_1.Evaluator.Weights[k] + ai_2.Evaluator.Weights[k]) / 2 end
      end
    end
    for k,v in pairs(new_ai.Evaluator.Weights.HeightCollumn) do
      local r = math.random(1, 100)
      if r <= 40 then new_ai.Evaluator.Weights.HeightCollumn[k] = ai_1.Evaluator.Weights.HeightCollumn[k]
      elseif r <= 80 then new_ai.Evaluator.Weights.HeightCollumn[k] = ai_2.Evaluator.Weights.HeightCollumn[k]
      else new_ai.Evaluator.Weights.HeightCollumn[k] = (ai_1.Evaluator.Weights.HeightCollumn[k] + ai_2.Evaluator.Weights.HeightCollumn[k]) / 2 end
    end
    for k,v in pairs(new_ai.Evaluator.Weights.Structure) do
      local r = math.random(1, 100)
      if r <= 40 then new_ai.Evaluator.Weights.Structure[k] = ai_1.Evaluator.Weights.Structure[k]
      elseif r <= 80 then new_ai.Evaluator.Weights.Structure[k] = ai_2.Evaluator.Weights.Structure[k]
      else new_ai.Evaluator.Weights.Structure[k] = (ai_1.Evaluator.Weights.Structure[k] + ai_2.Evaluator.Weights.Structure[k]) / 2 end
    end
    table.insert(this.Population, new_ai)
    return new_ai

  end


  return this
end

return TN
