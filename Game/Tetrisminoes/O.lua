local Tetrismino = require "Game/Tetrismino"

O = {}

O.New = function(board, x_position, y_position)
  local this = Tetrismino.New(board, x_position, y_position)

  this.ID = 'O'
  this.Forms = {
    {
      {4, 4},
      {4, 4}
    }
  }

  this.SRS = function(old, new)
    return -1
  end

  return this
end

return O
