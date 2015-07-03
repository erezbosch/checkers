require 'colorize'

class HumanPlayer
  attr_reader :color

  def initialize board, color
    @board, @color = board, color
  end

  def get_move
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
