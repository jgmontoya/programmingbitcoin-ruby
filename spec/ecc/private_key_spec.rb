require 'ecc/private_key'
require 'ecc/signature'

RSpec.describe ECC::PrivateKey do

  describe 'sign' do
    let(:secret) { rand(Secp256k1Constants::N) }
    let(:private_key) { described_class.new(secret) }
    let(:z) { rand(Secp256k1Constants::N) }
    let(:signature) { private_key.sign(z) }

    context 'validation using point method verify' do
      it 'generates a valid signature' do
        expect(private_key.point.verify(z, signature)).to be true
      end
    end

    context 'validation using analytical calculations' do
      let(:s_inv) { signature.s.pow(Secp256k1Constants::N - 2, Secp256k1Constants::N) }
      let(:u) { z * s_inv % Secp256k1Constants::N }
      let(:v) { signature.r * s_inv % Secp256k1Constants::N }
      let(:random_target) { (ECC::S256Point::G * u + private_key.point * v).x.num }

      it 'generates a valid signature' do
        expect(signature.r).to eq random_target
      end
    end
  end
end
