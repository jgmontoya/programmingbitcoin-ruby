require 'encoding_helper'

RSpec.describe EncodingHelper do
  let(:described_module) { Object.new.extend described_class }

  describe '#to_bytes' do
    it 'computes the little endian bytes' do
      bytes_solution = ",\x0f\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"\
                       "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
      bytes = described_module.to_bytes(69420, 32, 'little')
      expect(bytes).to eq bytes_solution
    end

    it 'computes the big endian bytes' do
      bytes_solution = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"\
                       "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x0f,"
      bytes = described_module.to_bytes(69420, 32, 'big')
      expect(bytes).to eq bytes_solution
    end
  end

  describe '#from_bytes' do
    it 'computes the int from byte array in big endian' do
      bytes = "\x00\x00\x01\xff\x00\x00\x01\xff"
      expect(described_module.from_bytes(bytes, 'big')).to eq 2194728288767
    end

    it 'computes the int from byte array in little endian' do
      bytes = "\x00\x00\x01\xff\x00\x00\x01\xff"
      expect(described_module.from_bytes(bytes, 'little')).to eq 18374967958926589952
    end
  end

  describe '#encode_base58' do
    it 'properly encodes to base 58' do
      base58 = 'vfUSmu3zfEoexnsWT1rSwgbStVv'
      expect(described_module.encode_base58('Bitcoin Guild rocks!')).to eq base58
    end
  end

  describe '#encode_base58_checksum' do
    it 'encodes in base58 the bytes with checksum' do
      base58 = '749vn7Y5mhjURoGG3gk25WxY3SxkE21fN'
      expect(described_module.encode_base58_checksum('Bitcoin Guild rocks!')).to eq base58
    end
  end

  describe '#decode_base58' do
    it 'decodes a base58 with checksum message' do
      message = 'Bitcoin Guild rocks!'
      checksum_encoded = described_module.encode_base58_checksum(message)
      expect(described_module.decode_base58(checksum_encoded)).to eq message
    end

    it 'raises an error when checksum does not match' do
      message = 'Bitcoin Guild rocks!'
      checksum_encoded = described_module.encode_base58_checksum(message)
      checksum_encoded[-1] = 'X'
      expect { described_module.decode_base58(checksum_encoded) }.to raise_error StandardError
    end
  end

  describe '#little_endian_to_int' do
    it 'takes byte sequence as a little-endian number' do
      bytes = '99c3980000000000'.to_i(16).digits(256).reverse.pack('c*')
      expect(described_module.little_endian_to_int(bytes)).to eq 10011545
    end
  end

  describe '#int_to_little_endian' do
    it 'takes an integer and returns the little-endian byte sequence of length' do
      expect(described_module.int_to_little_endian(1, 4)).to eq "\x01\x00\x00\x00"
    end
  end
end