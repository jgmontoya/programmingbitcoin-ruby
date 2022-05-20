require 'ecc/s256_field'

RSpec.describe ECC::S256Field do
  let(:num) { 637353833 }
  let(:element) { described_class.new(num)}
  let(:p_order) { (2**256 - 2**32 - 977) }

  describe 'init' do
    it 'sets P as prime' do
      expect(element.prime).to eq p_order
    end
  end

  describe '#to_s' do
    it 'parses s256 field element to expected format' do
      expect(element.to_s).to eq "0000000000000000000000000000000000000000000000000000000637353833"
    end
  end
end
