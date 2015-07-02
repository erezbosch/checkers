require 'colorize'

class Piece
  attr_reader :color, :pos

  DOWNWARD_MOVES = [[1, -1], [1, 1]]
  UPWARD_MOVES = [[-1, -1], [-1, 1]]

  def initialize pos, board, color, king = false
    @pos, @board, @color, @king = pos, board, color, king
  end

  def king?
    @king
  end



  def perform_slide new_pos
    return false if invalid_slide?(new_pos)
    @pos = new_pos
    maybe_promote
    true
  end

  def perform_jump
    return false if invalid_jump?(new_pos)
    @board[middle_pos(new_pos)] = nil
    @pos = new_pos
    maybe_promote
    true
  end


  def to_s
    symbol = king? ? "K" : "C"
    color == :black ? symbol.black : symbol.red
  end

  private

  def off_board? new_pos
    new_pos.any? { |coord| !coord.between?(0, @board.size - 1) }
  end

  def invalid_slide? new_pos
    illegal_move = move_diffs.all? do |diff|
      [pos[0] + diff[0], pos[1] + diff[1]] != new_pos
    end

    off_board?(new_pos) || !@board[new_pos].nil? || illegal_move
  end

  def invalid_jump? new_pos
    illegal_move = move_diffs.all? do |diff|
      [pos[0] + 2 * diff[0], pos[1] + 2 * diff[1]] != new_pos
    end

    jumpable = has_enemy_piece?(middle_pos(new_pos)) && @board[new_pos].nil?

    off_board?(new_pos) || !jumpable || illegal_move
  end

  def middle_pos end_pos
    [(pos[0] + end_pos[0]) / 2, (pos[1] + end_pos[1]) / 2]
  end

  def has_enemy_piece? target_pos
    !@board[target_pos].nil? && @board[target_pos].color != color
  end

  def maybe_promote
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
end
