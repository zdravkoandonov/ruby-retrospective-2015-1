def snake_head(snake)
  snake.last
end

def position_ahead_of_snake(head, direction, moves = 1)
  head_x, head_y = head
  direction_x, direction_y = direction

  [head_x + moves * direction_x, head_y + moves * direction_y]
end

def grow(snake, direction)
  snake + [position_ahead_of_snake(snake_head(snake), direction)]
end

def move(snake, direction)
  snake[1..-1].push(position_ahead_of_snake(snake_head(snake), direction))
end

def snake?(position, snake)
  snake.include?(position)
end

def in_bounds?(position, dimensions)
  position[0].between?(0, dimensions[:width] - 1) &&
    position[1].between?(0, dimensions[:height] - 1)
end

def obstacle_ahead?(snake, direction, dimensions, moves = 1)
  position = position_ahead_of_snake(snake_head(snake), direction, moves)
  (not in_bounds?(position, dimensions)) || snake?(position, snake)
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
