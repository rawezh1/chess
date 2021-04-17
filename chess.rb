# frozen_string_literal: true

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
    @board[1] = Array.new(8).fill { |i| Pawn.new('BP', [1, i]) }
    @board[0][0] = Rook.new('BR', [0, 0])
    @board[0][7] = Rook.new('BR', [0, 7])
    @board[0][1] = Knight.new('BK', [0, 1])
    @board[0][6] = Knight.new('BK', [0, 6])
    @board[0][2] = Bishop.new('BB', [0, 2])
    @board[0][5] = Bishop.new('BB', [0, 5])
    @board[0][3] = Queen.new('BQ', [0, 3])
    @board[0][4] = King.new('BKi', [0, 4])
    # fill white side
    @board[6] = Array.new(8).fill { |i| Pawn.new('WP', [6, i]) }
    @board[7][0] = Rook.new('WR', [7, 0])
    @board[7][7] = Rook.new('WR', [7, 7])
    @board[7][1] = Knight.new('WK', [7, 1])
    @board[7][6] = Knight.new('WK', [7, 6])
    @board[7][2] = Bishop.new('WB', [7, 2])
    @board[7][5] = Bishop.new('WB', [7, 5])
    @board[7][3] = Queen.new('WQ', [7, 3])
    @board[7][4] = King.new('WKi', [7, 4])
    self
  end

  def play
    # until self.finished?
    self.turn(player1)
    # black player turn
    # end
  end

  def turn(player)
    p "It is #{player.name} players turn, please select a piece by typing its row and column"
    from_pos = self.from_pos(player)
    to_pos = self.to_pos(player,from_pos)
  end

  def from_pos(player)
    loop do
      choice = gets.chomp.split('')
      if invalid_choice?(choice, player) then next end

      return choice.map(&:to_i)
    end
  end

  def invalid_choice?(choice, player)
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
    else
      false
    end
  end

  def to_pos(player, init_pos)
    loop do
      choice = gets.chomp.split('')
      if invalid_move?(choice, player.name[0], init_pos) then next end

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

  def possible_move?(final_pos,init_pos, player)
    possible_moves = @board[init_pos[0]][init_pos[1]].moves(@board)
    unless possible_moves.include?(final_pos) then return false end
    if player.in_check && removes_check?(final_pos, player) then return true end
    if player.in_check then return false end
    if puts_incheck?(final_pos, player) then return false end
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
  attr_accessor :move_count, :pos, :name

  def initialize(name, pos = [1, 1], move_count = 0)
    @pos = pos
    @move_count = move_count
    @name = name
  end
end

class Pawn < Piece
  attr_accessor :movement, :name

  def initialize(name = ' ', pos = [1, 1], move_count = 0)
    super(name, pos, move_count)
  end

  def moves(board)
    if @name[0] == 'W'
      moves = self.black_moves(board)
    else
      moves = self.white_moves(board)
    end
  end

  def black_moves(board)
    moves = []
    moves << [pos[0] + 2, pos[1]] if @move_count.zero? && board[pos[0] + 2][pos[1]] == '_'
    moves << [pos[0] + 1, pos[1]] if board[pos[0] + 1][pos[1]] == '_'
    moves << [pos[0] + 1, pos[1] + 1] unless board[pos[0] + 1][pos[1] + 1] == '_' || board[pos[0] + 1][pos[1] + 1].nil?
    moves << [pos[0] + 1, pos[1] - 1] unless board[pos[0] + 1][pos[1] - 1] == '_' || board[pos[0] + 1][pos[1] - 1].nil?
    moves
  end

  def white_moves(board)
    moves = []
    moves << [pos[0] - 2, pos[1]] if @move_count.zero? && board[pos[0] - 2][pos[1]] == '_'
    moves << [pos[0] - 1, pos[1]] if board[pos[0] + 1][pos[1]] == '_'
    moves << [pos[0] - 1, pos[1] + 1] unless board[pos[0] - 1][pos[1] + 1] == '_' || board[pos[0] - 1][pos[1] + 1].nil?
    moves << [pos[0] - 1, pos[1] - 1] unless board[pos[0] - 1][pos[1] - 1] == '_' || board[pos[0] - 1][pos[1] - 1].nil?
    moves
  end
end

class Knight < Piece
  attr_accessor :movement

  def initialize(name, pos = [1, 1], move_count = 0)
    super(name, pos, move_count)
  end
end

class Bishop < Piece
  attr_accessor :movement

  def initialize(name, pos = [1, 1], move_count = 0)
    super(name, pos, move_count)
  end
end

class Rook < Piece
  attr_accessor :movement

  def initialize(name, pos = [1, 1], move_count = 0)
    super(name, pos, move_count)
  end
end

class Queen < Piece
  attr_accessor :movement

  def initialize(name, pos = [1, 1], move_count = 0)
    super(name, pos, move_count)
  end
end

class King < Piece
  attr_accessor :movement, :checker

  def initialize(name, pos = [1, 1], move_count = 0)
    super(name, pos, move_count)
    @checker = nil
  end
end

chess = Chess.new.fill_board
chess1 = chess.board.map do |array|
  array.map do |element|
    if element.class == String
      element
    else
      element.name
    end
  end
end
p chess1
chess.play
