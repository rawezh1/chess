# frozen_string_literal: true

require 'pry'
# Adds check if string is integer to String class
class String
  def is_i?
    /\A[-+]?\d+\z/ === self
  end
end

# Creates a chess board and two players
class Chess
  attr_accessor :board, :player1, :player2

  def initialize
    @board = Array.new(8) { Array.new(8) { '_' } }
    @player1 = Player.new('White')
    @player2 = Player.new('Black')
    @turns = 0
  end

  def fill_board
    # fill black side
    @board[1] = Array.new(8).fill { |i| Pawn.new('BP', '♙', [1, i]) }
    @board[0][0] = Rook.new('BR', '♖', [0, 0])
    @board[0][7] = Rook.new('BR', '♖', [0, 7])
    @board[0][1] = Knight.new('BK', '♘', [0, 1])
    @board[0][6] = Knight.new('BK', '♘', [0, 6])
    @board[0][2] = Bishop.new('BB', '♗', [0, 2])
    @board[0][5] = Bishop.new('BB', '♗', [0, 5])
    @board[0][3] = Queen.new('BQ', '♕', [0, 3])
    @board[0][4] = King.new('BKi', '♔', [0, 4])
    # fill white side
    @board[6] = Array.new(8).fill { |i| Pawn.new('WP', '♟︎', [6, i]) }
    @board[7][0] = Rook.new('WR', '♜', [7, 0])
    @board[7][7] = Rook.new('WR', '♜', [7, 7])
    @board[7][1] = Knight.new('WK', '♞', [7, 1])
    @board[7][6] = Knight.new('WK', '♞', [7, 6])
    @board[7][2] = Bishop.new('WB', '♝', [7, 2])
    @board[7][5] = Bishop.new('WB', '♝', [7, 5])
    @board[7][3] = Queen.new('WQ', '♛', [7, 3])
    @board[7][4] = King.new('WKi', '♚', [7, 4])
    self
  end

  def play
    loop do
      turn(@player1)
      return if game_over?(@board, @player2)

      turn(@player2)
      return if game_over?(@board, @player1)
    end
  end

  def turn(player)
    p "It is #{player.name} players turn, please select a piece by typing its row and column"
    from_pos = self.from_pos(player)
    to_pos = self.to_pos(player, from_pos)
    apply_move(from_pos, to_pos, player)
  end

  def from_pos(player)
    loop do
      choice = gets.chomp.split('')
      if invalid_choice?(choice, player) then next end

      return choice.map(&:to_i)
    end
  end

  def invalid_choice?(choice, player)
    #binding.pry
    if choice.length != 2 || !choice[0].is_i? || !choice[1].is_i?
      puts 'Invalid input, please type a correct value'
      return true
    end
    choice = choice.map(&:to_i)
    if !choice[0].between?(0, 7) || !choice[1].between?(0, 7)
      puts 'Invalid input, please type a correct value'
      true
    elsif @board[choice[0]][choice[1]] == '_'
      puts 'Invalid input, please type a correct value'
      true
    elsif @board[choice[0]][choice[1]].name[0] != player.name[0]
      puts 'Invalid input, please type a correct value'
      true
    elsif @board[choice[0]][choice[1]].moves(@board, player).empty?
      puts 'Invalid input, please type a correct value'
      true
    else
      false
    end
  end

  def to_pos(player, init_pos)
    p 'Please select a position to move the piece to by typing its row and column'
    loop do
      choice = gets.chomp.split('')
      if invalid_move?(choice, player, init_pos) then next end

      return choice.map(&:to_i)
    end
  end

  def invalid_move?(choice, player, init_pos)
    if choice.length != 2 || !choice[0].is_i? || !choice[1].is_i?
      puts 'Invalid input, please type a correct value'
      return true
    end
    choice = choice.map(&:to_i)
    if !choice[0].between?(0, 7) || !choice[1].between?(0, 7)
      puts 'Invalid input, please type a correct value'
      true
    elsif !possible_move?(choice, init_pos, player)
      puts 'Invalid input, please type a correct value'
      true
    end
  end

  def possible_move?(final_pos, init_pos, player)
    possible_moves = @board[init_pos[0]][init_pos[1]].moves(@board, player)
    unless possible_moves.include?(final_pos) then return false end
    if player.in_check && !removes_check?(final_pos, player) then return false end
    if puts_incheck?(init_pos, player) then return false end
    true
  end

  def removes_check?(final_pos, player)
    king = player.name[0] == 'W' ? 'WKi' : 'BKi'
    king_pos = pos_of(king)
    king = @board[king_pos[0]][king_pos[1]]
    if final_pos[0] == king_pos[0] && final_pos[0] == king.checker.pos[0]
      between_rank?(final_pos, king)
    elsif final_pos[1] == king_pos[1] && final_pos[1] == king.checker.pos[1]
      between_file?(final_pos, king)
    elsif same_diagonal?(final_pos, king_pos)
      if same_diagonal?(king_pos, king.checker.pos)
        in_between?(final_pos, king)
      else
        false
      end
    end
  end

  def pos_of(piece)
    pos = []
    @board.each_with_index do |e, i|
      e.each_with_index do |cell, j|
        if cell == '_' then next end
        if cell.name == piece then return pos = [i, j] end
      end
    end
      return pos
  end

  def same_diagonal?(point1, point2)
    point2[1]-point1[1] == point2[0] - point1[0] || point2[1]-point1[1] == point1[0] - point2[0]
  end

  def between_rank?(final_pos, king)
    if (king.pos[0] - king.checker.pos[0]).negative?
      final_pos[0].between?(king.pos[0], king.checker.pos[0])
    else
      final_pos[0].between?(king.checker.pos[0], king.pos[0])
    end
  end

  def between_file?(final_pos, king)
    if king.pos[1] - king.checker.pos[1] < 0
      final_pos[1].between?(king.pos[1],king.checker.pos[1])
    else
      final_pos[1].between?(king.checker.pos[1], king.pos[1])
    end
  end

  def in_between?(final_pos, king)
    if (king.pos[0] - king.checker.pos[0]).negative?
      if (king.pos[1] - king.checker.pos[1]).negative?
        final_pos[0].between?(king.pos[0], king.checker.pos[0]) && final_pos[1].between?(king.pos[1], king.checker.pos[1])
      else
        final_pos[0].between?(king.pos[0], king.checker.pos[0]) && final_pos[1].between?(king.checker.pos[1], king.pos[1])
      end
    else
      if (king.pos[1] - king.checker.pos[1]).negative?
        final_pos[0].between?( king.checker.pos[0], king.pos[0]) && final_pos[1].between?(king.pos[1], king.checker.pos[1])
      else
        final_pos[0].between?(king.checker.pos[0], king.pos[0]) && final_pos[1].between?(king.checker.pos[1], king.pos[1])
      end
    end
  end

  def puts_incheck?(init_pos, player)
    new_board = @board
    new_board[init_pos[0]][init_pos[1]] = '_'
    in_check?(new_board, player, pos_of(King.new("#{player.name[0]}Ki")))
  end

  def apply_move(init_pos, final_pos, player)
    @board[init_pos[0]][init_pos[1]].pos = [final_pos[0], final_pos[1]]
    @board[final_pos[0]][final_pos[1]] = @board[init_pos[0]][init_pos[1]]
    @board[init_pos[0]][init_pos[1]] = '_'
    oppos_player = player.name[0] == 'W' ? player2 : player1
    king_pos = pos_of(King.new("#{oppos_player.name[0]}Ki"))
    in_check = in_check?(@board, oppos_player, king_pos)
    if in_check[0]
      @board[king_pos[0]][king_pos[1]].checker = @board[in_check[1][0]][in_check[1][1]]
      oppos_player.in_check = true
    end
  end

  def game_over?(board, player)
    if no_legal_moves?(board, player)
      if player.in_check
        puts "Checkmate! #{player.name} player lost!"
        true
      else
        puts 'Stalemate'
        true
      end
    end
    false
  end

  def no_legal_moves?(board, player)
    board.each do |arr|
      arr.each do |piece|
        next if piece == '_' || piece.name[0] != player.name[0]
        return false unless piece.moves.empty?
      end
    end
    true
  end
