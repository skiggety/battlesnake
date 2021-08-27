class Grid
  attr_accessor :grid

  def initialize(height, width)
    @grid = Array.new(width) { Array.new(height, 0) }
  end

  def draw_snake(s)
    s.body.each_with_index do |b, i|
      grid[b.x][b.y] = i == (s.body.length - 1) ? 't' : 'b'
    end
    grid[s.head.x][s.head.y] = 'h'
  end

  def draw_food(f)
    grid[f.x][f.y] = 'f'
  end

  def empty?(x,y)
    grid[x]&.[](y) == 0 || grid[x]&.[](y) == 'f'
  end
end