local Tetrismino = require "Game/Tetrismino"

J = {}

J.New = function(board, x_position, y_position)
  local this = Tetrismino.New(board, x_position, y_position)

  this.ID = 'J'
  this.Forms = {
    {
      {2, 0, 0},
      {2, 2, 2},
      {0, 0, 0}
    },
    {
      {0, 2, 2},
      {0, 2, 0},
      {0, 2, 0}
    },
    {
      {0, 0, 0},
      {2, 2, 2},
      {0, 0, 2}
    },
    {
      {0, 2, 0},
      {0, 2, 0},
      {2, 2, 0}
    }
  }

  return this
end

return J
