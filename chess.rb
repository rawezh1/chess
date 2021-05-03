# frozen_string_literal: true

require 'pry'
# Adds a method to determine if a string is integer or not to String class
class String
  def i?
    /\A[-+]?\d+\z/ === self
  end
end

# Creates a chess board and two players
class Chess
  attr_accessor :board, :player1, :player2

  # Chess game starts with a borad, two players, and number of turns.
  def initialize
    @board = Array.new(8) { Array.new(8) { '_' } }
    @player1 = Player.new('White')
    @player2 = Player.new('Black')
    @turns = 0
  end

  # Fills the chess board with pieces.
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

  # Starts the game, with the two players turns and checking if the game is over or not.
  def play
    loop do
      turn(@player1)
      print_board
      if game_over?(@board, @player2) then return puts 'Game over' end

      turn(@player2)
      print_board
      if game_over?(@board, @player1) then return puts 'Game over' end
    end
  end

  # One players turn, takes in a piece and a move and apply the move to the piece.
  def turn(player)
    p "It is #{player.name} players turn, please select a piece by typing its row and column"
    from_pos = self.from_pos(player)
    to_pos = self.to_pos(player, from_pos)
    apply_move(from_pos, to_pos, player)
  end

  # Selects a piece by taking its position from the player
  def from_pos(player)
    loop do
      choice = gets.chomp.split('') # Prompt the player to choose
      if invalid_choice?(choice, player) then next end # If the choice is invalid, ask again

      return choice.map(&:to_i) # convert the string given by player to integer
    end
  end

  # Checks if the player has entered a correct value
  def invalid_choice?(choice, player)
    # If more than two values is given or if they are not integers then get values again
    if choice.length != 2 || !choice[0].i? || !choice[1].i?
      puts 'Invalid input, please type a correct value'
      return true
    end
    choice = choice.map(&:to_i) # convert string to integer
    if !choice[0].between?(0, 7) || !choice[1].between?(0, 7) # If the choice is out of bound then it is invalid
      puts 'Invalid input, please type a correct value'
      true
    elsif @board[choice[0]][choice[1]] == '_' # If the position is empty then invalid
      puts 'Invalid input, please type a correct value'
      true
    elsif @board[choice[0]][choice[1]].name[0] != player.name[0] # If the piece does not belong to current player then invalid
      puts 'Invalid input, please type a correct value'
      true
    elsif @board[choice[0]][choice[1]].moves(@board, player).empty? # If piece has no legal moves then invalid
      puts 'Invalid input, please type a correct value'
      true
    else # Else it is a valid choice
      false
    end
  end

  # Selects a position to move the piece to by getting player input
  def to_pos(player, init_pos)
    p 'Please select a position to move the piece to by typing its row and column'
    original_piece = @board[init_pos[0]][init_pos[1]]
    loop do
      choice = gets.chomp.split('')
      next if invalid_move?(choice, player, init_pos)

      @board[init_pos[0]][init_pos[1]] = original_piece
      return choice.map(&:to_i)
    end
  end

  # Checks if the move given by player is invalid
  def invalid_move?(choice, player, init_pos)
    if choice.length != 2 || !choice[0].i? || !choice[1].i? # checks input form (same as invalid_choice)
      puts 'Invalid input, please type a correct value'
      return true
    end
    choice = choice.map(&:to_i)
    if !choice[0].between?(0, 7) || !choice[1].between?(0, 7)
      puts 'Invalid input, please type a correct value'
      true
    elsif !possible_move?(choice, init_pos, player) # Checks if move legal or not
      puts 'Invalid input, please type a correct value'
      true
    end
  end

  # Checks for possibility of moving the piece to the given location.
  def possible_move?(final_pos, init_pos, player)
    possible_moves = @board[init_pos[0]][init_pos[1]].moves(@board, player)
    # If piece can't move there then invalid
    return false unless possible_moves.include?(final_pos)
    # If player is in check and the move can't remove check then invalid
    return false if player.in_check && !removes_check?(final_pos, init_pos, player)
    # If the move puts the player in check then invalid
    return false if puts_incheck?(init_pos, player)[0]

    true
  end

  # Checks if the move removes check from player
  def removes_check?(final_pos, init_pos, player)
    king = player.name[0] == 'W' ? 'WKi' : 'BKi' # Gets king name to use for king position
    king_pos = pos_of(king) # Gets king position
    # Checks if the king moves out of check if the selected piece is king
    return !in_check?(@board, player, final_pos) if king_pos == init_pos

    king = @board[king_pos[0]][king_pos[1]]
    return true if king.checker.nil? # Check if king is in check

    # Checks if move falls between king and the piece checking the king
    if final_pos[0] == king_pos[0] && final_pos[0] == king.checker.pos[0] # King and checker on same rank
      between_rank?(final_pos, king)
    elsif final_pos[1] == king_pos[1] && final_pos[1] == king.checker.pos[1] # King and checker on same file
      between_file?(final_pos, king)
    elsif same_diagonal?(final_pos, king_pos) # King and piece and checker on same diagonal
      if same_diagonal?(king_pos, king.checker.pos)
        in_between?(final_pos, king)
      else
        false
      end
    end
  end

  def pos_of(piece_name)
    # returns the rank and file of a piece if found, empty array otherwise
    @board.each_with_index do |arr, r|
      arr.each_with_index do |cell, f|
        next if cell == '_'
        return [r, f] if cell.name == piece_name
      end
    end
    []
  end

  # Checks if two squares are on same diagonal
  def same_diagonal?(point1, point2)
    point2[1] - point1[1] == point2[0] - point1[0] || point2[1] - point1[1] == point1[0] - point2[0]
  end

  # Checks if square is between the king and checker in same rank
  def between_rank?(final_pos, king)
    if (king.pos[0] - king.checker.pos[0]).negative?
      final_pos[0].between?(king.pos[0], king.checker.pos[0])
    else
      final_pos[0].between?(king.checker.pos[0], king.pos[0])
    end
  end

  # Checks if square is between the king and checker in same file
  def between_file?(final_pos, king)
    if (king.pos[1] - king.checker.pos[1]).negative?
      final_pos[1].between?(king.pos[1], king.checker.pos[1])
    else
      final_pos[1].between?(king.checker.pos[1], king.pos[1])
    end
  end

  # Checks if square is between the king and checker in same diagonal
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

  # Checks if move puts king in check by creating a new board and
  # setting the current position of piece to empty and
  # seeing if king in new board is in check
  def puts_incheck?(init_pos, player)
    new_board = @board
    new_board[init_pos[0]][init_pos[1]] = '_'
    in_check?(new_board, player, pos_of("#{player.name[0]}Ki"))
  end

  # Applies the move given by player
  def apply_move(init_pos, final_pos, player)
    # Sets the position variable of the piece to the final position
    @board[init_pos[0]][init_pos[1]].pos = [final_pos[0], final_pos[1]]
    # Moves the piece to given square
    @board[final_pos[0]][final_pos[1]] = @board[init_pos[0]][init_pos[1]]
    # Sets the original position of the piece to empty
    @board[init_pos[0]][init_pos[1]] = '_'
    # Checks if the move puts opposite player in check
    oppos_player = player.name[0] == 'W' ? player2 : player1
    king_pos = pos_of("#{oppos_player.name[0]}Ki")
    in_check = in_check?(@board, oppos_player, king_pos)
    return unless in_check[0]

    # Set checker variable of opposite king to checking piece
    @board[king_pos[0]][king_pos[1]].checker = @board[in_check[1][0]][in_check[1][1]]
    oppos_player.in_check = true # Set in_check variable for opposite player to true
    puts 'Check'
  end

  def game_over?(board, player)
    if no_legal_moves?(board, player)
      if player.in_check
        puts "Checkmate! #{player.name} player lost!"
      else
        puts 'Stalemate'
      end
      return true
    end
    false
  end

  # Checks if there are any legal moves for player
  def no_legal_moves?(board, player)
    board.each do |arr|
      arr.each do |piece|
        next if piece == '_' || piece.name[0] != player.name[0]

        return false unless legal_moves(piece, board, player).empty?
      end
    end
    true
  end

  def legal_moves(piece, board, player)
    moves = piece.moves(board, player)
    return [] if moves.empty?

    moves.select { |move| removes_check?(move, piece.pos, player) }
  end

  def print_board
    @board.map do |array|
      arr = array.map do |element|
        if element == '_'
          element
        else
          element.symbol
        end
      end
      pp arr
    end
  end
