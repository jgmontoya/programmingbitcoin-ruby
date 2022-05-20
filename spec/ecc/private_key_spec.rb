require 'ecc/private_key'
require 'ecc/signature'

RSpec.describe ECC::PrivateKey do

  describe 'sign' do
    let(:secret) { rand(ECC::N) }
    let(:private_key) { described_class.new(secret) }
    let(:z) { rand(ECC::N) }
    let(:signature) { private_key.sign(z) }

    it 'generates a valid signature' do
      expect(private_key.point.verify(z, signature)).to be true
    end
  end
end
