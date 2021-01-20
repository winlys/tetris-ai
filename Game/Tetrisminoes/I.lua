local Tetrismino = require "Game/Tetrismino"

I = {}

I.New = function(board, x_position, y_position)
  local this = Tetrismino.New(board, x_position, y_position)

  this.ID = 'I'
  this.Forms = {
    {
      {0, 0, 0, 0},
      {1, 1, 1, 1},
      {0, 0, 0, 0},
      {0, 0, 0, 0}
    },
    {
      {0, 0, 1, 0},
      {0, 0, 1, 0},
      {0, 0, 1, 0},
      {0, 0, 1, 0}
    },
    {
      {0, 0, 0, 0},
      {0, 0, 0, 0},
      {1, 1, 1, 1},
      {0, 0, 0, 0}
    },
    {
      {0, 1, 0, 0},
      {0, 1, 0, 0},
      {0, 1, 0, 0},
      {0, 1, 0, 0}
    }
  }
  this.SRSData = {
    {{ -2, 0 }, { 1, 0 }, { -2, 1 }, { 1, -2 }},
    {{ 2, 0 }, { -1, 0 }, { 2, -1 }, { -1, 2 }},
    {{ -1, 0 }, { 2, 0 }, { -1, -2 }, { 2, 1 }},
    {{ 1, 0 }, { -2, 0 }, { 1, 2 }, { -2, -1 }}
  }

  this.SRS = function(old, new)
    k = 0
    if (old == 1 and new == 2) or (old == 4 and new == 3) then k = 1
    elseif (old == 2 and new == 1) or (old == 3 and new == 4) then k = 2
    elseif (old == 2 and new == 3) or (old == 1 and new == 4) then k = 3
    elseif (old == 3 and new == 2) or (old == 4 and new == 1) then k = 4 end

    if this.IsOverlapping(this.X, this.Y) then
      for i = 1, 4 do
        this.X = this.X + this.SRSData[k][i][1]
        this.Y = this.Y + this.SRSData[k][i][2]
        if this.IsOverlapping(this.X, this.Y) then
          this.X = this.X - this.SRSData[k][i][1]
          this.Y = this.Y - this.SRSData[k][i][2]
        else
          return 0
        end
      end
      this.CurrentFormID = old
      return 0
    else
      return 0
    end
  end

  return this
end


return I
