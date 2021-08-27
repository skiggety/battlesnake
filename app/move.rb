require 'yaml'
require 'set'

## CONFIGURATION
## ======================================
HUNT_ADVANTAGE = 1
## ======================================


# This function is called on every turn of a game. It's how your Battlesnake decides where to move.
# Valid moves are "up", "down", "left", or "right".
# TODO: Use the information in board to decide your next move.
def move(board)
  move = calc_move(board)
  puts "MOVE: " + move
  puts ''
  { "move": move }
end

def calc_move(board)
  # puts "board.to_yaml = #{board.to_yaml}"

  # Choose a random direction to move in
  possible_moves = %w[up down left right]

  possible_moves = avoid_walls(possible_moves, board)
  puts "after avoiding walls, possible_moves = #{possible_moves}"
  possible_moves = avoid_snakes(possible_moves, board)
  puts "after avoiding snakes, possible_moves = #{possible_moves}"
  possible_moves = avoid_long_snakes_possible_next_head_position(possible_moves, board)
  puts "after filtering, possible_moves = #{possible_moves}"

  preferred_moves = possible_moves

  preferred_moves = avoid_small_areas(preferred_moves, board)
  puts "after considering area, preferred_moves = #{preferred_moves}"
  preferred_moves = possible_moves if preferred_moves == []
  preferred_moves = head_toward_preferred_target(preferred_moves, board)
  puts "after considering targets, preferred_moves = #{preferred_moves}"

  preferred_moves.sample || possible_moves.sample || 'right'
end

# TODO: TEST/DEBUG
# avoid going into areas you can't easily fit into
def avoid_small_areas(preferred_moves, board)
  preferred_moves.filter{ |move| area_accessible_from_move(move, board) > minimum_needed_area(board) }
end

# TODO: TEST/DEBUG
def area_accessible_from_move(move, board)
  result = area_accessible_from_square(coordinates_for_move(move, my_head(board)), board)
  puts "result is \"#{result}\" ."
  result
end

# TODO: TEST/DEBUG
def area_accessible_from_square(square, board)
  region = Region.new(square)
  last_region = nil

  # add free squares contiguous to our growing region until we can't anymore
  while last_region != region do
    last_region = region

    contiguous_free_squares = region.get_adjacent_free_squares(board)
    region += contiguous_free_squares
  end

  region.size
end

class Region
  # TODO: TEST/DEBUG
  def initialize(first_square)
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
  def is_free?(square, board)
    # TODO: IMPLEMENT
  end

  def size
    @squares.size
  end
end

# TODO: TEST/DEBUG
def coordinates_for_move(move,head)
  case move
  when 'left'
    left_of(head)
  when 'right'
    right_of(head)
  when 'up'
    above(head)
  when 'down'
    below(head)
  end
end

# TODO: TEST/DEBUG
def minimum_needed_area(board)
  board[:you][:length]
end

def head_toward_preferred_target(possible_moves, board)
  preferred_food_move = direction_to_preferred_food(board)
  preferred_enemy_move = direction_to_preferred_enemy(board, HUNT_ADVANTAGE)

  preferred_move = if seek_food?(board)
                     preferred_food_move
                   else
                     preferred_enemy_move || preferred_food_move
                   end

  possible_moves & preferred_move
end

def direction_to_preferred_food(board)
  my_head = board[:you][:head]
  all_food = board[:board][:food]

  return nil if all_food.empty?

  directions_towards(nearest_to(all_food, my_head), my_head)
end

def direction_to_preferred_enemy(board, hunt_advantage)
  my_head = board[:you][:head]
  my_length = board[:you][:length]
  smaller_snake_heads = other_snakes(board).filter{ |s| s[:body].length < (my_length - hunt_advantage) }.map{ |s| s[:head] }
  return nil if smaller_snake_heads.empty?

  directions_towards(nearest_to(smaller_snake_heads, my_head), my_head)
end

