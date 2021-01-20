local Tetrismino = require "Game/Tetrismino"

T = {}

T.New = function(board, x_position, y_position)
  local this = Tetrismino.New(board, x_position, y_position)

  this.ID = 'T'
  this.Forms = {
    {
      {0, 6, 0},
      {6, 6, 6},
      {0, 0, 0}
    },
    {
      {0, 6, 0},
      {0, 6, 6},
      {0, 6, 0}
    },
    {
      {0, 0, 0},
      {6, 6, 6},
      {0, 6, 0}
    },
    {
      {0, 6, 0},
      {6, 6, 0},
      {0, 6, 0}
    }
  }

  return this
end

return T
