module Codebreaker
  class Console
    PHRASES_PATH = 'lib/codebreaker/src/phrases.yml'.freeze
    SCORES_FILE_PATH = 'lib/codebreaker/src/statistic.txt'.freeze

    attr_accessor :phrases, :game

    def initialize
      @phrases = YAML.load_file(PHRASES_PATH)
    end

    def start
      @game = Game.new
      loop do
        begin
          difficulty = choose_difficulty
        end until game.chose_difficulty?(difficulty)
        game.choose_difficulty(difficulty)
        play
        propose_save
        break unless play_again?
      end
    end

    def play
      loop do
        show_info(game.attempts_numb, game.hints_numb)
        game.attempts_numb -= 1
        propose_hint
        begin
          guess_code = make_guess
        end until game.got_guess_code?(guess_code)
        pluses_numb, minuses_numb = game.mark(guess_code)
        return win_game if game.win?(pluses_numb) # pluses_numb == CODE_LENGTH
        show_result(pluses_numb, minuses_numb)
        break if game.attempts_numb.zero?
      end
      lose_game
    end

    def propose_hint
      while game.hints_numb > 0
        break unless take_hint?
        hint = game.take_hint!
        show_hint(hint)
      end
    end

    def propose_save
      return until save?
      name = ask_name
      File.open(SCORES_FILE_PATH, 'a') do |f|
        f.puts("#{name}, #{game.difficulty}, #{game.attempts_numb}, #{game.hints_numb}")
      end
    end

    def show_sentence(parameter)
      puts parameter
    end

    def ask_phrase(parameter)
      puts phrases[parameter.to_sym]
      gets.chomp
    end

    def play_again?
      ask_phrase(:play_again) == 'y'
    end

    def take_hint?
      ask_phrase(:hint_message) == 'y'
    end

    def save?
      ask_phrase(:ask_save) == 'y'
    end

    def ask_name
      ask_phrase(:ask_name)
    end

    def make_guess
      guess_string = ask_phrase(:enter_numbers)
      guess_code = guess_string.split('').map(&:to_i)
    end

    def show_hint(hint)
      puts hint
    end

    def choose_difficulty
      show_sentence(phrases[:choose_difficulty])
      phrases[:difficulty].each { |x| puts x }
      puts phrases[:enter_difficulty]
      gets.chomp
    end

    def show_info(attempts_numb, hints_numb)
      show_sentence phrases[:separator]
      show_sentence 'attempts: ' + attempts_numb.to_s
      show_sentence 'hints: ' + hints_numb.to_s
      show_sentence phrases[:separator]
    end

    def show_result(pluses_numb, minuses_numb)
      show_sentence pluses_numb.to_s + '+'
      show_sentence minuses_numb.to_s + '-'
    end

    def win_game
      show_sentence(phrases[:win])
    end

    def lose_game
      show_sentence(phrases[:lose])
    end
  end
end