def seek_food?(board)
  return false if board[:board][:food].empty?

  my_health = board[:you][:health]

  (my_health < board[:board][:height] || my_health < board[:board][:width]) || i_am_not_the_largest_snake?(board)
end

# TODO: cleanup instances of .length
def i_am_the_largest_snake?(board)
  my_length = board[:you][:body].length

  other_snakes(board).each do |snake|
    return false if snake[:body].length >= my_length
  end

  true
end

def i_am_not_the_largest_snake?(board)
  !i_am_the_largest_snake?(board)
end

def nearest_to(squares, start)
  puts "In nearest_to(squares, start), squares = #{squares}"
  puts "In nearest_to(squares, start), start = #{start}"
  squares.sort_by{ |s| distance(s, start) }[0]
end

def distance(a, b)
  (a[:x] - b[:x]).abs + (a[:y] - b[:y]).abs
end

def directions_towards(target, start)
  result = []
  result << 'left' if target[:x] < start[:x]
  result << 'right' if target[:x] > start[:x]
  result << 'up' if target[:y] > start[:y]
  result << 'down' if target[:y] < start[:y]
  result
end

def avoid_walls(possible_moves, board)
  head = my_head(board)
  # puts "my_head:"
  # puts my_head

  possible_moves.delete('left') if head[:x] == 0
  possible_moves.delete('down') if head[:y] == 0
  possible_moves.delete('right') if head[:x] == max_x(board)
  possible_moves.delete('up') if head[:y] == max_y(board)
  possible_moves
end

def my_head(board)
  board[:you][:head]
end

def max_x(board)
  board[:board][:width] - 1
end

def max_y(board)
  board[:board][:height] - 1
end

def avoid_snakes(possible_moves, board)
  board[:board][:snakes].each do |snake|
    possible_moves = avoid_snake(possible_moves, board[:you][:head], snake)
    puts "in avoid_snakes, after avoiding snake #{snake[:name]}, possible moves are #{possible_moves}"
  end
  possible_moves
end

def avoid_snake(possible_moves, my_head, snake)
  # puts "avoid_snake:"
  # puts "my_head.to_yaml = #{my_head.to_yaml}"
  # puts "snake.to_yaml = #{snake.to_yaml}"

  avoid_squares = snake[:body][0..-2] # Don't avoid the tip of the tail # TODO: unless the snake just ate

  possible_moves.delete('left') if avoid_squares.include? left_of(my_head)
  possible_moves.delete('down') if avoid_squares.include? below(my_head)
  possible_moves.delete('right') if avoid_squares.include? right_of(my_head)
  possible_moves.delete('up') if avoid_squares.include? above(my_head)
  possible_moves
end

def avoid_long_snakes_possible_next_head_position(possible_moves, board)
  my_head = board[:you][:head]
  my_length = board[:you].length
  puts "my_length = #{my_length}"
  # only avoid snakes at least as long as me:
  long_snakes_heads = other_snakes(board).filter{ |s| s[:body].length >= my_length}.map{ |s| s[:head] }
  puts "long_snakes_heads = #{long_snakes_heads}"
  previous_possible_moves = possible_moves

  long_snakes_heads.each do |other_head|
    possible_moves = avoid_square(possible_moves, my_head, left_of(other_head))
    possible_moves = avoid_square(possible_moves, my_head, right_of(other_head))
    possible_moves = avoid_square(possible_moves, my_head, above(other_head))
    possible_moves = avoid_square(possible_moves, my_head, below(other_head))
  end

  possible_moves = previous_possible_moves if possible_moves == []
  possible_moves
end

def other_snakes(board)
  board[:board][:snakes] - [ board[:you] ]
end

def avoid_square(possible_moves, my_head, square)
  possible_moves.delete('left') if square == left_of(my_head)
  possible_moves.delete('down') if square == below(my_head)
  possible_moves.delete('right') if square == right_of(my_head)
  possible_moves.delete('up') if square == above(my_head)
  possible_moves
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

