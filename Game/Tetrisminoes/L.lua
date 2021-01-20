local Tetrismino = require "Game/Tetrismino"

L = {}

L.New = function(board, x_position, y_position)
  local this = Tetrismino.New(board, x_position, y_position)

  this.ID = 'L'
  this.Forms = {
    {
      {0, 0, 3},
      {3, 3, 3},
      {0, 0, 0}
    },
    {
      {0, 3, 0},
      {0, 3, 0},
      {0, 3, 3}
    },
    {
      {0, 0, 0},
      {3, 3, 3},
      {3, 0, 0}
    },
    {
      {3, 3, 0},
      {0, 3, 0},
      {0, 3, 0}
    }
  }

  return this
end

return L