end

# Plyaer is a player with a name (white or black) and whether or not the player is in check
class Player
  attr_accessor :name, :in_check

  def initialize(name)
    @name = name
    @in_check = false
  end
end

# Parent class of chess pieces with a name (name of piece and white or black), a symbol
# a position on board, and number of moves it has moved so far
class Piece
  attr_accessor :move_count, :pos, :name, :symbol

  def initialize(name, symbol, pos = [1, 1], move_count = 0)
    @pos = pos
    @move_count = move_count
    @name = name
    @symbol = symbol
  end
end

# A pawn piece with forward moves and diagonal captures (also counted as possible moves)
class Pawn < Piece
  def initialize(name, symbol, pos = [1, 1], move_count = 0)
    super(name, symbol, pos, move_count)
  end

  def moves(board, player)
    if @name[0] == 'W' # checks if the pawn is white or black
      white_moves(board, player)
    else
      black_moves(board, player)
    end
  end

  # Legal moves for a black pawn
  def black_moves(board, player)
    moves = []
    # Two sqaure move if first move
    moves << [pos[0] + 2, pos[1]] if @move_count.zero? && board[pos[0] + 2][pos[1]] == '_'
    # One move forward
    moves << [pos[0] + 1, pos[1]] if board[pos[0] + 1][pos[1]] == '_'
    # Diagonal captre moves
    unless board[pos[0] + 1][pos[1] + 1] == '_' || nil_or_friend?(board[pos[0] + 1][pos[1] + 1], player)
      moves << [pos[0] + 1, pos[1] + 1]
    end
    unless board[pos[0] + 1][pos[1] - 1] == '_' || nil_or_friend?(board[pos[0] + 1][pos[1] - 1], player)
      moves << [pos[0] + 1, pos[1] - 1]
    end
    moves
  end

  def white_moves(board, player)
    moves = []
    # Two sqaure move if first move
    moves << [pos[0] - 2, pos[1]] if @move_count.zero? && board[pos[0] - 2][pos[1]] == '_'
    # One move forward
    moves << [pos[0] - 1, pos[1]] if board[pos[0] - 1][pos[1]] == '_'
    # Diagonal captre moves
    unless board[pos[0] - 1][pos[1] + 1] == '_' || nil_or_friend?(board[pos[0] - 1][pos[1] + 1], player)
      moves << [pos[0] - 1, pos[1] + 1]
    end
    unless board[pos[0] - 1][pos[1] - 1] == '_' || nil_or_friend?(board[pos[0] - 1][pos[1] - 1], player)
      moves << [pos[0] - 1, pos[1] - 1]
    end
    moves
  end
