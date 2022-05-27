require 'ecc/s256_point'
require 'ecc/s256_field'
require 'ecc/field_element'
require 'ecc/signature'
require 'ecc/secp256k1_constants'

RSpec.describe ECC::S256Point do
  describe 'init' do
    context 'when S256Point is initialized but is not part of the curve' do
      let(:x) { 0x887387e452b8eacc4acfde10d9aaf7e6d9a0f975aabb10d006e4da568744d06c }
      let(:y) { 0x61de6d95231cd29026e286df3e6ae4a894a3378e393e93a0f45b666329a0ae34 }

      it 'raises an ArgumentError' do
        expect { described_class.new(x, y) }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'order of group' do
    let(:identity) { Secp256k1Constants::N * described_class::G }

    it 'returns identity point' do
      expect([identity.x, identity.y]).to eq [nil, nil]
    end
  end

  describe 'secret and generator point solves to public point' do
    let(:secret) { 7 }
    let(:x) { 0x5cbdf0646e5db4eaa398f365f2ea7a0e3d419b7e0330e39ce92bddedcac4f9bc }
    let(:y) { 0x6aebca40ba255960a3178d6d861a54dba813d0b813fde7b5a5082628087264da }
    let(:point) { described_class.new(x, y) }

    it 'returns public point' do
      expect(secret * described_class::G).to eq point
    end
  end

  describe 'verify' do
    let(:x) { 0x887387e452b8eacc4acfde10d9aaf7f6d9a0f975aabb10d006e4da568744d06c }
    let(:y) { 0x61de6d95231cd89026e286df3b6ae4a894a3378e393e93a0f45b666329a0ae34 }
    let(:point) { described_class.new(x, y) }

    let(:r) { 0xac8d1c87e51d0d441be8b3dd5b05c8795b48875dffe00b7ffcfac23010d3a395 }
    let(:s) { 0x68342ceff8935ededd102dd876ffd6ba72d6a427a3edb13d26eb0781cb423c4 }
    let(:signature) { ECC::Signature.new(r, s) }

    let(:z) { 0xec208baa0fc1c19f708a9ca96fdeff3ac3f230bb4a7ba4aede4942ad003c0f60 }

    context 'when signature is valid' do
      it 'returns true' do
        expect(point.verify(z, signature)).to be true
      end
    end

    context 'when signature is not valid' do
      let(:r_modified) { 0xac8d1c87eeed0d441be8b3dd5b05c8795b48875dffe00b7ffcfac23010d3a395 }
      let(:signature_modified) { ECC::Signature.new(r_modified, s) }

      it 'returns false' do
        expect(point.verify(z, signature_modified)).to be false
      end
    end

    context 'when message is altered' do
      let(:z_modified) { 0xec208baa0fc1c194408a9ca96fdeff3ac3f230bb4a7ba4aede4942ad003c0f60 }

      it 'returns false' do
        expect(point.verify(z_modified, signature)).to be false
      end
    end
  end
end
