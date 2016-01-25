class Integer
  def prime?
    return false if self == 1
    divisor = 2
    square_root_of_number = Math.sqrt(self)
    while divisor <= square_root_of_number
      return false if self % divisor == 0
      divisor += 1
    end
    true
  end
end

class RationalSequence
  include Enumerable

  def initialize(count)
    @count = count
  end

  def each
    row, position = 1, 1
    yielded_numbers_count = 0
    going_upward = false
    while yielded_numbers_count < @count
      numerator, denominator = position, row + 1 - position
      numerator, denominator = denominator, numerator if going_upward
      irreducible = Rational(numerator, denominator)
      if irreducible.numerator == numerator
        yield irreducible
        yielded_numbers_count += 1
      end
      position += 1
      if position > row
        position = 1
        row += 1
        going_upward = !going_upward
      end
    end
  end
end

class PrimeSequence
  include Enumerable

  def initialize(count)
    @count = count
  end

  def each
    yielded_numbers_count = 0
    number = 2
    while yielded_numbers_count < @count
      if number.prime?
        yield number
        yielded_numbers_count += 1
      end
      number += 1
    end
  end
end

class FibonacciSequence
  include Enumerable

  def initialize(count, first: 1, second: 1)
    @count = count
    @first = first
    @second = second
  end

  def each
    current = @first
    following = @second
    yielded_numbers_count = 0
    while yielded_numbers_count < @count
      yield current
      current, following = following, current + following
      yielded_numbers_count += 1
    end
  end
end

module DrunkenMathematician
  module_function

  def meaningless(n)
    first_n_rational_numbers = RationalSequence.new(n)
    two_groups = first_n_rational_numbers.partition do |number|
      number.numerator.prime? || number.denominator.prime?
    end
    two_groups_reduced = two_groups.flat_map { |group| group.reduce(1, :*) }
    two_groups_reduced[0] / two_groups_reduced[1]
  end

  def aimless(n)
    first_n_prime_numbers = PrimeSequence.new(n)
    rational_numbers = []
    first_n_prime_numbers.each_slice(2) do |slice|
      rational_numbers << Rational(slice.fetch(0, 0), slice.fetch(1, 1))
    end
    rational_numbers.reduce(0, :+)
  end

  def worthless(n)
    rational_numbers = RationalSequence.new(Float::INFINITY)
    limit = FibonacciSequence.new(n).to_a.fetch(-1, 0)
    taken_numbers = []
    rational_numbers.take_while do |number|
      taken_numbers << number
      taken_numbers.reduce(0, :+) <= limit
    end
  end
end
