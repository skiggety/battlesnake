class Location
  attr_accessor :x, :y

  def initialize(location_data)
    @x = location_data[:x]
    @y = location_data[:y]
  end

  def up
    [x, y + 1]
  end

  def down
    [x, y - 1]
  end

  def left
    [x - 1, y]
  end

  def right
    [x + 1, y]
  end
end