end

class Player
  attr_accessor :name, :in_check

  def initialize(name)
    @name = name
    # @pieces = [pieces]
    @in_check = false
  end
end

class Piece
  attr_accessor :move_count, :pos, :name, :symbol

  def initialize(name, symbol, pos = [1, 1], move_count = 0)
    @pos = pos
    @move_count = move_count
    @name = name
    @symbol = symbol
  end
end

class Pawn < Piece

  def initialize(name, symbol, pos = [1, 1], move_count = 0)
    super(name, symbol, pos, move_count)
  end

  def moves(board, _player)
    if @name[0] == 'W'
      self.black_moves(board)
    else
      self.white_moves(board)
    end
  end

  def black_moves(board)
    moves = []
    moves << [pos[0] + 2, pos[1]] if @move_count.zero? && board[pos[0] + 2][pos[1]] == '_'
    moves << [pos[0] + 1, pos[1]] if board[pos[0] + 1][pos[1]] == '_'
    unless board[pos[0] + 1][pos[1] + 1] == '_' || nil_or_friend?(board[pos[0] + 1][pos[1] + 1], player)
      moves << [pos[0] + 1, pos[1] + 1]
    end
    unless board[pos[0] + 1][pos[1] - 1] == '_' || nil_or_friend?(board[pos[0] + 1][pos[1] - 1], player)
      moves << [pos[0] + 1, pos[1] - 1]
    end
    moves
  end

  def white_moves(board)
    moves = []
    moves << [pos[0] - 2, pos[1]] if @move_count.zero? && board[pos[0] - 2][pos[1]] == '_'
    moves << [pos[0] - 1, pos[1]] if board[pos[0] - 1][pos[1]] == '_'
    unless board[pos[0] - 1][pos[1] + 1] == '_' || nil_or_friend?(board[pos[0] - 1][pos[1] + 1], player)
      moves << [pos[0] - 1, pos[1] + 1]
    end
    unless board[pos[0] - 1][pos[1] - 1] == '_' || nil_or_friend?(board[pos[0] - 1][pos[1] - 1], player)
      moves << [pos[0] - 1, pos[1] - 1]
    end
    moves
  end
