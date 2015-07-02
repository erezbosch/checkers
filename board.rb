require 'colorize'
require_relative 'piece'

class Board
  attr_reader :cursor

  def initialize
    @grid = Array.new(8) { Array.new(8) }
    @cursor = [4, 4]
  end

  def populate
    3.times do |row_idx|
      populate_row(row_idx)
      populate_row(7 - row_idx)
    end
  end

  def populate_row(row_idx)
    color = (row_idx < 3) ? :black : :red
    8.times do |col_idx|
      pos = [row_idx, col_idx]
      self[pos] = Piece.new(pos, self, color) if (row_idx + col_idx).odd?
    end
  end

  def [] pos
    row, col = pos
    @grid[row][col]
  end

  def []= pos, thing
    row, col = pos
    @grid[row][col] = thing
  end

  def dup
    duped_board = self.class.new
    8.times do |row_idx|
      8.times do |col_idx|
        pos = row_idx, col_idx
        duped_board[pos] = self[pos].dup(duped_board) unless self[pos].nil?
      end
    end
    duped_board
  end

  def pieces
    @grid.flatten.compact
  end

  def over?
    pieces.map(&:color).uniq.size < 2
  end

  def winner
    return false unless over?
    pieces.first.color
  end

  def move_cursor dir
    new_cursor = [@cursor[0] + dir[0], @cursor[1] + dir[1]]
    @cursor = new_cursor if new_cursor.all? { |coord| coord.between?(0, 7) }
  end

  def self.prepare
    b = self.new
    b.populate
    b
  end
end
