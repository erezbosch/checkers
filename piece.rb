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

  def perform_moves move_sequence
    unless move_sequence.length > 0 && valid_move_seq?(move_sequence)
      raise InvalidMoveError
    end
    perform_moves!(move_sequence)
  end

  def to_s
    symbol = king? ? "❤" : "★"
    color == :black ? symbol.black : symbol.red
  end

  def dup duped_board
    Piece.new(@pos, duped_board, @color, king?)
  end

  def valid_jumps
    move_diffs.inject([]) do |jumps, diff|
      new_pos = [pos[0] + 2 * diff[0], pos[1] + 2 * diff[1]]
      invalid_jump?(new_pos) ? jumps : jumps << new_pos
    end
  end

  def valid_slides
    move_diffs.inject([]) do |slides, diff|
      new_pos = [pos[0] + diff[0], pos[1] + diff[1]]
      invalid_slide?(new_pos) ? slides : slides << new_pos
    end
  end

  protected

  def perform_moves! move_sequence
    if move_sequence.length == 1
      return if perform_slide(move_sequence[0])
    end

    move_sequence.length.times do |i|
      jump = perform_jump(move_sequence[i])
      raise InvalidMoveError unless jump
    end
  end

  def valid_move_seq? move_sequence
    duped_board = @board.dup
    duped_piece = duped_board[@pos]
    duped_piece.perform_moves!(move_sequence)
    true
  rescue InvalidMoveError
    false
  end

  def perform_slide new_pos
    return false if invalid_slide?(new_pos)
    @board[@pos] = nil
    @pos = new_pos
    @board[new_pos] = self
    maybe_promote
    true
  end

  def perform_jump new_pos
    return false if invalid_jump?(new_pos)
    @board[@pos] = nil
    @board[middle_pos(new_pos)] = nil
    @pos = new_pos
    @board[new_pos] = self
    maybe_promote
    true
  end

  def off_board? new_pos
    new_pos.any? { |coord| !coord.between?(0, 7) }
  end

  def invalid_slide? new_pos
    return true if off_board?(new_pos)
    
    illegal_move = move_diffs.all? do |diff|
      [@pos[0] + diff[0], @pos[1] + diff[1]] != new_pos
    end

    !@board[new_pos].nil? || illegal_move
  end

  def invalid_jump? new_pos
    return true if off_board?(new_pos)

    illegal_move = move_diffs.all? do |diff|
      [@pos[0] + 2 * diff[0], @pos[1] + 2 * diff[1]] != new_pos
    end

    jumpable = has_enemy_piece?(middle_pos(new_pos)) && @board[new_pos].nil?

    !jumpable || illegal_move
  end

  def middle_pos end_pos
    [(@pos[0] + end_pos[0]) / 2, (@pos[1] + end_pos[1]) / 2]
  end

  def has_enemy_piece? target_pos
    !@board[target_pos].nil? && @board[target_pos].color != color
  end

  def maybe_promote
    if (@pos[0] == 0 && color == :red) || (@pos[0] == 7 && color == :black)
      @king = true
    end
  end

  def move_diffs
    if king?
      DOWNWARD_MOVES + UPWARD_MOVES
    else
      color == :black ? DOWNWARD_MOVES : UPWARD_MOVES
    end
  end
end
