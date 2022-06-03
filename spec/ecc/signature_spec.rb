require 'ecc/signature'

RSpec.describe ECC::Signature do
  let(:r) { 0xac8d1c87e51d0d441be8b3dd5b05c8795b48875dffe00b7ffcfac23010d3a395 }
  let(:s) { 0x68342ceff8935ededd102dd876ffd6ba72d6a427a3edb13d26eb0781cb423c4 }
  let(:signature) { described_class.new(r, s) }

  describe '#to_s' do
    let(:string_format) do
      "Signature(78047132305074547209667415378684003360790728528333174453334458954808711947157,"\
      " 2945795152904547855448158643091235482997756069461486099501216307557115896772)"
    end

    it 'parses signature to expected format' do
      expect(signature.to_s).to eq string_format
    end
  end

  describe '#==' do
    it 'returns true on equal r and s signatures' do
      r = 0x37206a0610995c58074999cb9767b87af4c4978db68c06e8e6e81d282047a7c6
      s = 0x8ca63759c1157ebeaec0d03cecca119fc9a75bf8e6d0fa65c841c8e2738cdaec
      sig1 = described_class.new(r, s)
      sig2 = described_class.new(r, s)
      expect(sig1 == sig2).to be true
    end

    it 'returns false on different r' do
      r = 0x37206a0610995c58074999cb9767b87af4c4978db68c06e8e6e81d282047a7c6
      s = 0x8ca63759c1157ebeaec0d03cecca119fc9a75bf8e6d0fa65c841c8e2738cdaec
      sig1 = described_class.new(r, s)
      sig2 = described_class.new(r + 1, s)
      expect(sig1 == sig2).to be false
    end

    it 'returns false on different s' do
      r = 0x37206a0610995c58074999cb9767b87af4c4978db68c06e8e6e81d282047a7c6
      s = 0x8ca63759c1157ebeaec0d03cecca119fc9a75bf8e6d0fa65c841c8e2738cdaec
      sig1 = described_class.new(r, s)
      sig2 = described_class.new(r, s + 1)
      expect(sig1 == sig2).to be false
    end
  end

  describe '#der' do
    it 'serializes signature in DER format' do
      hex_der_sig = "3045022037206a0610995c58074999cb9767b87af4c4978db68c06e8e6e81d282047a7c602210"\
                    "08ca63759c1157ebeaec0d03cecca119fc9a75bf8e6d0fa65c841c8e2738cdaec"
      r = 0x37206a0610995c58074999cb9767b87af4c4978db68c06e8e6e81d282047a7c6
      s = 0x8ca63759c1157ebeaec0d03cecca119fc9a75bf8e6d0fa65c841c8e2738cdaec
      sig = described_class.new(r, s)
      expect(sig.der.unpack1('H*')).to eq hex_der_sig
    end
  end

  describe '#self.parse' do
    it 'returns the proper Signature object' do
      r = 0x37206a0610995c58074999cb9767b87af4c4978db68c06e8e6e81d282047a7c6
      s = 0x8ca63759c1157ebeaec0d03cecca119fc9a75bf8e6d0fa65c841c8e2738cdaec
      sig = described_class.new(r, s)
      expect(described_class.parse(sig.der)).to eq sig
    end
  end
end
