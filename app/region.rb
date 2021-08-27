require 'set'

class Region
  attr_accessor :grid

  # TODO: TEST/DEBUG
  def initialize(first_square, grid)
    @grid = grid
    @squares = SortedSet[first_square]
  end

  # TODO: TEST/DEBUG
  def get_adjacent_free_squares(board)
    new_squares = SortedSet[]
    @squares.each do |square|
      filtered = get_all_adjacent(square).filter{ |square| is_free?(square, board) }
      new_squares += SortedSet.new(filtered)
    end
    new_squares
  end

  # TODO: TEST/DEBUG
  def + (new_squares)
    @squares + new_squares
    self
  end

  # TODO: TEST/DEBUG
  def !=(another_region)
    ! self == another_region
  end

  # TODO: TEST/DEBUG
  def ==(another_region)
    region.squares == another_region.squares
  end

  attr_accessor :squares

  # TODO: TEST/DEBUG
  def get_all_adjacent(square)
    [left_of(square), right_of(square), above(square), below(square)].to_set
  end

  # TODO: TEST/DEBUG
  def is_free?(square)
    grid.empty?(square[:x], square[:y])
  end

  def size
    @squares.size
  end

  def left_of(square)
    { x: square[:x] - 1, y: square[:y] }
  end

  def right_of(square)
    { x: square[:x] + 1, y: square[:y] }
  end

  def below(square)
    { x: square[:x], y: square[:y] - 1 }
  end

  def above(square)
    { x: square[:x], y: square[:y] + 1 }
  end
end
