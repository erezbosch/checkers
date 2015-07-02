require 'colorize'
require_relative 'piece'

class Board
  def initialize
    @grid = Array.new(8) { Array.new(8) }
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

  def get_bg_color pos
    pos.inject(:+).odd? ? :white : :blue
  end

  def display
    8.times do |row_idx|
      8.times do |col_idx|
        pos = [row_idx, col_idx]
        print "#{self[pos].to_s} ".colorize(:background => get_bg_color(pos))
      end
      puts
    end
  end

  def self.prepare_board
    self.new.populate
  end


end
