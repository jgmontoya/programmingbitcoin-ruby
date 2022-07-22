# encoding: ascii-8bit
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

  describe '#encode_varint' do
    context 'when the integer is below 0xfd' do
      let(:integer) { 0x5d }

      it 'returns the number as a single byte' do
        expect(described_module.encode_varint(integer)).to eq "\x5d"
      end
    end

    context 'when the integer is above 0xfd and below 0x10000' do
      let(:integer) { 0x012c }

      it 'returns `0xfd` + the number in two bytes in little endian' do
        expect(described_module.encode_varint(integer)).to eq "\xfd\x2c\x01"
      end
    end

    context 'when the integer is above 0x10000 and below 0x100000000' do
      let(:integer) { 0xf3946ba }

      it 'returns `0xfe` + the number in four bytes in little endian' do
        expect(described_module.encode_varint(integer)).to eq "\xfe\xba\x46\x39\x0f"
      end
    end

    context 'when the integer is above 0x100000000 and below 0x10000000000000000' do
      let(:integer) { 0x100000000000 }

      it 'returns `0xff` + the number in eight bytes in little endian' do
        expect(described_module.encode_varint(integer)).to eq "\xff\x00\x00\x00\x00\x00\x10\x00\x00"
      end
    end

    context 'when the integer is above 0x10000000000000000' do
      let(:integer) { 0x10000000000000000 }

      it 'raises an EncodingError' do
        expect { described_module.encode_varint(integer) }.to raise_error(EncodingError)
      end
    end
  end

  describe '#h160_to_p2pkh_address' do
    let(:h160) { ['74d691da1574e6b3c192ecfb52cc8984ee7b6c56'].pack('H*') }

    context 'when testnet is true' do
      let(:testnet) { true }

      it 'calculates the testnet address' do
        expect(described_module.h160_to_p2pkh_address(h160, testnet: testnet))
          .to eq('mrAjisaT4LXL5MzE81sfcDYKU3wqWSvf9q')
      end
    end

    context 'when testnet is false' do
      let(:testnet) { false }

      it 'calculates the mainnet address' do
        expect(described_module.h160_to_p2pkh_address(h160, testnet: testnet))
          .to eq('1BenRpVUFK65JFWcQSuHnJKzc4M8ZP8Eqa')
      end
    end
  end

  describe '#h160_to_p2sh_address' do
    let(:h160) { ['74d691da1574e6b3c192ecfb52cc8984ee7b6c56'].pack('H*') }

    context 'when testnet is true' do
      let(:testnet) { true }

      it 'calculates the testnet address' do
        expect(described_module.h160_to_p2sh_address(h160, testnet: testnet))
          .to eq('2N3u1R6uwQfuobCqbCgBkpsgBxvr1tZpe7B')
      end
    end

    context 'when testnet is false' do
      let(:testnet) { false }

      it 'calculates the mainnet address' do
        expect(described_module.h160_to_p2sh_address(h160, testnet: testnet))
          .to eq('3CLoMMyuoDQTPRD3XYZtCvgvkadrAdvdXh')
      end
    end
  end

  describe '#encode_num' do
    context 'when the number is 0' do
      let(:num) { 0 }

      it 'returns an empty string' do
        expect(described_module.encode_num(num)).to eq ""
      end
    end

    context 'when the number is not 0' do
      let(:num) { 7 }

      it 'returns the number as a single byte' do
        expect(described_module.encode_num(num)).to eq "\x07"
      end
    end
  end
end
