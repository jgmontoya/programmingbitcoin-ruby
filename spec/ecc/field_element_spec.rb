require 'ecc/field_element'

RSpec.describe ECC::FieldElement do
  let(:element) { described_class.new(3, 5) }
  let(:other) { described_class.new(3, 7) }

  describe '#==' do
    context 'when comparing to nil' do
      it 'returns false' do
        expect(element == nil).to be false
      end
    end

    context 'when comparing it to itself' do
      it 'returns true' do
        expect(element == element).to be true  # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      end
    end

    context 'when comparing it to the same element' do
      let(:same_element) { described_class.new(3, 5) }

      it 'returns true' do
        expect(element == same_element).to be true
      end
    end

    context 'when comparing it to an element with different prime' do
      it 'returns false' do
        expect(element == other).to be false
      end

      context 'when comparing it to an element with different num' do
        let(:other) { described_class.new(4, 7) }

        it 'returns false' do
          expect(element == other).to be false
        end
      end
    end

    context 'when comparing it to an element with different num' do
      let(:other) { described_class.new(4, 5) }

      it 'returns false' do
        expect(element == other).to be false
      end
    end
  end

  describe '#!=' do
    context 'when comparing to nil' do
      it 'returns true' do
        expect(!element.nil?).to be true
      end
    end

    context 'when comparing it to itself' do
      it 'returns false' do
        expect(element != element).to be false  # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      end
    end

    context 'when comparing it to the same element' do
      let(:same_element) { described_class.new(3, 5) }

      it 'returns false' do
        expect(element != same_element).to be false
      end
    end

    context 'when comparing it to an element with different prime' do
      it 'returns true' do
        expect(element != other).to be true
      end

      context 'when comparing it to an element with different num' do
        let(:other) { described_class.new(4, 7) }

        it 'returns true' do
          expect(element != other).to be true
        end
      end
    end

    context 'when comparing it to an element with different num' do
      let(:other) { described_class.new(4, 5) }

      it 'returns true' do
        expect(element != other).to be true
      end
    end
  end

  describe '#+' do
    context 'when adding a FieldElement of different prime' do
      it 'raises TypeError' do
        expect { element + other }.to raise_error(TypeError)
      end
    end

    context 'when adding a FieldElement of the same prime' do
      let(:other) { described_class.new(2, 5) }

      it 'returns a FieldElement' do
        expect((element + other).class).to be described_class
      end

      context 'when the sum is less than the prime' do
        let(:element) { described_class.new(2, 31) }
        let(:other) { described_class.new(15, 31) }

        it 'returns the normal sum' do
          expect((element + other).num).to be 17
        end
      end

      context 'when the sum is larger than the prime' do
        let(:element) { described_class.new(17, 31) }
        let(:other) { described_class.new(21, 31) }

        it 'wraps around to stay on the field' do
          expect(element + other).to eq described_class.new(7, 31)
        end
      end
    end
  end

  describe '#-' do
    context 'when subtracting a FieldElement of different prime' do
      it 'raises TypeError' do
        expect { element - other }.to raise_error(TypeError)
      end
    end

    context 'when subtracting a FieldElement of the same prime' do
      let(:other) { described_class.new(2, 5) }

      it 'returns a FieldElement' do
        expect((element - other).class).to be described_class
      end

      context 'when the subtraction is greater than 0' do
        let(:element) { described_class.new(29, 31) }
        let(:other) { described_class.new(4, 31) }

        it 'returns the normal subtraction' do
          expect((element - other).num).to be 25
        end
      end

      context 'when the subtraction is less than 0' do
        let(:element) { described_class.new(15, 31) }
        let(:other) { described_class.new(30, 31) }
        let(:solution) { described_class.new(16, 31) }

        it 'wraps around to stay on the field' do
          expect(element - other).to eq solution
        end
      end
    end
  end

  describe '#*' do
    context 'when multiplying a FieldElement of different prime' do
      it 'raises TypeError' do
        expect { element * other }.to raise_error(TypeError)
      end
    end

    context 'when multiplying a FieldElement of the same prime' do
      let(:other) { described_class.new(2, 5) }

      it 'returns a FieldElement' do
        expect((element * other).class).to be described_class
      end

      context 'when the product is less than the prime' do
        let(:element) { described_class.new(2, 31) }
        let(:other) { described_class.new(15, 31) }

        it 'returns the normal product' do
          expect((element * other).num).to be 30
        end
      end

      context 'when the product is larger than the prime' do
        let(:element) { described_class.new(24, 31) }
        let(:other) { described_class.new(19, 31) }
        let(:solution) { described_class.new(22, 31) }

        it 'wraps around to stay on the field' do
          expect(element * other).to eq solution
        end
      end
    end
  end

  describe '#**' do
    context 'when the power is less than the prime' do
      let(:element) { described_class.new(2, 31) }

      it 'returns the normal power' do
        expect((element**3).num).to be 8
      end
    end

    context 'when the power is larger than the prime' do
      let(:element) { described_class.new(17, 31) }
      let(:solution) { described_class.new(15, 31) }

      it 'wraps around to stay on the field' do
        expect(element**3).to eq solution
      end
    end

    context 'when the exponent is -1' do
      let(:element) { described_class.new(17, 31) }
      let(:solution) { described_class.new(11, 31) }

      it 'returns the multiplicative inverse' do
        expect(element**-1).to eq solution
      end
    end
  end

  describe '#/' do
    context 'when dividing a FieldElement of different prime' do
      it 'raises TypeError' do
        expect { element / other }.to raise_error(TypeError)
      end
    end

    context 'when dividing a FieldElement of the same prime' do
      let(:element) { described_class.new(3, 31) }
      let(:other) { described_class.new(24, 31) }
      let(:solution) { described_class.new(4, 31) }

      it 'returns a FieldElement' do
        expect((element / other).class).to be described_class
      end

      it 'returns the normal product with the inverse' do
        expect(element / other).to eq solution
      end
    end
  end
end
