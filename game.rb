require_relative 'board'
require_relative 'piece'

class Game
  def initialize players = [HumanPlayer.new, HumanPlayer.new]
    @players = players
    @colors = { @players[0] => :black, @players[1] => :red }
    @board = Board.prepare_board
  end

  def play
    until @board.over?
      take_turn
    end
    p @board.winner
  end

  private

  def switch_players!
    @players.reverse!
  end

  def take_turn
    puts "\n\n\n"
    @board.display
    identify_turn

    begin
      input = @players.first.get_move_sequence

      raise InvalidMoveError if invalid_input?(input)

      @board[input.first].perform_moves(input.drop(1))
    rescue InvalidMoveError
      puts "Your input was invalid. Please read the directions carefully."
      retry
    end
    switch_players!
  end

  def invalid_input? input
    return true if @board[input.first].nil? || input.length < 2
    return true if @board[input.first].color != @colors[@players.first]
    false
  end

  def identify_player
    @colors[@players.first].to_s.capitalize
  end

  def identify_turn
    puts "It's #{identify_player}'s turn."
  end
end

class HumanPlayer
  def initialize
  end

  def get_move_sequence
    puts "Enter your move sequence starting with the piece you'd like to move,"
    print "for example '2,0;4,2;6,4'. \n> "
    gets.chomp.split(";").map { |move| move.split(",").map(&:to_i) }
  end
end

class InvalidMoveError < StandardError
end

Game.new.play if __FILE__ == $PROGRAM_NAME
