local Tetrismino = require "Game/Tetrismino"

Z = {}

Z.New = function(board, x_position, y_position)
  local this = Tetrismino.New(board, x_position, y_position)

  this.ID = 'Z'
  this.Forms = {
    {
      {7, 7, 0},
      {0, 7, 7},
      {0, 0, 0}
    },
    {
      {0, 0, 7},
      {0, 7, 7},
      {0, 7, 0}
    },
    {
      {0, 0, 0},
      {7, 7, 0},
      {0, 7, 7}
    },
    {
      {0, 7, 0},
      {7, 7, 0},
      {7, 0, 0}
    }
  }

  return this
end

return Z