end

# A knight piece with L shaped moves
class Knight < Piece
  def initialize(name, symbol, pos = [1, 1], move_count = 0)
    super(name, symbol, pos, move_count)
  end

  def moves(board, player)
    topside(board, player) + bottomside(board, player) + leftside(board, player) + rightside(board, player)
  end

  def bottomside(board, player)
    moves = []
    r = pos[0]
    f = pos[1]
    moves << [r + 2, f - 1] if r <= 5 && f >= 1 && !nil_or_friend?(board[r + 2][f - 1], player)
    moves << [r + 2, f + 1] if r <= 5 && f <= 6 && !nil_or_friend?(board[r + 2][f + 1], player)
    moves
  end

  def topside(board, player)
    moves = []
    r = pos[0]
    f = pos[1]
    moves << [r - 2, f - 1] if r >= 2 && f >= 1 && !nil_or_friend?(board[r - 2][f - 1], player) 
    moves << [r - 2, f + 1] if r >= 2 && f <= 6 && nil_or_friend?(board[r - 2][f + 1], player)
    moves
  end

  def rightside(board, player)
    moves = []
    r = pos[0]
    f = pos[1]
    moves << [r + 1, f + 2] if r <= 6 && f <= 5 && !nil_or_friend?(board[r + 1][f + 2], player)
    moves << [r - 1, f + 2] if r >= 1 && f <= 5 && !nil_or_friend?(board[r - 1][f + 2], player)
    moves
  end

  def leftside(board, player)
    moves = []
    r = pos[0]
    f = pos[1]
    moves << [r + 1, f - 2] if r <= 6 && f >= 2 && !nil_or_friend?(board[r + 1][f - 2], player)
    moves << [r - 1, f - 2] if r >= 1 && f <= 2 && !nil_or_friend?(board[r - 1][f - 2], player)
    moves
  end
