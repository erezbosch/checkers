require_relative 'board'

class Game
  def initialize
    @players = [HumanPlayer.new, HumanPlayer.new]
    @colors = { @players[0] => :black, @players[1] => :red }
    @board = Board.prepare_board
  end

  def play
    until over?
      
    end
  end
end

class HumanPlayer
