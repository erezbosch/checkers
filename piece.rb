class Piece
  attr_reader :pos, :color

  DOWNWARD_MOVES = [[1, -1], [1, 1]]
  UPWARD_MOVES = [[-1, -1], [-1, 1]]

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

  def move_diffs
    if king?
      DOWNWARD_MOVES + UPWARD_MOVES
    elsif color == :black
      DOWNWARD_MOVES
    else
      UPWARD_MOVES
    end
  end

  def perform_slide
  end

  def valid_slide? new_pos

  end

  def to_s
    king? ? "K" : "C"
  end
end