end

# A bishop piece with diagonal moves
class Bishop < Piece
  def initialize(name, symbol, pos = [1, 1], move_count = 0)
    super(name, symbol, pos, move_count)
  end

  def moves(board, player)
    north = ne_diag(board, player, self, 7) + nw_diag(board, player, self, 7)
    north + se_diag(board, player, self, 7) + sw_diag(board, player, self, 7)
  end
end

# A rook piece with straight moves
class Rook < Piece
  def initialize(name, symbol, pos = [1, 1], move_count = 0)
    super(name, symbol, pos, move_count)
  end

  def moves(board, player)
    up(board, player, self, 7) + down(board, player, self, 7) + left(board, player, self, 7) + right(board, player, self, 7)
  end
end

# A queen piece with diagonal and straight moves
class Queen < Piece
  def initialize(name, symbol, pos = [1, 1], move_count = 0)
    super(name, symbol, pos, move_count)
  end

  def moves(board, player)
    diagonal_moves(board, player) + straight_moves(board, player)
  end

  def straight_moves(board, player)
    up(board, player, self, 7) + down(board, player, self, 7) + left(board, player, self, 7) + right(board, player, self, 7)
  end

  def diagonal_moves(board, player)
    north = ne_diag(board, player, self, 7) + nw_diag(board, player, self, 7)
    north + se_diag(board, player, self, 7) + sw_diag(board, player, self, 7)
  end
end

# A king piece with a checker (a piece checking it) and one move to all sides plus castling
class King < Piece
  attr_accessor :checker

  def initialize(name, symbol = '', pos = [1, 1], move_count = 0)
    super(name, symbol, pos, move_count)
    @checker = nil
  end

  def moves(board, player)
    one_moves(board, player) + castling_moves(board, player)
  end

  def one_moves(board, player)
    diagonal_moves(board, player) + straight_moves(board, player)
  end

  def straight_moves(board, player)
    up(board, player, self, 1) + down(board, player, self, 1) + left(board, player, self, 1) + right(board, player, self, 1)
  end

  def diagonal_moves(board, player)
    ne_diag(board, player, self, 1) + nw_diag(board, player, self, 1) + se_diag(board, player, self, 1) + sw_diag(board, player, self, 1)
  end

  def castling_moves(board, player)
    return [] if board[pos[0]][pos[1]].move_count != 0

    king_castle(board, player) + queen_castle(board, player)
  end

  # Checks if king side castle is possible and returns it if so
  def king_castle(board, player)
    r = pos[0]
    moves = []
    return moves if board[r][7] == '_' || board[r][7].name[1] != 'R'
    return moves unless board[r][5] == '_' && board[r][6] == '_'

    if !player.in_check && !in_check?(board, player, [r, 5])[0] && !in_check?(board, player, [r, 6])[0]
      moves << [r, 6]
    end
  end

  # Checks if queen side castle is possible and returns it if so
  def queen_castle(board, player)
    r = pos[0]
    moves = []
    return moves if board[r][0] == '_' || board[r][0].name[1] != 'R'
    return moves unless board[r][1] == '_' && board[r][2] == '_' && board[r][3] == '_'

    if !player.in_check && !in_check?(board, player, [r, 1])[0] && !in_check?(board, player, [r, 2])[0] && !in_check?(board, player, [r, 3])[0]
      moves << [r, 2]
    end
  end
end

