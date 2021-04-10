class String
    def is_i?
       /\A[-+]?\d+\z/ === self
    end
end

class Chess
    attr_accessor :board,:player1,:player2
    def initialize
        @board = Array.new(8) {Array.new(8) {'_'}}
        @player1 = Player.new('White')
        @player2 = Player.new('Black')
        @turns = 0
    end

    def fill_board
        # fill black side
        @board[1] = Array.new(8){Pawn.new('BP')}
        @board[0][0] = Rook.new('BR')
        @board[0][7] = Rook.new('BR')
        @board[0][1] = Knight.new('BK')
        @board[0][6] = Knight.new('BK')
        @board[0][2] = Bishop.new('BB')
        @board[0][5] = Bishop.new('BB')
        @board[0][3] = Queen.new('BQ')
        @board[0][4] = King.new('BKi')
        # fill white side
        @board[6] = Array.new(8){Pawn.new('WP')}
        @board[7][0] = Rook.new('WR')
        @board[7][7] = Rook.new('WR')
        @board[7][1] = Knight.new('WK')
        @board[7][6] = Knight.new('WK')
        @board[7][2] = Bishop.new('WB')
        @board[7][5] = Bishop.new('WB')
        @board[7][3] = Queen.new('WQ')
        @board[7][4] = King.new('WKi')
        self
    end

    def play
        #until self.finished?
          self.turn(player1)
          #black player turn
        #end
    end

    def turn(player)
        p "It is #{player.name} players turn, please select a piece by typing its position"
        choice = self.choose(player)
    end

    def choose(player)
        loop do
            choice = gets.chomp.split('')
            if invalid_choice?(choice,player.name[0]) then next end
            choice = choice.map(&:to_i)
            p choice
            break
        end
    end

    def invalid_choice?(choice,p_letter)
        if choice.length != 2 || !(choice[0].is_i?) || !(choice[1].is_i?) 
            puts 'Invalid input, please type a correct value'
            true
        elsif [choice.map(&:to_i)[0]][choice.map(&:to_i)[1]].nil?
            puts 'Invalid input, please type a correct value'
            true
        elsif @board[choice.map(&:to_i)[0]][choice.map(&:to_i)[1]].name[0] != p_letter
            puts 'Invalid input, please type a correct value'
            true
        else
            false
        end
    end
end

class Player
    attr_accessor :name, :in_check
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

chess = Chess.new().fill_board
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