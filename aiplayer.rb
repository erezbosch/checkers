class AiPlayer

  def initialize board, color
    @board, @color = board, color
  end

  def get_move
    my_pieces = get_pieces.shuffle

    # try to jump if I can
    my_jumps = my_pieces.map { |piece| piece.valid_jumps.shuffle }
    my_pieces.length.times do |i|
      return [my_pieces[i].pos, my_jumps[i][0]] unless my_jumps[i].empty?
    end

    # crown a piece if I can
    kings_row = @color == :black ? 7 : 0
    my_slides = my_pieces.map { |piece| piece.valid_slides.shuffle }
    my_pieces.length.times do |i|
      unless my_pieces[i].king?
        my_slides[i].each do |slide|
          return [my_pieces[i].pos, slide] if slide[0] == kings_row
        end
      end
    end

    # return a random move otherwise
    my_piece = my_pieces.reject { |piece| piece.valid_slides.empty? }.sample
    [my_piece.pos, my_piece.valid_slides.sample]
  end

  def get_pieces
    @board.pieces.select { |piece| piece.color == @color }
  end
end
