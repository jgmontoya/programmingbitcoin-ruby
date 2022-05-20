require 'ecc/field_element'
require 'ecc/point'

RSpec.describe ECC do
  let(:prime) { 223 }
  let(:a) { ECC::FieldElement.new(0, prime) }
  let(:b) { ECC::FieldElement.new(7, prime) }
  let(:x1) { ECC::FieldElement.new(192, prime) }
  let(:y1) { ECC::FieldElement.new(105, prime) }
  let(:point_1) { ECC::Point.new(x1, y1, a, b) }

  describe 'point init over field elements' do
    context 'when point is not part of the curve' do
      let(:x) { ECC::FieldElement.new(200, prime) }
      let(:y) { ECC::FieldElement.new(199, prime) }

      it 'raises an ArgumentError' do
        expect { ECC::Point.new(x, y, a, b) }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'point addition over finite elements' do
    context 'when points are over same finite field' do
      let(:x2) { ECC::FieldElement.new(17, prime) }
      let(:y2) { ECC::FieldElement.new(56, prime) }
      let(:point_2) { ECC::Point.new(x2, y2, a, b) }

      let(:x_sol) { ECC::FieldElement.new(170, prime) }
      let(:y_sol) { ECC::FieldElement.new(142, prime) }
      let(:solution) { ECC::Point.new(x_sol, y_sol, a, b) }

      it 'returns the point sum' do
        expect(point_1 + point_2).to eq solution
      end
    end
  end

  describe 'scalar multiplication of point over finite elements' do
      let(:scalar) { 2 }
      let(:x) { ECC::FieldElement.new(49, prime) }
      let(:y) { ECC::FieldElement.new(71, prime) }
      let(:solution) { ECC::Point.new(x, y, a, b) }

      it 'returns the point scalar product' do
        expect(point_1 * scalar ).to eq solution
      end
  end
end
