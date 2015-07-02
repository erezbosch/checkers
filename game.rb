require_relative 'board'
require 'io/console'
require 'colorize'

class Game
  def initialize player_classes = [HumanPlayer, HumanPlayer]
    @board, @players = Board.prepare, []
    colors = [:black, :red]
    2.times { |idx| @players << player_classes[idx].new(@board, colors[idx]) }
  end

  def play
    until @board.over?
      take_turn
    end
    system "clear"
    display_message("#{@board.winner.to_s.capitalize} wins!")
  end

  private

  def switch_players!
    @players.reverse!
  end

  def take_turn
    begin
      input = @players.first.get_moves_from_cursor

      raise InvalidMoveError if input.length < 2

      @board[input.first].perform_moves(input.drop(1))
    rescue InvalidMoveError
      display_message("Invalid move sequence!")
      retry
    end
    switch_players!
  end

  def display_message(message)
    system "clear"
    puts "\n\n\n#{message.center(75)}"
    sleep(1.5)
  end
end

class HumanPlayer
  attr_reader :color

  def initialize board, color
    @board, @color = board, color
    @input = []
  end

  def get_moves_from_cursor
    @input = []
    char = nil
    until char == " "
      display_board

      char = $stdin.getch

      case char
      # handle cursor moves
      when "w"
        @board.move_cursor([-1, 0])
      when "a"
        @board.move_cursor([0, -1])
      when "s"
        @board.move_cursor([1, 0])
      when "d"
        @board.move_cursor([0, 1])
      when "\r"
        @input << cursor unless @input.empty? && invalid_first_selection?
      when "\e"
        exit
      end
    end

    display_board
    @input
  end

  def invalid_first_selection?
    @board[cursor].nil? || @board[cursor].color != color
  end

  def cursor
    @board.cursor
  end

  def display_board
    system "clear"
    display = Array.new(8) { "" }
    8.times do |row_idx|
      8.times do |col_idx|
        pos = [row_idx, col_idx]
        display[row_idx] +=
          " #{@board[pos].to_s} ".rjust(3).colorize(background: bg_color(pos))
      end
    end

    display.each_with_index do |row, idx|
      puts "#{row} #{instructions(idx)}"
    end
  end

  def bg_color pos
    if pos == cursor
      :green
    elsif @input.include?(pos)
      :yellow
    else
      pos.inject(:+).odd? ? :white : :blue
    end
  end

  def instructions(idx)
    case idx
    when 1
      "It's #{color.to_s.capitalize}'s turn."
    when 2
      "Press W-A-S-D to move the cursor or return to select."
    when 3
      "First select the piece you'd like to move."
    when 4
      "Then select the square(s) that piece should move to."
    when 5
      "If you're done, press space to process your move."
    when 6
      "Press esc to quit at any time."
    else
      ""
    end
  end
end

class InvalidMoveError < StandardError
end

Game.new.play if __FILE__ == $PROGRAM_NAME