end

class Knight < Piece
  def initialize(name, symbol, pos = [1, 1], move_count = 0)
    super(name, symbol, pos, move_count)
  end

  def moves(board, player)
    moves = []
    moves + topside(board, player) + bottomside(board, player) + leftside(board, player) + rightside(board, player)
  end

  def bottomside(board, player)
    moves = []
    r = pos[0]
    f = pos[1]
    if r <= 5 && f >= 1
      moves << [r + 2, f - 1] unless nil_or_friend?(board[r + 2][f - 1], player)
    elsif r <= 5 && f <= 6
      moves << [r + 2, f + 1] unless nil_or_friend?(board[r + 2][f + 1], player)
    else
      moves
    end
  end

  def topside(board, player)
    moves = []
    r = pos[0]
    f = pos[1]
    if r >= 2 && f >= 1
      moves << [r - 2, f - 1] unless nil_or_friend?(board[r - 2][f - 1], player)
    elsif r >= 2 && f <= 6
      moves << [r - 2, f + 1] unless nil_or_friend?(board[r - 2][f + 1], player)
    else
      moves
    end
  end

  def rightside(board, player)
    moves = []
    r = pos[0]
    f = pos[1]
    if r <= 6 && f <= 5
      moves << [r + 1, f + 2] unless nil_or_friend?(board[r + 1][f + 2], player)
    elsif r >= 1 && f <= 5
      moves << [r - 1, f + 2] unless nil_or_friend?(board[r - 1][f + 2], player)
    else
      moves
    end
  end

  def leftside(board, player)
    moves = []
    r = pos[0]
    f = pos[1]
    if r <= 6 && f >= 2
      moves << [r + 1, f - 2] unless nil_or_friend?(board[r + 1][f - 2], player)
    elsif r >= 1 && f <= 2
      moves << [r - 1, f - 2] unless nil_or_friend?(board[r - 1][f - 2], player)
    else
      moves
    end
  end
end

