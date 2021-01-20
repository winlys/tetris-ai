local Tetrismino = require "Game/Tetrismino"

S = {}

S.New = function(board, x_position, y_position)
  local this = Tetrismino.New(board, x_position, y_position)

  this.ID = 'S'
  this.Forms = {
    {
      {0, 5, 5},
      {5, 5, 0},
      {0, 0, 0}
    },
    {
      {0, 5, 0},
      {0, 5, 5},
      {0, 0, 5}
    },
    {
      {0, 0, 0},
      {0, 5, 5},
      {5, 5, 0}
    },
    {
      {5, 0, 0},
      {5, 5, 0},
      {0, 5, 0}
    }
  }

  return this
end

return S
