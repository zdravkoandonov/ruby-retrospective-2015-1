def position_ahead_of_snake(snake, direction, moves = 1)
  [snake[-1][0] + moves * direction[0], snake[-1][1] + moves * direction[1]]
end

def grow(snake, direction)
  snake.dup.push(position_ahead_of_snake(snake, direction))
end

def move(snake, direction)
  snake[1..-1].push(position_ahead_of_snake(snake, direction))
end

def snake?(position, snake)
  snake.include?(position)
end

def in_bounds?(position, dimensions)
  position[0].between?(0, dimensions[:width] - 1) &&
    position[1].between?(0, dimensions[:height] - 1)
end

def obstacle_ahead?(snake, direction, dimensions, moves = 1)
  position = position_ahead_of_snake(snake, direction, moves)
  !in_bounds?(position, dimensions) || snake?(position, snake)
end

def danger?(snake, direction, dimensions)
  obstacles_in_one_move  = obstacle_ahead?(snake, direction, dimensions)
  obstacles_in_two_moves = obstacle_ahead?(snake, direction, dimensions, 2)
  obstacles_in_one_move || obstacles_in_two_moves
end

def new_food(food, snake, dimensions)
  valid_positions_x = (0...dimensions[:width]).to_a
  valid_positions_y = (0...dimensions[:height]).to_a
  valid_positions = valid_positions_x.product(valid_positions_y)
  vacant_positions = valid_positions - food - snake
  vacant_positions.sample
end
