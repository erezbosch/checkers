class Piece
  attr_reader :pos, :color

  def initialize pos, board, color, king = false
    @pos, @board, @color, @king = pos, board, color, king
  end

  def king?
    @king
  end

  def promotion
    if (pos[0] == 0 && color == :red) || (pos[0] == 7 && color == :black)
      @king = true
    end
  end

end