# Chechks if a square on the board is in check by checking opposite pieces moves
def in_check?(board, player, pos)
  if player.name[0] == 'W'
    other_player = Player.new('Black')
  else
    other_player = Player.new('White')
  end
  # retrun true and the checking piece if it is possible for an enemy piece to attack a sqaure
  board.each do |arr|
    arr.each do |piece|
      next if piece == '_'
      next if piece.name[0] == player.name[0]
      next if piece.name[2] == 'i'
      return [true, piece.pos] if piece.moves(board, other_player).include?(pos)
    end
  end
  [false, []]
end

# Check if square is out of bounds or contains a friend
def nil_or_friend?(piece, player)
  return false if piece == '_'

  piece.nil? || piece.name[0] == player.name[0]
end

# Up left diagonal moves up to a certain count (for example , 1 for king and 7 for bishop)
def nw_diag(board, player, piece, count)
  r = piece.pos[0] # initial rank of piece
  f = piece.pos[1] # initial file of piece
  moves = []
  1.upto(count) do
    r.zero? || f.zero? ? break : r -= 1; f -= 1

    return moves if nil_or_friend?(board[r][f], player)

    moves << [r, f]
    return moves unless board[r][f] == '_'
  end
  moves
end

# Up right diagonal moves up to a certain count
def ne_diag(board, player, piece, count)
  r = piece.pos[0] # initial rank of piece
  f = piece.pos[1] # initial file of piece
  moves = []
  1.upto(count) do
    r.zero? || f == 7 ? break : r -= 1; f += 1

    return moves if nil_or_friend?(board[r][f], player)

    moves << [r, f]
    return moves unless board[r][f] == '_'
  end
  moves
end

# Down left diagonal moves up to a certain count
def sw_diag(board, player, piece, count)
  r = piece.pos[0] # initial rank of piece
  f = piece.pos[1] # initial file of piece
  moves = []
  1.upto(count) do
    r == 7 || f.zero? ? break : r += 1; f -= 1

    return moves if nil_or_friend?(board[r][f], player)

    moves << [r, f]
    return moves unless board[r][f] == '_'
  end
  moves
end

# Down right diagonal moves up to a certain count
def se_diag(board, player, piece, count)
  r = piece.pos[0] # initial rank of piece
  f = piece.pos[1] # initial file of piece
  moves = []
  1.upto(count) do
    r == 7 || f == 7 ? break : r += 1; f += 1

    return moves if nil_or_friend?(board[r][f], player)

    moves << [r, f]
    return moves unless board[r][f] == '_'
  end
  moves
end

# Straight up moves
def up(board, player, piece, count)
  r = piece.pos[0] # initial rank of piece
  f = piece.pos[1] # initial file of piece
  moves = []
  1.upto(count) do
    r.zero? ? break : r -= 1

    return moves if nil_or_friend?(board[r][f], player)

    moves << [r, f]
    return moves unless board[r][f] == '_' # stop if position is occupied by enemy
  end
  moves
end

# Straight down moves
def down(board, player, piece, count)
  r = piece.pos[0] # initial rank of piece
  f = piece.pos[1] # initial file of piece
  moves = []
  1.upto(count) do
    r == 7 ? break : r += 1

    return moves if nil_or_friend?(board[r][f], player)

    moves << [r, f]
    return moves unless board[r][f] == '_'
  end
  moves
end

# Straight left moves
def left(board, player, piece, count)
  r = piece.pos[0] # initial rank of piece
  f = piece.pos[1] # initial file of piece
  moves = []
  1.upto(count) do
    f == 7 ? break : f += 1

    return moves if nil_or_friend?(board[r][f], player)

    moves << [r, f]
    return moves unless board[r][f] == '_'
  end
  moves
end

# Straight right moves
def right(board, player, piece, count)
  r = piece.pos[0] # initial rank of piece
  f = piece.pos[1] # initial file of piece
  moves = []
  1.upto(count) do
    f.zero? ? break : f -= 1

    return moves if nil_or_friend?(board[r][f], player)

    moves << [r, f]
    return moves unless board[r][f] == '_'
  end
  moves
end

chess = Chess.new.fill_board
chess.print_board
chess.play
# TODO: Update check condition after a move removes check,add save system,
# TODO: Is player parameter redundant?, is passing rank and file better?,
# TODO: Add en passant, promotion, Refactor methods and classes
