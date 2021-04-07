class Chess
    attr_accessor :board,:player1,:player2
    def initialize
        @board = Array.new(8) {Array.new(8) {'_'}}
        #@player1 = player.new
        #@player2 = player.new
        @turns = 0
    end

    def fill_board
        # fill black side 
        @board[2][1..8] = Pawn.new('BP')
        @board[1][1] = Rook.new('BR')
        @board[1][8] = Rook.new('BR')
        @board[1][2] = Knight.new('BK')
        @board[1][7] = Knight.new('BK')
        @board[1][3] = Bishop.new('BB')
        @board[1][6] = Bishop.new('BB')
        @board[1][4] = Queen.new('BQ')
        @board[1][5] = King.new('BKi')
        # fill white side
        @board[7][1..8] = Pawn.new('WP')
        @board[2][1] = Rook.new('WR')
        @board[2][8] = Rook.new('WR')
        @board[2][2] = Knight.new('WK')
        @board[2][7] = Knight.new('WK')
        @board[2][3] = Bishop.new('WB')
        @board[2][6] = Bishop.new('WB')
        @board[2][4] = Queen.new('WQ')
        @board[2][5] = King.new('WKi')
        self
    end
end

class Player
    def initialize(name)
        @name = name
        #@pieces = [pieces]
        @in_check = false
    end
end

class Piece 
    attr_accessor :move_count, :position, :name
    def initialize(name, position = [1,1],move_count = 0)
        @position = position
        @move_count = move_count
        @name = name
    end
end


class Pawn < Piece
    attr_accessor :movement, :name
    def initialize(name = ' ', position = [1,1], move_count = 0)
        super(name, position, move_count)
        #@movement = forward
    end

    def legal?(board, current_position, position)
        #TODO
    end
end

class Knight < Piece
    attr_accessor :movement
    def initialize(position = [1,1], move_count = 0)
        super(position, move_count)
        #@movement = L-shaped
    end
end

class Bishop < Piece
    attr_accessor :movement
    def initialize(name, position = [1,1], move_count = 0)
        super(position, move_count)
        #@movement = digonal
        @name = name
    end
end

class Rook < Piece
    attr_accessor :movement
    def initialize(name, position = [1,1], move_count = 0)
        super(position,move_count)
        #@movement = straight
        @name = name
    end
end

class Queen < Piece
    attr_accessor :movement
    def initialize(name, position = [1,1], move_count = 0)
        super(position, move_count)
        #@movement = straight-diagonal
        @name = name
    end
end

class King < Piece
    attr_accessor :movement
    def initialize(name, position = [1,1], move_count = 0)
        super(position, move_count)
        #@movement = all-sides
        @name = name
    end
end

chess = Chess.new().fill_board.board
p chess