class Bishop < Piece

  def initialize(name, symbol, pos = [1, 1], move_count = 0)
    super(name, symbol, pos, move_count)
  end

  def moves(board, player)
    ne_diagonal(board, player) + nw_diagonal(board, player) + se_diagonal(board, player) + sw_diagonal(board, player)
  end

  def nw_diagonal(board, player)
    r = pos[0] # initial rank of piece
    f = pos[1] # initial file of piece
    moves = []
    loop do
      r += 1 unless r == 7 # NW diagonal rank
      f -= 1 unless f.zero? # NW diagonal file
      return moves if nil_or_friend?(board[r][f], player)

      moves << [r, f]
      return moves unless board[r][f] == '_'
    end
  end

  def ne_diagonal(board, player)
    r = pos[0] # initial rank of piece
    f = pos[1] # initial file of piece
    moves = []
    loop do
      r += 1 unless r == 7 # NE diagonal rank
      f += 1 unless f == 7 # NE diagonal file
      return moves if nil_or_friend?(board[r][f], player)

      moves << [r, f]
      return moves unless board[r][f] == '_'
    end
  end

  def sw_diagonal(board, player)
    r = pos[0] # initial rank of piece
    f = pos[1] # initial file of piece
    moves = []
    loop do
      r -= 1 unless r.zero? # SW diagonal rank
      f -= 1 unless r.zero? # SW diagonal file
      return moves if nil_or_friend?(board[r][f], player)

      moves << [r, f]
      return moves unless board[r][f] == '_'
    end
  end

  def se_diagonal(board, player)
    r = pos[0] # initial rank of piece
    f = pos[1] # initial file of piece
    moves = []
    loop do
      r -= 1 unless r.zero? # SE diagonal rank
      f += 1 unless f == 7 # SE diagonal file
      return moves if nil_or_friend?(board[r][f], player)

      moves << [r, f]
      return moves unless board[r][f] == '_'
    end
  end
end

class Rook < Piece

  def initialize(name, symbol, pos = [1, 1], move_count = 0)
    super(name, symbol, pos, move_count)
  end

  def moves(board, player)
    up(board, player) + down(board, player) + left(board, player) + right(board, player)
  end

  def up(board, player)
    r = pos[0] # initial rank of piece
    f = pos[1] # initial file of piece
    moves = []
    loop do
      r += 1 unless r == 7 # Upper rank
      #binding.pry
      return moves if nil_or_friend?(board[r][f], player)

      moves << [r, f]
      return moves unless board[r][f] == '_'
    end
  end

  def down(board, player)
    r = pos[0] # initial rank of piece
    f = pos[1] # initial file of piece
    moves = []
    loop do
      r -= 1 unless r.zero? # lower rank
      return moves if nil_or_friend?(board[r][f], player)

      moves << [r, f]
      return moves unless board[r][f] == '_'
    end
  end

  def left(board, player)
    r = pos[0] # initial rank of piece
    f = pos[1] # initial file of piece
    moves = []
    loop do
      f -= 1 unless f.zero? # left file
      return moves if nil_or_friend?(board[r][f], player)

      moves << [r, f]
      return moves unless board[r][f] == '_'
    end
  end

  def right(board, player)
    r = pos[0] # initial rank of piece
    f = pos[1] # initial file of piece
    moves = []
    loop do
      f += 1 unless f == 7 # right file
      return moves if nil_or_friend?(board[r][f], player)

      moves << [r, f]
      return moves unless board[r][f] == '_'
    end
  end
end

class Queen < Piece

  def initialize(name, symbol, pos = [1, 1], move_count = 0)
    super(name, symbol, pos, move_count)
  end

  def moves(board, player)
    diagonal_moves(board, player) + flat_moves(board, player)
  end

  def flat_moves(board, player)
    up(board, player, self, 6) + down(board, player) + left(board, player) + right(board, player)
  end

  def down(board, player)
    r = pos[0] # initial rank of piece
    f = pos[1] # initial file of piece
    moves = []
    loop do
      r -= 1 # lower rank
      return moves if nil_or_friend?(board[r][f], player)

      moves << [r, f]
      return moves unless board[r][f] == '_'
    end
  end

  def left(board, player)
    r = pos[0] # initial rank of piece
    f = pos[1] # initial file of piece
    moves = []
    loop do
      f -= 1 # left file
      return moves if nil_or_friend?(board[r][f], player)

      moves << [r, f]
      return moves unless board[r][f] == '_'
    end
  end

  def right(board, player)
    r = pos[0] # initial rank of piece
    f = pos[1] # initial file of piece
    moves = []
    loop do
      f -= 1 # right file
      return moves if nil_or_friend?(board[r][f], player)

      moves << [r, f]
      return moves unless board[r][f] == '_'
    end
  end

  def diagonal_moves(board, player)
    ne_diagonal(board, player) + nw_diagonal(board, player) + se_diagonal(board, player) + sw_diagonal(board, player)
  end

  def nw_diagonal(board, player)
    r = pos[0] # initial rank of piece
    f = pos[1] # initial file of piece
    moves = []
    loop do
      r += 1 # NW diagonal rank
      f -= 1 # NW diagonal file
      return moves if nil_or_friend?(board[r][f], player)

      moves << [r, f]
      return moves unless board[r][f] == '_'
    end
  end

  def ne_diagonal(board, player)
    r = pos[0] # initial rank of piece
    f = pos[1] # initial file of piece
    moves = []
    loop do
      r += 1 # NE diagonal rank
      f += 1 # NE diagonal file
      return moves if nil_or_friend?(board[r][f], player)

      moves << [r, f]
      return moves unless board[r][f] == '_'
    end
  end

  def sw_diagonal(board, player)
    r = pos[0] # initial rank of piece
    f = pos[1] # initial file of piece
    moves = []
    loop do
      r -= 1 # SW diagonal rank
      f -= 1 # SW diagonal file
      return moves if nil_or_friend?(board[r][f], player)

      moves << [r, f]
      return moves unless board[r][f] == '_'
    end
  end

  def se_diagonal(board, player)
    r = pos[0] # initial rank of piece
    f = pos[1] # initial file of piece
    moves = []
    loop do
      r -= 1 # SE diagonal rank
      f += 1 # SE diagonal file
      return moves if nil_or_friend?(board[r][f], player)

      moves << [r, f]
      return moves unless board[r][f] == '_'
    end
  end
