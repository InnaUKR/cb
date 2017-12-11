require 'spec_helper'

module Codebreaker
  RSpec.describe Game do
    let(:game) { Game.new }

    describe '#generates secret code' do
      before(:each) { game.send(:generate_secret_code) }
      it 'generates not empty secret code' do
        expect(game.instance_variable_get(:@secret_code)).not_to be_empty
      end

      it 'saves 4 numbers secret code' do
        expect(game.instance_variable_get(:@secret_code).length).to eq(4)
      end

      it 'saves secret code with numbers from 1 to 6' do
        expect(game.instance_variable_get(:@secret_code)).to all((be >= 1).and(be <= 6))
      end
    end

    describe '#count_pluses' do
      context 'usual situations' do
        before(:each) { game.instance_variable_set(:@secret_code, [1, 2, 3, 4]) }

        it 'codebreaker wins' do
          expect(game.send(:count_pluses, [1, 2, 3, 4])).to eq(4)
        end

        it 'codebreaker guess 3 numbers and them order' do
          expect(game.send(:count_pluses, [1, 2, 5, 4])).to eq(3)
        end

        it 'codebreaker did not guess anything' do
          expect(game.send(:count_pluses, [5, 5, 5, 5])).to eq(0)
        end

        it 'codebreaker input all the same' do
          expect(game.send(:count_pluses, [3, 3, 3, 3])).to eq(1)
        end
      end

      context 'more special situations' do
        it 'codebreaker guess 1 from 2 same' do
          game.instance_variable_set(:@secret_code, [1, 3, 3, 4])
          expect(game.send(:count_pluses, [5, 6, 3, 6])).to eq(1)
        end
      end
    end

    describe '#count_minuses' do
      context 'usual situations' do
        before(:each) { game.instance_variable_set(:@secret_code, [1, 2, 3, 4]) }

        it 'codebreaker guess numbers but not order' do
          expect(game.send(:count_minuses, [4, 3, 2, 1])).to eq(4)
        end

        it 'codebreaker guess 1 number but not order' do
          expect(game.send(:count_minuses, [4, 5, 6, 5])).to eq(1)
        end

        it 'codebreaker input few same numbers guess 1 but in wrong places' do
          expect(game.send(:count_minuses, [2, 5, 2, 6])).to eq(1)
        end
      end

      context 'more special situations' do
        it 'codebreaker guess 2 same numbers but in wrong places' do
          game.instance_variable_set(:@secret_code, [1, 2, 3, 2])
          expect(game.send(:count_minuses, [2, 5, 2, 5])).to eq(2)
        end

        it 'codebreaker input 3 same numbers(secret code contains 2 of them) but in wrong places' do
          game.instance_variable_set(:@secret_code, [1, 2, 2, 2])
          expect(game.send(:count_minuses, [2, 5, 2, 5])).to eq(1)
        end
      end
    end

    describe '#mark' do
      before(:each) { game.instance_variable_set(:@secret_code, [1, 2, 3, 4]) }

      it 'codebreaker guess 4 cow and 0 bulls' do
        expect(game.send(:mark, [1, 2, 3, 4])).to eq([4, 0])
      end

      it 'codebreaker guess 1 cow and 2 bulls' do
        expect(game.send(:mark, [1, 4, 2, 5])).to eq([1, 2])
      end

      it 'codebreaker guess 0 cow and 2 bulls' do
        expect(game.send(:mark, [3, 6, 1, 5])).to eq([0, 2])
      end

      it 'codebreaker guess 0 cow and 0 bulls' do
        expect(game.send(:mark, [5, 5, 6, 6])).to eq([0, 0])
      end
    end

    describe '#take_hint' do
      before(:each) do
        game.instance_variable_set(:@secret_code, [1, 2, 3, 4])
        game.instance_variable_set(:@hints_numb, 1)
      end

      it 'secret code include number from hint' do
        game.instance_variable_set(:@gotten_hints, [])
        expect(game.instance_variable_get(:@secret_code).include?(game.send(:take_hint)))
      end

      it 'always returns different prompts' do
        game.instance_variable_set(:@gotten_hints, [0, 1, 2])
        expect(game.send(:take_hint)).to eq(4)
      end
    end
  end
end
