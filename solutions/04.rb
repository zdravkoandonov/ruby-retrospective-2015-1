class Card < Struct.new(:rank, :suit)
  def to_s
    "#{rank.to_s.capitalize} of #{suit.to_s.capitalize}"
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
    INITIAL_SIZE = 26

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
    WarHand.new(@cards.shift(WarHand::INITIAL_SIZE))
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
    INITIAL_SIZE = 8

    def highest_of_suit(suit)
      BeloteDeck.new(@cards.select { |card| card.suit == suit }).sort.first
    end

    def belote?
      @cards.select { |card| card.rank == :king || card.rank == :queen }.
        group_by { |card| card.suit }.
        any? { |_, same_suit_cards| same_suit_cards.size == 2 }
    end

    def tierce?
      contain_consecutive?(@cards, 3)
    end

    def quarte?
      contain_consecutive?(@cards, 4)
    end

    def quint?
      contain_consecutive?(@cards, 5)
    end

    def carre_of_jacks?
      carre?(:jack)
    end

    def carre_of_nines?
      carre?(9)
    end

    def carre_of_aces?
      carre?(:ace)
    end

    private

    def carre?(card_rank)
      @cards.select { |card| card.rank == card_rank }.size == 4
    end

    def contain_consecutive?(cards, count)
      BeloteDeck.new(@cards).sort.to_a.group_by { |card| card.suit }.
        any? do |_, same_suit_cards|
          contain_consecutive_among_same_suit?(same_suit_cards, count)
        end
    end

    def contain_consecutive_among_same_suit?(ordered_same_suit_cards, count)
      ranks = BeloteDeck.new.ranks
      ordered_same_suit_cards.each_cons(count).any? do |consecutive_cards|
        cards_ranks = consecutive_cards.collect { |card| card.rank }
        rank_index = ranks.index(cards_ranks.first)
        ranks[rank_index...(rank_index + count)] == cards_ranks
      end
    end
  end

  def deal
    BeloteHand.new(@cards.shift(BeloteHand::INITIAL_SIZE))
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
    INITIAL_SIZE = 6

    def twenty?(trump_suit)
      pair_of_queen_and_king?(@cards.select { |card| card.suit != trump_suit })
    end

    def forty?(trump_suit)
      pair_of_queen_and_king?(@cards.select { |card| card.suit == trump_suit })
    end

    private

    def pair_of_queen_and_king?(cards)
      cards.select { |card| card.rank == :king || card.rank == :queen }.
        group_by { |card| card.suit }.
        any? { |_, same_suit_cards| same_suit_cards.size == 2 }
    end
  end

  def deal
    SixtySixHand.new(@cards.shift(SixtySixHand::INITIAL_SIZE))
  end
end
