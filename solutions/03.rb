class Integer
  def prime?
    return false if self == 1
    2.upto(self**0.5).all? { |divisor| self % divisor != 0}
  end
end

class RationalSequence
  include Enumerable

  def initialize(count)
    @count = count
  end

  def each(&block)
    pairs_by_row = 1.upto(Float::INFINITY).lazy.map do |row|
      if row % 2 == 0
        (1..row).to_a.reverse.zip((1..row).to_a)
      else
        (1..row).to_a.zip((1..row).to_a.reverse)
      end
    end
    pairs_by_row.
      flat_map { |pair| pair }.
      select { |numerator, denominator| numerator.gcd(denominator) == 1 }.
      map { |numerator, denominator| Rational(numerator, denominator) }.
      take(@count).
      each(&block)
  end
end

class PrimeSequence
  include Enumerable

  def initialize(count)
    @count = count
  end

  def each(&block)
    1.upto(Float::INFINITY).lazy.select(&:prime?).take(@count).each(&block)
  end
end

class FibonacciSequence
  include Enumerable

  def initialize(count, first: 1, second: 1)
    @count = count
    @first = first
    @second = second
  end

  def each(&block)
    enum_for(:all_numbers).lazy.take(@count).each(&block)
  end

  private

  def all_numbers
    current = @first
    following = @second

    loop do
      yield current
      current, following = following, current + following
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
    limit = FibonacciSequence.new(n).to_a.fetch(-1, 0)

    sum = 0
    RationalSequence.new(limit**2).take_while do |number|
      sum += number
      sum <= limit
    end
  end
end