end

class King < Piece
  attr_accessor :checker

  def initialize(name, symbol, pos = [1, 1], move_count = 0)
    super(name, symbol, pos, move_count)
    @checker = nil
  end

  def moves(board, player)
    one_moves(board, player) + castling_moves(board, player)
  end

  def one_moves(board, player)
    r = pos[0]
    f = pos[1]
    moves = []
    moves << [r + 1, f] unless nil_or_friend?(board[r + 1][f], player)
    moves << [r - 1, f] unless nil_or_friend?(board[r - 1][f], player)
    moves << [r, f + 1] unless nil_or_friend?(board[r][f + 1], player)
    moves << [r, f - 1] unless nil_or_friend?(board[r][f - 1], player)
    moves << [r + 1, f + 1] unless nil_or_friend?(board[r + 1][f + 1], player)
    moves << [r + 1, f - 1] unless nil_or_friend?(board[r + 1][f - 1], player)
    moves << [r - 1, f + 1] unless nil_or_friend?(board[r - 1][f + 1], player)
    moves << [r - 1, f - 1] unless nil_or_friend?(board[r - 1][f - 1], player)
  end

  def castling_moves(board, player)
    return [] if board[pos[0]][pos[1]].move_count != 0

    king_castle(board, player) + queen_castle(board, player)
  end

  def king_castle(board, player)
    r = pos[0]
    moves = []
    moves if board[r][7] == '_' || board[r][7].name[1] != 'R'
    moves unless board[r][5] == '_' && board[r][6] == '_'
    if !player.in_check && !in_check?(board, player, [r, 5])[0] && !in_check?(board, player, [r, 6])[0]
      moves << [r, 6]
    end
  end

  def queen_castle(board, player)
    r = pos[0]
    moves = []
    moves if board[r][0] == '_' || board[r][0].name[1] != 'R'
    moves unless board[r][1] == '_' && board[r][2] == '_' && board[r][3] == '_'
    if !player.in_check && !in_check?(board, player, [r, 1])[0] && !in_check?(board, player, [r, 2])[0] && !in_check?(board, player, [r, 3])[0]
      moves << [r, 2]
    end
  end
end

def in_check?(board, player, pos)
  if player.name[0] == 'W'
    other_player = Player.new('Black')
  else
    other_player = Player.new('White')
  end
  board.each do |arr|
    arr.each do |piece|
      next if piece == '_'
      next if piece.name[0] == player.name[0]
      return [true, piece.pos] if piece.moves(board, other_player).include?(pos)
    end
  end
  [false, []]
end

def nil_or_friend?(piece, player)
  return false if piece == '_'

  piece.nil? || piece.name[0] == player.name[0]
end

def up(board, player, piece, count)
  r = piece.pos[0] # initial rank of piece
  f = piece.pos[1] # initial file of piece
  moves = []
  i = 1
  until i == count
    i += 1
    r += 1 unless r == 7 # Upper rank
    return moves if nil_or_friend?(board[r][f], player)

    moves << [r, f]
    return moves unless board[r][f] == '_' # stop if position is occupied by enemy
  end
end

chess = Chess.new.fill_board
chess1 = chess.board.map do |array|
  arr = array.map do |element|
    if element.class == String
      element
    else
      element.symbol
    end
  end
  pp arr
end
chess.play
# TODO: Add print board,is player parameter redundant?, is passing rank and file better?, add en passant, promotion
