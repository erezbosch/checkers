require_relative 'board'
require 'io/console'
require 'colorize'
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
    puts "Press 1 to play or 2 to load your game: "
    if $stdin.getch == "2"
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
      input = @players.first.get_moves_from_cursor

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

class HumanPlayer
  attr_reader :color

  def initialize board, color
    @board, @color = board, color
  end

  def get_moves_from_cursor
    @input = []
    char = nil
    until char == " "
      display_board

      char = $stdin.getch

      case char
      when "w"
        @board.move_cursor([-1, 0])
      when "a"
        @board.move_cursor([0, -1])
      when "s"
        @board.move_cursor([1, 0])
      when "d"
        @board.move_cursor([0, 1])
      when "\r"
        if @input.empty?
          @input << cursor unless invalid_first_selection?
        else
          cursor == @input.last ? @input.pop : @input << cursor
        end
      when "r"
        return get_save_name
      when "\e"
        exit
      end
    end

    display_board
    @input
  end

  private

  def get_save_name
    begin
      puts "Enter the name of the file you want to save to: "
      name = gets.chomp
      exit if name == "\e"
      raise NameError if name == ""
      return name
    rescue NameError
      puts "Invalid filename."
      retry
    end
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
        display[row_idx] += pos_to_s([row_idx, col_idx])
      end
    end

    display.each_with_index do |row, idx|
      puts "#{row} #{instructions(idx)}"
    end
  end

  def pos_to_s pos
    " #{@board[pos].to_s} ".rjust(3).colorize(background: bg_color(pos))
  end

  def bg_color pos
    if pos == cursor
      :green
    elsif @input.include?(pos)
      :yellow
    else
      if show_as_possible_slide?(pos) || show_as_possible_jump?(pos)
        :blue
      else
        pos.inject(:+).odd? ? :white : :black
      end
    end
  end

  def show_as_possible_slide? pos
    @input.length == 1 && @board[@input.last].valid_slides.include?(pos)
  end

  def show_as_possible_jump? pos
    return false if @input.length == 0
    if @input.length == 2
      return false if @board[@input.first].valid_slides.include?(@input.last)
    end

    if @input.length > 1
      test_board = @board.dup
      test_board[@input.first].perform_moves(@input.drop(1))
      test_board[@input.last].valid_jumps.include?(pos)
    else
      @board[@input.last].valid_jumps.include?(pos)
    end

  rescue InvalidMoveError
    false
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
      "Press R to save or esc to quit at any time."
    else
      ""
    end
  end
end

class InvalidMoveError < StandardError
  attr_reader :message

  def initialize message = "Invalid move sequence!"
    @message = message
  end
end

Game.set_up_game if __FILE__ == $PROGRAM_NAME
