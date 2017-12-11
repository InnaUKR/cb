module Codebreaker
  class Game
    CODE_LENGTH = 4
  RANGE_OF_NUMBERS = (1..6)
  DIFFICULTY = {
    easy: { attempts: 30, hints: 3 },
    medium: { attempts: 15, hints: 2 },
    hard: { attempts: 10, hints: 1 }
  }.freeze

  attr_accessor :difficulty, :attempts_numb, :hints_numb

  def initialize
    generate_secret_code
  end

  def choose_difficulty(difficulty)
      @difficulty = difficulty.to_sym
      level = DIFFICULTY[@difficulty]
      @attempts_numb = level[:attempts]
      @hints_numb = level[:hints]
      @gotten_hints = []
  end

  def chose_difficulty?(difficulty)
    DIFFICULTY.keys.include?(difficulty.to_sym)
  end

  def got_guess_code?(guess_code)
    guess_code.length == CODE_LENGTH && guess_code.all? { |number| RANGE_OF_NUMBERS.include?(number) }
  end

  def take_hint
    index = nil
    loop do
      index = Random.rand(0...CODE_LENGTH)
      break unless @gotten_hints.include?(index)
    end
    @gotten_hints << index
    @hints_numb -= 1
    @secret_code[index]
  end

  def mark(guess_code)
    pluses_number = count_pluses(guess_code)
    minuses_number = count_minuses(guess_code)
    [pluses_number, minuses_number]
  end

  def win?(pluses_number)
    pluses_number == CODE_LENGTH
  end

  private

  def generate_secret_code
      @secret_code = Array.new(CODE_LENGTH) { Random.rand(RANGE_OF_NUMBERS) }
  end

  def count_pluses(guess_code)
    secret_code, guess_code = remove_pluses(guess_code)
    pluses_number = CODE_LENGTH - secret_code.length
  end

  def remove_pluses(guess_code)
    secret_code, guess_code = @secret_code.zip(guess_code).reject { |s, g| s == g }.transpose
    [secret_code.to_a, guess_code.to_a]
  end

  def count_minuses(guess_code)
    secret_code, new_guess_code = remove_pluses(guess_code)
    new_guess_code.count do |x|
      index = secret_code.find_index(x)
      secret_code.delete_at(index) if index
    end
  end
  end
end
