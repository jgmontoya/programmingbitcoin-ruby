require 'ecc/private_key'
require 'ecc/signature'

RSpec.describe ECC::PrivateKey do
  describe '#sign' do
    let(:secret) { rand(Secp256k1Constants::N) }
    let(:private_key) { described_class.new(secret) }
    let(:z) { rand(Secp256k1Constants::N) }
    let(:signature) { private_key.sign(z) }

    it 'generates a valid point verifiable signature' do
      expect(private_key.point.verify(z, signature)).to be true
    end

    it 'generates a valid signature' do
      s_inv = signature.s.pow(Secp256k1Constants::N - 2, Secp256k1Constants::N)
      u = z * s_inv % Secp256k1Constants::N
      v = signature.r * s_inv % Secp256k1Constants::N
      random_target = (ECC::S256Point::G * u + private_key.point * v).x.num
      expect(signature.r).to eq random_target
    end
  end

  describe '#wif' do
    it 'returns the proper compressed wif private key for testnet' do
      secret = 0x1cca23de92fd1862fb5b76e5f4f50eb082165e5191e116c18ed1a6b24be6a53f
      wif = 'cNYfWuhDpbNM1JWc3c6JTrtrFVxU4AGhUKgw5f93NP2QaBqmxKkg'
      expect(described_class.new(secret).wif(compressed: true, testnet: true)).to eq wif
    end

    it 'returns the proper uncompressed wif private key for testnet' do
      secret = 2**256 - 2**201
      wif = '93XfLeifX7Jx7n7ELGMAf1SUR6f9kgQs8Xke8WStMwUtrDucMzn'
      expect(described_class.new(secret).wif(compressed: false, testnet: true)).to eq wif
    end

    it 'returns the proper compressed wif private key for mainnet' do
      secret = 2**256 - 2**199
      wif = 'L5oLkpV3aqBJ4BgssVAsax1iRa77G5CVYnv9adQ6Z87te7TyUdSC'
      expect(described_class.new(secret).wif(compressed: true, testnet: false)).to eq wif
    end

    it 'returns the proper uncompressed wif private key for mainnet' do
      secret = 0x0dba685b4511dbd3d368e5c4358a1277de9486447af7b3604a69b8d9d8b7889d
      wif = '5HvLFPDVgFZRK9cd4C5jcWki5Skz6fmKqi1GQJf5ZoMofid2Dty'
      expect(described_class.new(secret).wif(compressed: false, testnet: false)).to eq wif
    end
  end
end
