class Card
  attr_reader :rank, :suit

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def ==(other)
    @rank == other.rank && @suit == other.suit
  end

  def to_s
    "#{@rank.to_s.capitalize} of #{@suit.to_s.capitalize}"
  end
end

class Deck
  include Enumerable

  def suits
    [:spades, :hearts, :diamonds, :clubs].freeze
  end

  def ranks
    [:ace, :king, :queen, :jack, *(10.downto(2))].freeze
  end

  def all_possible_cards
    suits.product(ranks).map { |suit, rank| Card.new(rank, suit) }.freeze
  end

  def initialize(cards)
    @cards = cards
  end

  def each
    @cards.each { |card| yield card }
  end

  def size
    @cards.size
  end

  def draw_top_card
    @cards.shift
  end

  def draw_bottom_card
    @cards.pop
  end

  def top_card
    @cards.first
  end

  def bottom_card
    @cards.last
  end

  def shuffle
    @cards.shuffle!
  end

  def sort
    @cards.sort_by! { |card| [suits.index(card.suit), ranks.index(card.rank)] }
  end

  def to_s
    @cards.map(&:to_s).join("\n")
  end

  class Hand
    def initialize(cards)
      @cards = cards
    end

    def size
      @cards.size
    end
  end
end

class WarDeck < Deck
  def initialize(cards = all_possible_cards.dup)
    super(cards)
  end

  class WarHand < Hand
    def initialize(cards)
      super
    end

    def play_card
      @cards.shift
    end

    def allow_face_up?
      size <= 3
    end
  end

  def deal
    WarHand.new(@cards.shift(26))
  end
end

class BeloteDeck < Deck
  def ranks
    [:ace, 10, :king, :queen, :jack, 9, 8, 7].freeze
  end

  def initialize(cards = all_possible_cards.dup)
    super
  end

  class BeloteHand < Hand
    def highest_of_suit(suit)
      BeloteDeck.new(@cards.select { |card| card.suit == suit }).sort.first
    end

    def belote?
      @cards.select { |card| card.rank == :king || card.rank == :queen }.
        group_by { |card| card.suit }.
        any? { |_, same_suit_cards| same_suit_cards.size == 2 }
    end

    def contains_consecutive?(cards, consecutive_count)
      ranks = BeloteDeck.new.ranks
      cards.each_cons(consecutive_count).any? do |consecutive_cards|
        cards_ranks = consecutive_cards.collect { |card| card.rank }
        rank_index = ranks.index(cards_ranks.first)
        ranks[rank_index...(rank_index + consecutive_count)] == cards_ranks
      end
    end

    def tierce?
      BeloteDeck.new(@cards).sort.to_a.group_by { |card| card.suit }.
        any? { |_, same_suit_cards| contains_consecutive?(same_suit_cards, 3) }
    end

    def quarte?
      BeloteDeck.new(@cards).sort.to_a.group_by { |card| card.suit }.
        any? { |_, same_suit_cards| contains_consecutive?(same_suit_cards, 4) }
    end

    def quint?
      BeloteDeck.new(@cards).sort.to_a.group_by { |card| card.suit }.
        any? { |_, same_suit_cards| contains_consecutive?(same_suit_cards, 4) }
    end

    def carre_of_jacks?
      @cards.select { |card| card.rank == :jack }.size == 4
    end

    def carre_of_nines?
      @cards.select { |card| card.rank == 9 }.size == 4
    end

    def carre_of_aces?
      @cards.select { |card| card.rank == :ace }.size == 4
    end
  end

  def deal
    BeloteHand.new(@cards.shift(8))
  end
end

class SixtySixDeck < Deck
  def ranks
    [:ace, 10, :king, :queen, :jack, 9].freeze
  end

  def initialize(cards = all_possible_cards.dup)
    super
  end

  class SixtySixHand < Hand
    def twenty?(trump_suit)
      @cards.select { |card| card.suit != trump_suit }.
        select { |card| card.rank == :king || card.rank == :queen }.
        group_by { |card| card.suit }.
        any? { |_, cards_of_same_suit| cards_of_same_suit.size == 2 }
    end

    def forty?(trump_suit)
      @cards.select { |card| card.suit == trump_suit }.
        select { |card| card.rank == :king || card.rank == :queen }.size == 2
    end
  end

  def deal
    SixtySixHand.new(@cards.shift(6))
  end
end
