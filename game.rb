require_relative 'board'
require 'io/console'

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
    puts "\n\n#{identify_color(@board.winner)} wins!"
  end

  private

  def switch_players!
    @players.reverse!
  end

  def take_turn
    system "clear"
    @board.display
    identify_turn

    begin
      input = @players.first.get_moves_from_cursor

      raise InvalidMoveError if input.length < 2

      @board[input.first].perform_moves(input.drop(1))
    rescue InvalidMoveError
      puts "Your input was invalid. Please read the directions carefully."
      retry
    end
    switch_players!
  end

  def identify_color color
    color.to_s.capitalize
  end

  def identify_turn
    puts "It's #{identify_color(@players.first.color)}'s turn."
  end
end

class HumanPlayer
  attr_reader :color

  def initialize board, color
    @board = board
    @color = color
  end

  # input by hand

  def get_move_sequence
    puts "Enter your move sequence starting with the piece you'd like to move,"
    print "for example '2,0;4,2;6,4'. \n> "
    gets.chomp.split(";").map { |move| move.split(",").map(&:to_i) }
  end

  # input from cursor

  def get_moves_from_cursor
    input = []
    char = nil
    until char == " "
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

      # add to move sequence
      when "\r"
        if input.empty? && !@board[cursor].nil?
          input << @board.cursor if @board[cursor].color == color
        elsif !input.empty? && @board[cursor].nil?
          input << @board.cursor
          p input
          unless @board[input.first].valid_move_seq?(input.drop(1))
            raise InvalidMoveError
          end
        end

      when "\e"
        exit
      end

      system "clear"
      @board.display
    end

    p input
    input
  end

  def cursor
    @board.cursor
  end
end

class InvalidMoveError < StandardError
end

Game.new.play if __FILE__ == $PROGRAM_NAME
