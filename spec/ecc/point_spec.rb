require 'ecc/point'

RSpec.describe ECC::Point do
  let(:point) { described_class.new(-1, -1, 5, 7) }
  let(:identity) { described_class.new(nil, nil, 5, 7) }

  describe 'init' do
    context 'when Point is initialized but is not part of the curve' do
      it 'raises an ArgumentError' do
        expect { described_class.new(-1, 12, 5, 7) }.to raise_error(ArgumentError)
      end
    end

    context 'when Point is the identity point' do
      it 'returns creates a valid point' do
        expect([identity.x, identity.y]).to eq [nil,nil]
      end
    end
  end

  describe '#==' do
    context 'when comparing to nil' do
      it 'returns false' do
        expect(point == nil).to be false
      end
    end

    context 'when comparing to self' do
      it 'returns true' do
        expect(point == point).to be true # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      end
    end

    context 'when comparing it to same point different instance' do
      let(:same_point) { described_class.new(-1, -1, 5, 7) }

      it 'returns true' do
        expect(point == same_point).to be true
      end
    end

    context 'when comparing it to a point in same ECC with different "x" and "y" value' do
      let(:other) { described_class.new(18, 77, 5, 7) }

      it 'returns false' do
        expect(other == point).to be false
      end
    end

    context 'when comparing it to a Point in other ECC' do
      let(:other_curve) { described_class.new(1,2,1,2) }

      it 'returns false' do
        expect(point == other_curve).to be false
      end
    end
  end

  describe '#!=' do
    context 'when comparing to nil' do
      it 'returns true' do
        expect(point != nil).to be true
      end
    end

    context 'when comparing to self' do
      it 'returns false' do
        expect(point != point).to be false # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      end
    end

    context 'when comparing it to same point different instance' do
      let(:same_point) { described_class.new(-1, -1, 5, 7) }

      it 'returns false' do
        expect(point != same_point).to be false
      end
    end

    context 'when comparing it to a point in same ECC with different "x" and "y" value' do
      let(:other) { described_class.new(18, 77, 5, 7) }

      it 'returns true' do
        expect(other != point).to be true
      end
    end

    context 'when comparing it to a Point in other ECC' do
      let(:other_curve) { described_class.new(1,2,1,2) }

      it 'returns true' do
        expect(point != other_curve).to be true
      end
    end
  end

  describe '#to_s' do
    it 'parses point to expected format' do
      expect(point.to_s).to eq "Point(-1, -1)_5_7"
    end

    context 'when is the identity point' do
      it 'parses nil values as string nils' do
        expect(identity.to_s).to eq "Point(infinity)_5_7"
      end
    end
  end

  describe '#+' do
    context 'when points are different curves' do
      let(:other_curve) { described_class.new(1, 2, 1, 2) }

      it 'raises an TypeError' do
        expect { point + other_curve }.to raise_error(TypeError)
      end
    end

    context 'when one point is the identity Point' do
      it 'returns the non identity' do
        expect(point + identity).to eq point
      end
    end

    context 'when the point adding is the identity point' do
      it 'returns the non identity' do
        expect(identity + point).to eq point
      end
    end

    context 'when points are additive inverses' do
      let(:point) { described_class.new(1, -2, 1, 2) }
      let(:point_same_ecc) { described_class.new(1, 2, 1, 2) }

      it 'returns the identity' do
        new_point = point + point_same_ecc
        expect([new_point.x, new_point.y]).to eq [nil, nil]
      end
    end

    context 'when points are different but same ECC' do
      let(:point_same_ecc) { described_class.new(2, 5, 5, 7) }

      it 'returns a third point intersecting in the curve, reflecting on X' do
        result = point_same_ecc + point
        expect([result.x, result.y]).to eq [3,-7]
      end
    end

    context 'when points are same' do
      it 'returns a third point intersecting in the curve, reflecting on x' do
        result = point + point
        expect([result.x, result.y]).to eq [18.0, 77.0]
      end

      context 'when y is equal to 0' do
        let(:point) { described_class.new(-1, 0, 0, 1) }
        
        it 'returns identity' do
          result = point + point
          expect([result.x, result.y]).to eq [nil, nil]
        end
      end
    end
  end
end

