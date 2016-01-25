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
    primeish, non_primeish = RationalSequence.new(n).partition do |number|
      number.numerator.prime? || number.denominator.prime?
    end
    primeish.reduce(1, :*) / non_primeish.reduce(1, :*)
  end

  def aimless(n)
    addends = PrimeSequence.new(n).each_slice(2).map do |numerator, denominator|
      Rational(numerator, denominator || 1)
    end
    addends.reduce(0, :+)
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
