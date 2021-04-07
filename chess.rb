class Chess
    attr_accessor :board,:player1,:player2
    def initialize
        @board = Array.new(8) {Array.new(8) {'_'}}
        #@player1 = player.new
        #@player2 = player.new
        @turns = 0
    end
end

class Player
    def initialize(name)
        @name = name
        @pieces = [pieces]
        @in_check = false
    end
end

class Piece 
    attr_accessor :move_count, :position
    def initialize(position = [1,1],move_count = 0)
        @position = position
        @move_count = move_count
    end
end

class Rook < Piece
    attr_accessor :movement
    def initialize(position = [1,1], move_count = 0)
        super(position,move_count)
        #@movement = line
    end
end

class Pawn < Piece
    attr_accessor :movement
    def initialize(position = [1,1], move_count = 0)
        super(position, move_count)
        #@movement = forward
    end
end


chess = Chess.new().board
chess[1][2] = 'S'
p chess