require_relative 'board'
require_relative 'humanplayer'
require_relative 'aiplayer'
require 'io/console'
require 'yaml'

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

  def self.set_up_game
    puts "Welcome to Checkers!"
    puts "1 Human vs Human "
    puts "2 Human vs Computer "
    puts "3 Computer vs Human "
    puts "4 Load Game "
    case $stdin.getch.to_i
    when 1
      self.new([HumanPlayer, HumanPlayer]).play
    when 2
      self.new([HumanPlayer, AiPlayer]).play
    when 3
      self.new([AiPlayer, HumanPlayer]).play
    when 4
      self.load
    else
      self.new.play
    end
  end

  protected

  def self.load
    begin
      puts "Enter the name of the file you want to load from: "
      name = gets.chomp
      exit if name == "\e"
      raise NameError unless File.exist?(name)
      YAML.load_file(name).play
    rescue NameError
      print "Invalid filename. "
      retry
    end
  end

  private

  def save(name)
    f = File.new(name, "w")
    f.puts self.to_yaml
    f.close
  end

  def switch_players!
    @players.reverse!
  end

  def take_turn
    begin
      input = @players.first.get_move

      if input.is_a?(String)
        save(input)
        raise InvalidMoveError.new("Game saved!")
      end

      raise InvalidMoveError if input.length < 2

      @board[input.first].perform_moves(input.drop(1))

    rescue InvalidMoveError => e
      display_message(e.message)

      retry
    end
    switch_players!
  end

  def display_message message
    system "clear"
    puts "\n\n\n#{message.center(75)}"
    sleep(1.5)
  end
end

class InvalidMoveError < StandardError
  attr_reader :message

  def initialize message = "Invalid move sequence!"
    @message = message
  end
end

Game.set_up_game if __FILE__ == $PROGRAM_NAME
