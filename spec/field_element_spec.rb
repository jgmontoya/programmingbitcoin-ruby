require 'ecc'

RSpec.describe FieldElement do
  describe '#==' do
    context 'when comparing to nil' do
      it 'returns false' do
        element = described_class.new(3, 5)
        expect(element == nil).to be false
      end
    end

    context 'when comparing it to itself' do
      it 'returns true' do
        element = described_class.new(3, 5)
        expect(element == element).to be true  # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      end
    end

    context 'when comparing it to the same element' do
      it 'returns true' do
        element = described_class.new(3, 5)
        same_element = described_class.new(3, 5)
        expect(element == same_element).to be true
      end
    end

    context 'when comparing it to an element with different prime' do
      it 'returns false' do
        element = described_class.new(3, 5)
        other = described_class.new(3, 7)
        expect(element == other).to be false
      end

      context 'when comparing it to an element with different num' do
        it 'returns false' do
          element = described_class.new(3, 5)
          other = described_class.new(4, 7)
          expect(element == other).to be false
        end
      end
    end

    context 'when comparing it to an element with different num' do
      it 'returns false' do
        element = described_class.new(3, 5)
        other = described_class.new(4, 5)
        expect(element == other).to be false
      end
    end
  end

  describe '#!=' do
    context 'when comparing to nil' do
      it 'returns true' do
        element = described_class.new(3, 5)
        expect(!element.nil?).to be true
      end
    end

    context 'when comparing it to itself' do
      it 'returns false' do
        element = described_class.new(3, 5)
        expect(element != element).to be false  # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      end
    end

    context 'when comparing it to the same element' do
      it 'returns false' do
        element = described_class.new(3, 5)
        same_element = described_class.new(3, 5)
        expect(element != same_element).to be false
      end
    end

    context 'when comparing it to an element with different prime' do
      it 'returns true' do
        element = described_class.new(3, 5)
        other = described_class.new(3, 7)
        expect(element != other).to be true
      end

      context 'when comparing it to an element with different num' do
        it 'returns true' do
          element = described_class.new(3, 5)
          other = described_class.new(4, 7)
          expect(element != other).to be true
        end
      end
    end

    context 'when comparing it to an element with different num' do
      it 'returns true' do
        element = described_class.new(3, 5)
        other = described_class.new(4, 5)
        expect(element != other).to be true
      end
    end
  end

  describe '#+' do
    context 'when adding a FieldElement of different prime' do
      it 'raises TypeError' do
        element = described_class.new(3, 5)
        other = described_class.new(3, 7)
        expect { element + other }.to raise_error(TypeError)
      end
    end

    context 'when adding a FieldElement of the same prime' do
      it 'returns a FieldElement' do
        element = described_class.new(3, 5)
        other = described_class.new(2, 5)
        expect((element + other).class).to be described_class
      end

      context 'when the sum is less than the prime' do
        it 'returns the normal sum' do
          element = described_class.new(2, 31)
          other = described_class.new(15, 31)
          expect((element + other).num).to be 17
        end
      end

      context 'when the sum is larger than the prime' do
        it 'wraps around to stay on the field' do
          element = described_class.new(17, 31)
          other = described_class.new(21, 31)
          expect(element + other).to eq described_class.new(7, 31)
        end
      end
    end
  end

  describe '#-' do
    context 'when subtracting a FieldElement of different prime' do
      it 'raises TypeError' do
        element = described_class.new(3, 5)
        other = described_class.new(3, 7)
        expect { element - other }.to raise_error(TypeError)
      end
    end

    context 'when subtracting a FieldElement of the same prime' do
      it 'returns a FieldElement' do
        element = described_class.new(3, 5)
        other = described_class.new(2, 5)
        expect((element - other).class).to be described_class
      end

      context 'when the subtraction is greater than 0' do
        it 'returns the normal subtraction' do
          element = described_class.new(29, 31)
          other = described_class.new(4, 31)
          expect((element - other).num).to be 25
        end
      end

      context 'when the subtraction is less than 0' do
        it 'wraps around to stay on the field' do
          element = described_class.new(15, 31)
          other = described_class.new(30, 31)
          expect(element - other).to eq described_class.new(16, 31)
        end
      end
    end
  end

  describe '#*' do
    context 'when multiplying a FieldElement of different prime' do
      it 'raises TypeError' do
        element = described_class.new(3, 5)
        other = described_class.new(3, 7)
        expect { element * other }.to raise_error(TypeError)
      end
    end

    context 'when multiplying a FieldElement of the same prime' do
      it 'returns a FieldElement' do
        element = described_class.new(3, 5)
        other = described_class.new(2, 5)
        expect((element * other).class).to be described_class
      end

      context 'when the product is less than the prime' do
        it 'returns the normal product' do
          element = described_class.new(2, 31)
          other = described_class.new(15, 31)
          expect((element * other).num).to be 30
        end
      end

      context 'when the product is larger than the prime' do
        it 'wraps around to stay on the field' do
          element = described_class.new(24, 31)
          other = described_class.new(19, 31)
          expect(element * other).to eq described_class.new(22, 31)
        end
      end
    end
  end

  describe '#**' do
    context 'when the power is less than the prime' do
      it 'returns the normal power' do
        element = described_class.new(2, 31)
        expect((element**3).num).to be 8
      end
    end

    context 'when the power is larger than the prime' do
      it 'wraps around to stay on the field' do
        element = described_class.new(17, 31)
        expect(element**3).to eq described_class.new(15, 31)
      end
    end

    context 'when the exponent is -1' do
      it 'returns the multiplicative inverse' do
        element = described_class.new(17, 31)
        expect(element**-1).to eq described_class.new(11, 31)
      end
    end
  end

  describe '#/' do
    context 'when dividing a FieldElement of different prime' do
      it 'raises TypeError' do
        element = described_class.new(3, 5)
        other = described_class.new(3, 7)
        expect { element / other }.to raise_error(TypeError)
      end
    end

    context 'when dividing a FieldElement of the same prime' do
      it 'returns a FieldElement' do
        element = described_class.new(3, 5)
        other = described_class.new(2, 5)
        expect((element / other).class).to be described_class
      end

      it 'returns the normal product with the inverse' do
        element = described_class.new(3, 31)
        other = described_class.new(24, 31)
        expect(element / other).to eq described_class.new(4, 31)
      end
    end
  end
end
