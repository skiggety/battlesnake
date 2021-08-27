require 'yaml'
require_relative './game'

## CONFIGURATION
## ======================================
HUNT_ADVANTAGE = 1
## ======================================


# This function is called on every turn of a game. It's how your Battlesnake decides where to move.
# Valid moves are "up", "down", "left", or "right".
# TODO: Use the information in board to decide your next move.
def move(board)
  game = Game.new(board)
  move = game.determine_best_move
  puts "MOVE: " + move
  puts ''
  { "move": move }
end

